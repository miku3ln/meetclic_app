import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../widgets/empty_data.dart';
import '../../../utils/pos_socket_service.dart';

import '../../../../../../infrastructure/config/server_config.dart';

class PosSettingsCustomerScreenSection extends StatefulWidget {
  const PosSettingsCustomerScreenSection({super.key});

  @override
  State<PosSettingsCustomerScreenSection> createState() =>
      _PosSettingsCustomerScreenSectionState();
}

class _PosSettingsCustomerScreenSectionState
    extends State<PosSettingsCustomerScreenSection> {
  // ===========================================================================
  // SOCKET
  // ===========================================================================

  final List<Map<String, dynamic>> _socketEvents = [];

  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

  DateTime? _lastEventAt;

  bool _isConnecting = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _initializeSocket();
  }

  // ===========================================================================
  // INITIALIZE SOCKET
  // ===========================================================================

  Future<void> _initializeSocket() async {
    final socketService = PosSocketService.instance;

    _listenSocketEvents();

    if (socketService.isConnected) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }

      return;
    }

    if (mounted) {
      setState(() {
        _isConnecting = true;
      });
    }

    try {
      await socketService.connect(url: ServerConfig.socketUrl);
    } catch (error) {
      debugPrint('Customer screen socket connection error: $error');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
    });

    debugPrint('Socket URL: ${ServerConfig.socketUrl}');
  }

  // ===========================================================================
  // LISTEN SOCKET
  // ===========================================================================

  void _listenSocketEvents() {
    _socketSubscription?.cancel();

    _socketSubscription = PosSocketService.instance.events.listen(
      (event) {
        if (!mounted) {
          return;
        }

        final String eventName = event['event']?.toString() ?? 'unknown';

        debugPrint('Customer screen socket event: $event');

        setState(() {
          _lastEventAt = DateTime.now();

          _socketEvents.insert(0, event);
        });

        // No mostramos SnackBar para el evento inicial
        // de conexión.
        if (eventName != 'socket.connected') {
          _showEventNotification(eventName);
        }
      },
      onError: (error) {
        debugPrint('Customer screen socket error: $error');

        if (!mounted) {
          return;
        }

        setState(() {});
      },
    );
  }

  // ===========================================================================
  // EVENT NOTIFICATION
  // ===========================================================================

  void _showEventNotification(String eventName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Nuevo evento recibido: $eventName')),
            ],
          ),
        ),
      );
  }

  // ===========================================================================
  // RECONNECT
  // ===========================================================================

  Future<void> _reconnectSocket() async {
    if (_isConnecting) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    final socketService = PosSocketService.instance;

    try {
      await socketService.disconnect();

      await socketService.connect(url: ServerConfig.socketUrl);
    } catch (error) {
      debugPrint('Socket reconnect error: $error');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
    });
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _socketSubscription?.cancel();

    // NO desconectamos el singleton.
    // Puede ser utilizado por otras pantallas.

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSocketStatus(),

        Expanded(child: _socketEvents.isEmpty ? _buildEmpty() : _buildEvents()),
      ],
    );
  }

  // ===========================================================================
  // SOCKET STATUS
  // ===========================================================================

  Widget _buildSocketStatus() {
    final socketService = PosSocketService.instance;

    final bool connected = socketService.isConnected;

    final Color statusColor;

    final IconData statusIcon;

    final String statusTitle;

    final String statusDescription;

    if (_isConnecting) {
      statusColor = Colors.orange;
      statusIcon = Icons.sync_rounded;
      statusTitle = 'Conectando';

      statusDescription = 'Estableciendo conexión con el punto de venta.';
    } else if (connected) {
      statusColor = Colors.green;
      statusIcon = Icons.wifi_rounded;
      statusTitle = 'Conectado';

      statusDescription = 'Pantalla preparada para recibir información.';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.wifi_off_rounded;
      statusTitle = 'Sin conexión';

      statusDescription = 'No se están recibiendo eventos del punto de venta.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          // ===============================================================
          // STATUS ICON
          // ===============================================================
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: _isConnecting
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: statusColor,
                    ),
                  )
                : Icon(statusIcon, color: statusColor),
          ),

          const SizedBox(width: 12),

          // ===============================================================
          // INFORMATION
          // ===============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  statusDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                if (_lastEventAt != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Último evento: ${_formatTime(_lastEventAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ===============================================================
          // EVENTS COUNTER
          // ===============================================================
          if (_socketEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_socketEvents.length}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

          const SizedBox(width: 4),

          // ===============================================================
          // RECONNECT
          // ===============================================================
          if (!connected && !_isConnecting)
            IconButton(
              tooltip: 'Reconectar',
              onPressed: _reconnectSocket,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmpty() {
    final bool connected = PosSocketService.instance.isConnected;

    return EmptyData(
      icon: connected ? Icons.desktop_windows_rounded : Icons.wifi_off_rounded,
      title: connected ? 'Esperando información' : 'Sin conexión',
      descriptionText: connected
          ? 'La pantalla está conectada y esperando información desde el punto de venta.'
          : 'No existe conexión con el servicio del punto de venta.',
      linkText: connected ? 'Conexión activa' : 'Intentar nuevamente',
      onLinkTap: connected
          ? () {
              debugPrint('Socket activo: ${ServerConfig.socketUrl}');
            }
          : _reconnectSocket,
    );
  }

  // ===========================================================================
  // EVENTS
  // ===========================================================================

  Widget _buildEvents() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _socketEvents.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final event = _socketEvents[index];

        return _buildEventItem(event, index);
      },
    );
  }

  // ===========================================================================
  // EVENT ITEM
  // ===========================================================================

  Widget _buildEventItem(Map<String, dynamic> event, int index) {
    final String eventName = event['event']?.toString() ?? 'unknown';

    final dynamic data = event['data'];

    final bool isInvoice = eventName == 'invoice.created';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

        leading: CircleAvatar(
          child: Icon(
            isInvoice
                ? Icons.receipt_long_rounded
                : Icons.notifications_active_outlined,
          ),
        ),

        title: Text(
          _getEventTitle(eventName),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(_getEventDescription(eventName, data)),
        ),

        trailing: Text(
          '#${_socketEvents.length - index}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ===========================================================================
  // EVENT TITLE
  // ===========================================================================

  String _getEventTitle(String eventName) {
    switch (eventName) {
      case 'socket.connected':
        return 'Conexión establecida';

      case 'invoice.created':
        return 'Nueva venta';

      default:
        return eventName;
    }
  }

  // ===========================================================================
  // EVENT DESCRIPTION
  // ===========================================================================

  String _getEventDescription(String eventName, dynamic data) {
    if (eventName == 'socket.connected') {
      return 'El dispositivo se conectó correctamente al servicio.';
    }

    if (eventName == 'invoice.created' && data is Map) {
      final invoiceId = data['invoice_id'];

      final userId = data['user_id'];

      final total = data['total'];

      return 'Factura: ${invoiceId ?? '-'}'
          '\nUsuario: ${userId ?? '-'}'
          '${total != null ? '\nTotal: \$$total' : ''}';
    }

    return data?.toString() ?? 'Sin información';
  }

  // ===========================================================================
  // TIME
  // ===========================================================================

  String _formatTime(DateTime date) {
    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    final String second = date.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}
