import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../infrastructure/config/server_config.dart';

// =================== Streaming Controller ===================
// Controla la grabación (record) y el envío por WebSocket (comentarios en español).
class AudioStreamingController {
  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _ws;
  StreamSubscription<Uint8List>? _micSub;

  bool get isStreaming => _micSub != null;

  Future<void> start({
    required String wsUrl,
    required void Function(int sentDelta) onSent,
    required void Function(AckStats ack) onAck,
    required void Function(String status) onStatus,
  }) async {
    // 1) Permisos de micrófono (comentarios en español)
    onStatus('checking-permissions');
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      onStatus('microphone-permission-denied');
      return;
    }

    // 2) Conexión WebSocket (comentarios en español)
    onStatus('connecting-ws');
    _ws = WebSocketChannel.connect(Uri.parse(wsUrl));
    _ws!.stream.listen(
      (event) {
        // Procesa ACKs del servidor (JSON) (comentarios en español)
        try {
          final map = jsonDecode(event as String) as Map<String, dynamic>;
          if (map['type'] == 'ack') {
            onAck(AckStats.fromJson(map));
          }
        } catch (_) {
          // Ignora otros mensajes (comentarios en español)
        }
      },
      onDone: () {
        onStatus('ws-closed');
      },
      onError: (e) {
        onStatus('ws-error: $e');
      },
    );

    // 3) Configurar stream de micrófono en PCM16 mono 16kHz (comentarios en español)
    onStatus('starting-mic-stream');
    final config = const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    final audioStream = await _recorder.startStream(config);

    // 4) Enviar cada chunk al servidor (comentarios en español)
    _micSub = audioStream.listen((Uint8List bytes) {
      _ws?.sink.add(bytes); // Envío binario
      onSent(bytes.length); // Reporte de bytes enviados
      onStatus('streaming'); // Estado informativo
    });
  }

  Future<void> stop({required void Function(String status) onStatus}) async {
    // Cancela stream, detiene micro y cierra WS (comentarios en español)
    await _micSub?.cancel();
    _micSub = null;
    await _recorder.stop();
    await _ws?.sink.close();
    _ws = null;
    onStatus('stopped');
  }

  Future<void> dispose() async {
    await _micSub?.cancel();
    await _recorder.dispose();
    await _ws?.sink.close();
  }
}

// ACK tipado (comentarios en español)
class AckStats {
  final int totalBytes;
  final int chunks;
  final DateTime receivedAt;
  final String textConvert;

  AckStats({
    required this.totalBytes,
    required this.chunks,
    required this.receivedAt,
    required this.textConvert,
  });

  factory AckStats.fromJson(Map<String, dynamic> json) {
    return AckStats(
      totalBytes: (json['totalBytes'] as num).toInt(),
      chunks: (json['chunks'] as num).toInt(),
      textConvert: json['textConvert'],
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }
}

// ======================= UI: StreamingPage =======================
// Un botón para iniciar/detener + indicadores básicos (comentarios en español).
class StreamingPage extends StatefulWidget {
  const StreamingPage({super.key});
  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  // Cambia la URL según tu entorno:
  // - Android Emulator: ws://10.0.2.2:3000/audio
  // - iOS Simulator:  ws://localhost:3000/audio
  // - Dispositivo real: ws://<TU_IP_LAN>:3000/audio
  static String wsUrl = ServerConfig.getSocketServer;
  final TextEditingController _textCtrl = TextEditingController(); // 👈 NUEVO

  final controller = AudioStreamingController();

  String status = 'idle';
  int sentBytes = 0;
  int ackBytes = 0;
  int chunks = 0;
  String text = '';
  Future<void> _toggle() async {
    if (!controller.isStreaming) {
      // Start
      await controller.start(
        wsUrl: wsUrl,
        onSent: (delta) => setState(() => sentBytes += delta),
        onAck: (ack) => setState(() {
          ackBytes = ack.totalBytes;
          chunks = ack.chunks;
          text = ack.textConvert;
        }),
        onStatus: (s) => setState(() => status = s),
      );
      setState(() {}); // Refresca el botón
    } else {
      // Stop
      await controller.stop(onStatus: (s) => setState(() => status = s));
      setState(() {}); // Refresca el botón
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose(); // 👈 importante
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = sentBytes == 0
        ? 0
        : (ackBytes / sentBytes).clamp(0, 1).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Audio → Node.js (ACK)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Status: $status'),
            ),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: Text('Sent bytes: $sentBytes'))]),
            Row(children: [Expanded(child: Text('ACK bytes:  $ackBytes'))]),
            Row(children: [Expanded(child: Text('Chunks:     $chunks'))]),
            Row(children: [Expanded(child: Text('Text:     $text'))]),

            const SizedBox(height: 8),
            LinearProgressIndicator(value: sentBytes == 0 ? null : progress),
            const Spacer(),
            ElevatedButton.icon(
              icon: Icon(controller.isStreaming ? Icons.stop : Icons.mic),
              label: Text(controller.isStreaming ? 'Stop' : 'Start streaming'),
              onPressed: _toggle,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
