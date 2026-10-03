import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PosSocketService {
  PosSocketService._();

  static final PosSocketService instance =
  PosSocketService._();

  WebSocketChannel? _channel;

  StreamSubscription? _channelSubscription;

  bool _isConnected = false;
  bool _isConnecting = false;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // ===========================================================================
  // EVENT STREAM
  // ===========================================================================

  final StreamController<Map<String, dynamic>> _eventController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events =>
      _eventController.stream;

  // ===========================================================================
  // CONNECT
  // ===========================================================================

  Future<bool> connect({
    required String url,
  }) async {
    if (_isConnected) {
      debugPrint('Socket already connected');

      return true;
    }

    if (_isConnecting) {
      debugPrint('Socket connection already in progress');

      return false;
    }

    _isConnecting = true;

    debugPrint('Connecting socket...');
    debugPrint('Socket URL: $url');

    try {
      final channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      _channel = channel;

      // web_socket_channel 2.4.0:
      // la conexión real se comprobará por el stream.
      _channelSubscription = channel.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _isConnecting = false;

      debugPrint('Socket connected: $url');

      return true;
    } catch (error) {
      _isConnected = false;
      _isConnecting = false;
      _channel = null;

      debugPrint(
        'Socket connection error: $error',
      );

      return false;
    }
  }

  // ===========================================================================
  // RECEIVE MESSAGE
  // ===========================================================================

  void _onMessage(dynamic message) {
    try {
      final decoded = jsonDecode(
        message.toString(),
      );

      if (decoded is! Map) {
        debugPrint(
          'Invalid socket payload: $decoded',
        );

        return;
      }

      final payload =
      Map<String, dynamic>.from(decoded);

      // Si recibimos información del servidor,
      // sabemos que la conexión está activa.
      _isConnected = true;
      _isConnecting = false;

      debugPrint(
        'Socket event received: $payload',
      );

      _eventController.add(
        payload,
      );

      final String? event =
      payload['event']?.toString();

      switch (event) {
        case 'invoice.created':
          _onInvoiceCreated(
            payload['data'],
          );
          break;

        case 'socket.connected':
          debugPrint(
            'Socket server connection confirmed',
          );
          break;

        default:
          debugPrint(
            'Unknown socket event: $event',
          );
      }
    } catch (error) {
      debugPrint(
        'Invalid socket message: $error',
      );
    }
  }

  // ===========================================================================
  // INVOICE CREATED
  // ===========================================================================

  void _onInvoiceCreated(dynamic data) {
    if (data is! Map) {
      return;
    }

    debugPrint('Invoice created');
    debugPrint('User: ${data['user_id']}');
    debugPrint('Date: ${data['date']}');
    debugPrint('Invoice: ${data['invoice_id']}');
  }

  // ===========================================================================
  // SEND
  // ===========================================================================

  bool send({
    required String event,
    required Map<String, dynamic> data,
  }) {
    debugPrint(
      'Socket send -> connected: $_isConnected',
    );

    debugPrint(
      'Socket send -> channel: ${_channel != null}',
    );

    if (!_isConnected || _channel == null) {
      debugPrint(
        'Socket is not connected',
      );

      return false;
    }

    try {
      final payload = {
        'event': event,
        'data': data,
      };

      final message = jsonEncode(
        payload,
      );

      _channel!.sink.add(
        message,
      );

      debugPrint(
        'Socket event sent: $message',
      );

      return true;
    } catch (error) {
      debugPrint(
        'Socket send error: $error',
      );

      return false;
    }
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  void _onError(Object error) {
    debugPrint(
      'Socket error: $error',
    );

    _isConnected = false;
    _isConnecting = false;
  }

  // ===========================================================================
  // DISCONNECTED
  // ===========================================================================

  void _onDone() {
    debugPrint(
      'Socket disconnected',
    );

    _isConnected = false;
    _isConnecting = false;

    _channel = null;
    _channelSubscription = null;
  }

  // ===========================================================================
  // DISCONNECT
  // ===========================================================================

  Future<void> disconnect() async {
    await _channelSubscription?.cancel();

    await _channel?.sink.close();

    _channelSubscription = null;
    _channel = null;

    _isConnected = false;
    _isConnecting = false;

    debugPrint(
      'Socket manually disconnected',
    );
  }
}