
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
      final granted = await _requestBluetoothPermissions();

      if (!mounted || !granted) {
        if (mounted) {
          _showError(
            'Debes autorizar Bluetooth para buscar dispositivos.',
          );
        }
        return;
      }

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
    if (_isSearching || _isLoading || _pairingAddress != null) {
      return;
    }

    try {
      final details = await _manager.getDetails(device);

      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 16),
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
                    details.rssi != null
                        ? '${details.rssi} dBm'
                        : 'No disponible',
                  ),
                  _detailRow(
                    'Última detección',
                    details.lastSeen?.toLocal().toString() ??
                        'Sin información',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      _showError(e);
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
