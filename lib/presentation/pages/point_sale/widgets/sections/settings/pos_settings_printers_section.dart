
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/printer/bluetooth/bluetooth_permission_manager.dart';
import '../../../../../../shared/printer/cpcl/cpcl_receipt_util.dart';
import '../../../../../../shared/printer/models/printer_device.dart';
import '../../../../../../shared/printer/printer_service.dart';
import '../../../../../../shared/printer/bluetooth/printer_discovery_manager.dart';
import '../../../../../widgets/empty_data.dart';

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/printer/bluetooth/bluetooth_permission_manager.dart';
import '../../../../../../shared/printer/models/printer_device.dart';
import '../../../../../../shared/printer/printer_service.dart';
import '../../../../../../shared/printer/bluetooth/printer_discovery_manager.dart';
import '../../../../../widgets/empty_data.dart';

class PosSettingsPrintersSection extends StatefulWidget {
  final PrinterService printerService;

  const PosSettingsPrintersSection({
    super.key,
    required this.printerService,
  });

  @override
  State<PosSettingsPrintersSection> createState() =>
      _PosSettingsPrintersSectionState();
}

class _PosSettingsPrintersSectionState
    extends State<PosSettingsPrintersSection> {
  late final PrinterDiscoveryManager _manager;
  static const MethodChannel _printerChannel = MethodChannel("pos/printer_bluetooth_classic");

  int _selectedPrinterTab = 0;

  bool _isSearching = false;
  bool _isLoading = false;

  String? _pairingAddress;
  String? _errorMessage;

  List<PrinterDevice> _foundDevices = [];
  List<PrinterDevice> _bondedDevices = [];
  List<PrinterDevice> _savedDevices = [];

  // ==========================================
  // LIFECYCLE
  // ==========================================

  @override
  void initState() {
    super.initState();

    _manager = context.read<PrinterDiscoveryManager>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitial();
    });
  }

  // ==========================================
  // INITIAL LOAD
  // ==========================================

  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    debugPrint(
      '[YapitaPrintersSection] BONDED_PERMISSION_CHECK sdk=$sdkInt',
    );

    // Android 10 y 11: los dispositivos ya emparejados
    // no necesitan permiso de ubicación.
    if (sdkInt < 31) {
      debugPrint(
        '[YapitaPrintersSection] BONDED_PERMISSION_LEGACY_OK',
      );
      return true;
    }

    // Android 12+: requiere BLUETOOTH_CONNECT.
    final status = await Permission.bluetoothConnect.request();

    debugPrint(
      '[YapitaPrintersSection] BONDED_PERMISSION_RESULT $status',
    );

    return status.isGranted;
  }
  Future<void> _loadInitial() async {
    if (_isLoading || _isSearching || _pairingAddress != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ==========================================
      // 1. CARGAR DISPOSITIVOS GUARDADOS
      // ==========================================

      final saved = await _manager.loadSaved();

      if (!mounted) return;

      setState(() {
        _savedDevices = saved;
      });

      // ==========================================
      // 2. SOLICITAR PERMISOS BLUETOOTH
      // ==========================================

      final granted = await _requestBluetoothPermissions();

      if (!mounted) return;

      if (!granted) {
        _showError(
          'Debes autorizar los permisos Bluetooth '
              'para consultar los dispositivos emparejados.',
        );
        return;
      }

      // ==========================================
      // 3. CONSULTAR EMPAREJADOS EN ANDROID
      // ==========================================

      final bonded = await _manager.getBondedDevices();

      if (!mounted) return;

      // ==========================================
      // 4. ACTUALIZAR CACHÉ LOCAL
      // ==========================================

      final updatedSaved = await _manager.loadSaved();

      if (!mounted) return;

      // ==========================================
      // 5. ACTUALIZAR INTERFAZ
      // ==========================================

      setState(() {
        _bondedDevices = bonded;
        _savedDevices = updatedSaved;
      });
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // ==========================================
  // SCAN
  // ==========================================

  Future<void> _searchDevices() async {
    if (_isSearching || _isLoading || _pairingAddress != null) {
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _foundDevices = [];
    });

    try {
      debugPrint('[YapitaPrintersSection] SEARCH_REQUEST');
      final ready = await BluetoothPermissionManager.ensureReadyForScan(context);
      if (!mounted || !ready) {
        debugPrint('[YapitaPrintersSection] SEARCH_NOT_READY');
        return;
      }
      debugPrint('[YapitaPrintersSection] SCAN_START');
      final found = await _manager.scan();
      final bonded = await _manager.getBondedDevices();
      final saved = await _manager.loadSaved();

      if (!mounted) return;

      setState(() {
        _foundDevices = found;
        _bondedDevices = bonded;
        _savedDevices = saved;
      });
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // ==========================================
  // PAIR
  // ==========================================

  Future<void> _pairDevice(PrinterDevice device) async {
    if (_pairingAddress != null || _isSearching || _isLoading) {
      return;
    }

    setState(() {
      _pairingAddress = device.address;
      _errorMessage = null;
    });

    try {
      final paired = await _manager.pair(device);

      final bonded = await _manager.getBondedDevices();
      final saved = await _manager.loadSaved();

      if (!mounted) return;

      setState(() {
        _bondedDevices = bonded;
        _savedDevices = saved;

        _foundDevices = _foundDevices.map((item) {
          if (_sameDevice(item, paired)) {
            return paired;
          }
          return item;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${paired.name} emparejado correctamente.',
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() {
          _pairingAddress = null;
        });
      }
    }
  }

  // ==========================================
  // DETAILS
  // ==========================================


  Future<void> _showDetails(PrinterDevice device) async {
    if (_isSearching || _isLoading || _pairingAddress != null) return;

    debugPrint('[YapitaPrintersSection] DETAILS_REQUEST');

    try {
      final details = await _manager.getDetails(device);
      if (!mounted) return;

      bool printing = false;
      String selectedProtocol = 'CPCL';
      final textController = TextEditingController(text: 'Hola Yapitas');

      // ==========================================
      // GENERAR COMANDOS SEGÚN EL PROTOCOLO
      // ==========================================

      Uint8List buildPrintData(String protocol, String text) {
        // ASCII para las pruebas iniciales.
        final safeText = text
            .replaceAll(RegExp(r'[^\x20-\x7E]'), '?')
            .replaceAll('"', "'")
            .replaceAll('\r', ' ')
            .replaceAll('\n', ' ');

        switch (protocol) {
          case 'TSPL':
            final command = [
              'SIZE 50 mm,30 mm',
              'GAP 2 mm,0 mm',
              'DENSITY 10',
              'DIRECTION 1',
              'CLS',
              'BAR 20,20,300,100',
              'PRINT 1,1',
              '',
            ].join('\r\n');

            return Uint8List.fromList(ascii.encode(command));
          case 'CPCL':
            return CpclReceiptUtil.buildReceipt(
              profile: CpclPrinterProfile.model608L80D,
              receipt: CpclReceiptData(
                businessName: 'TRECE',
                businessCategory: 'COMIDA RAPIDA',
                address: 'Otavalo - Ecuador',
                phone: '099 999 9999',
                ticketNumber: '0001',
                issuedAt: DateTime.now(),
                items: const [
                  CpclReceiptItem(
                    code: '001',
                    name: 'Hamburguesa',
                    quantity: 2,
                    unitPriceCents: 350,
                  ),
                  CpclReceiptItem(
                    code: '002',
                    name: 'Papas fritas',
                    quantity: 1,
                    unitPriceCents: 200,
                  ),
                  CpclReceiptItem(
                    code: '003',
                    name: 'Hot dog',
                    quantity: 1,
                    unitPriceCents: 250,
                  ),
                  CpclReceiptItem(
                    code: '004',
                    name: 'Gaseosa',
                    quantity: 2,
                    unitPriceCents: 100,
                  ),
                ],
                amountPaidCents: 2000,
              ),
            );
          case 'ESC/POS':
            return Uint8List.fromList([
              0x1B, 0x40, // Inicializar
              0x1B, 0x61, 0x01, // Centrar
              ...ascii.encode(safeText),
              0x0A, 0x0A, 0x0A,
            ]);

          default:
            throw ArgumentError('Protocolo no soportado: $protocol');
        }
      }

      try {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (sheetContext) => StatefulBuilder(
            builder: (sheetContext, updateSheet) {
              // ==========================================
              // IMPRIMIR PRUEBA
              // ==========================================

              Future<void> printTest() async {
                if (printing) return;

                final text = textController.text.trim();

                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa un texto para imprimir.'),
                    ),
                  );
                  return;
                }

                updateSheet(() => printing = true);

                try {
                  final granted = await _requestBluetoothPermissions();

                  if (!granted) {
                    throw PlatformException(
                      code: 'PERMISSION_DENIED',
                      message: 'Falta permiso para conectar por Bluetooth',
                    );
                  }

                  final protocol = selectedProtocol;
                  final data = buildPrintData(protocol, text);

                  debugPrint(
                    '[YapitaPrintersSection] PRINT_TEST_REQUEST '
                        'protocol=$protocol bytes=${data.length}',
                  );

                  debugPrint(
                    '[YapitaPrintersSection] PRINT_TEXT=$text',
                  );

                  debugPrint(
                    '[YapitaPrintersSection] PRINT_HEX='
                        '${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
                  );

                  final success = await _printerChannel.invokeMethod<bool>(
                    'printTest',
                    {
                      'address': details.address,
                      'protocol': protocol,
                      'data': data,
                    },
                  );

                  debugPrint(
                    '[YapitaPrintersSection] PRINT_TEST_RESULT=$success',
                  );

                  if (!mounted || !sheetContext.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success == true
                            ? 'Datos $protocol enviados. Comprueba la impresión.'
                            : 'No se pudo completar el envío.',
                      ),
                    ),
                  );
                } catch (e, stack) {
                  debugPrint(
                    '[YapitaPrintersSection] PRINT_TEST_ERROR: $e',
                  );
                  debugPrintStack(stackTrace: stack);

                  if (mounted) _showError(e);
                } finally {
                  if (sheetContext.mounted) {
                    updateSheet(() => printing = false);
                  }
                }
              }

              // ==========================================
              // ELIMINAR EMPAREJAMIENTO
              // ==========================================

              Future<void> openForgetSettings() async {
                final confirmed = await showDialog<bool>(
                  context: sheetContext,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Eliminar emparejamiento'),
                    content: const Text(
                      'Android administra los dispositivos sincronizados. '
                          'Abre sus ajustes y pulsa Olvidar en la impresora.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: const Text('Abrir ajustes'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true || !sheetContext.mounted) return;

                debugPrint(
                  '[YapitaPrintersSection] OPEN_BLUETOOTH_SETTINGS_FOR_FORGET',
                );

                try {
                  await _printerChannel.invokeMethod(
                    'openBluetoothSettings',
                  );

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                } catch (e, stack) {
                  debugPrint(
                    '[YapitaPrintersSection] OPEN_SETTINGS_ERROR: $e',
                  );
                  debugPrintStack(stackTrace: stack);

                  if (mounted) _showError(e);
                }
              }

              final canPrint = details.bonded &&
                  details.bluetoothType == PrinterBluetoothType.classic;

              // ==========================================
              // INTERFAZ DE DETALLES
              // ==========================================

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Icon(
                            Icons.print,
                            size: 64,
                            color: Theme.of(sheetContext)
                                .colorScheme
                                .primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            details.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleLarge,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            details.bonded
                                ? 'Dispositivo sincronizado'
                                : 'Dispositivo no emparejado',
                          ),
                        ),

                        const Divider(height: 32),

                        _detailRow('Dirección', details.address),
                        _detailRow(
                          'Tipo',
                          _bluetoothTypeLabel(details.bluetoothType),
                        ),
                        _detailRow(
                          'Emparejado',
                          details.bonded ? 'Sí' : 'No',
                        ),
                        _detailRow(
                          'Conectado',
                          details.connected ? 'Sí' : 'No',
                        ),
                        _detailRow(
                          'Clase',
                          details.deviceClass?.toString() ??
                              'No disponible',
                        ),
                        _detailRow(
                          'RSSI',
                          details.rssi == null
                              ? 'No disponible'
                              : '${details.rssi} dBm',
                        ),
                        _detailRow(
                          'Última detección',
                          details.lastSeen?.toLocal().toString() ??
                              'Sin información',
                        ),

                        const SizedBox(height: 24),

                        // ==========================================
                        // SELECCIONAR PROTOCOLO
                        // ==========================================

                        Text(
                          'Protocolo de impresión',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          value: selectedProtocol,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.settings_input_component),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'TSPL',
                              child: Text('TSPL - Etiquetas'),
                            ),
                            DropdownMenuItem(
                              value: 'CPCL',
                              child: Text('CPCL - Etiquetas portátiles'),
                            ),
                            DropdownMenuItem(
                              value: 'ESC/POS',
                              child: Text('ESC/POS - Tickets'),
                            ),
                          ],
                          onChanged: printing
                              ? null
                              : (value) {
                            if (value != null) {
                              updateSheet(
                                    () => selectedProtocol = value,
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==========================================
                        // TEXTO PERSONALIZADO
                        // ==========================================

                        TextField(
                          controller: textController,
                          enabled: !printing,
                          maxLines: 2,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Texto de prueba',
                            hintText: 'Hola Yapitas',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          selectedProtocol == 'TSPL'
                              ? 'Prueba TSPL: etiqueta 50 × 30 mm, '
                              'separación de 2 mm.'
                              : selectedProtocol == 'CPCL'
                              ? 'Prueba CPCL: etiqueta aproximada '
                              'de 30 mm de alto a 203 DPI.'
                              : 'Prueba ESC/POS: texto simple '
                              'con avance de papel.',
                          style: Theme.of(sheetContext).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                            canPrint && !printing ? printTest : null,
                            icon: printing
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.receipt_long),
                            label: Text(
                              printing
                                  ? 'Enviando impresión...'
                                  : 'Imprimir prueba',
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: printing || !details.bonded
                                ? null
                                : openForgetSettings,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar emparejamiento'),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Prueba un protocolo a la vez y comprueba '
                              'si la impresora imprime correctamente. '
                              'El envío Bluetooth no garantiza que '
                              'el papel se haya impreso.',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } finally {
        textController.dispose();
      }
    } catch (e, stack) {
      debugPrint('[YapitaPrintersSection] DETAILS_ERROR: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) _showError(e);
    }
  }


  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
// ==========================================
// BLUETOOTH PERMISSIONS
// ==========================================

  // ==========================================
  // HELPERS
  // ==========================================

  bool _sameDevice(PrinterDevice a, PrinterDevice b) {
    return a.bluetoothType == b.bluetoothType &&
        a.address.trim().toUpperCase() ==
            b.address.trim().toUpperCase();
  }

  String _bluetoothTypeLabel(PrinterBluetoothType type) {
    switch (type) {
      case PrinterBluetoothType.classic:
        return 'Bluetooth Classic';
      case PrinterBluetoothType.ble:
        return 'Bluetooth BLE';
      case PrinterBluetoothType.unknown:
        return 'Desconocido';
    }
  }

  void _showError(Object error) {
    if (!mounted) return;

    String message = error.toString();

    if (error is PlatformException) {
      switch (error.code) {
        case 'PERMISSION_DENIED':
          message =
          'Faltan permisos Bluetooth. '
              'Autorízalos en los ajustes de Android.';
          break;
        case 'BLUETOOTH_BUSY':
          message =
          'Hay otra operación Bluetooth en curso.';
          break;
        case 'PAIR_TIMEOUT':
          message =
          'Se agotó el tiempo para emparejar.';
          break;
        default:
          message = error.message ?? error.code;
      }
    }

    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPrinterTabs(),
        Expanded(child: _buildPrinterContent()),
      ],
    );
  }

  Widget _buildPrinterTabs() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ToggleButtons(
          isSelected: [
            _selectedPrinterTab == 0,
            _selectedPrinterTab == 1,
            _selectedPrinterTab == 2,
          ],
          onPressed: (index) {
            setState(() {
              _selectedPrinterTab = index;
            });

            if (index == 1 && !_isSearching) {
              _loadInitial();
            }
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Buscar'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Emparejados'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Guardados'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterContent() {
    switch (_selectedPrinterTab) {
      case 0:
        return _buildSearchDevices();

      case 1:
        return _buildDeviceList(
          devices: _bondedDevices,
          emptyIcon: Icons.bluetooth_connected,
          emptyTitle: 'Sin dispositivos emparejados',
          emptyDescription:
          'Los dispositivos emparejados en Android '
              'aparecerán aquí.',
        );

      case 2:
        return _buildDeviceList(
          devices: _savedDevices,
          emptyIcon: Icons.print_outlined,
          emptyTitle: 'Sin dispositivos guardados',
          emptyDescription:
          'Busca y empareja dispositivos para '
              'registrarlos en este teléfono.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // SEARCH TAB
  // ==========================================

  Widget _buildSearchDevices() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSearching ||
                  _isLoading ||
                  _pairingAddress != null
                  ? null
                  : _searchDevices,
              icon: _isSearching
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.bluetooth_searching),
              label: Text(
                _isSearching
                    ? 'Buscando dispositivos...'
                    : 'Buscar dispositivos',
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildDeviceList(
            devices: _foundDevices,
            emptyIcon: Icons.bluetooth_searching,
            emptyTitle: _isSearching
                ? 'Buscando dispositivos'
                : 'Sin dispositivos encontrados',
            emptyDescription: _isSearching
                ? 'Espera mientras Android busca '
                'dispositivos cercanos.'
                : 'Activa tu impresora Bluetooth '
                'y pulsa Buscar dispositivos.',
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DEVICE LIST
  // ==========================================

  Widget _buildDeviceList({
    required List<PrinterDevice> devices,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyDescription,
  }) {
    if (_isLoading && devices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (devices.isEmpty) {
      return EmptyData(
        icon: emptyIcon,
        title: emptyTitle,
        descriptionText: emptyDescription,
        linkText: '',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      itemCount: devices.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildDeviceTile(devices[index]);
      },
    );
  }

  Widget _buildDeviceTile(PrinterDevice device) {
    final isPairing = _pairingAddress == device.address;
    final isBusy =
        _isSearching || _isLoading || _pairingAddress != null;
    final canPair =
        device.bluetoothType == PrinterBluetoothType.classic &&
            !device.bonded &&
            !isBusy;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(
            device.bonded
                ? Icons.bluetooth_connected
                : Icons.bluetooth,
          ),
        ),
        title: Text(
          device.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(device.address),
            const SizedBox(height: 4),
            Text(
              '${_bluetoothTypeLabel(device.bluetoothType)}'
                  ' · ${device.bonded ? "Emparejado" : "No emparejado"}',
            ),
          ],
        ),
        trailing: isPairing
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : PopupMenuButton<String>(
          enabled: !isBusy,
          tooltip: 'Opciones del dispositivo',
          onSelected: (action) {
            if (action == 'pair') {
              _pairDevice(device);
            } else if (action == 'details') {
              _showDetails(device);
            }
          },
          itemBuilder: (context) => [
            if (canPair)
              const PopupMenuItem(
                value: 'pair',
                child: Text('Emparejar'),
              ),
            const PopupMenuItem(
              value: 'details',
              child: Text('Ver detalles'),
            ),
          ],
        ),
      ),
    );
  }
}