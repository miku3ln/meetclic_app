// Modelos y tipos compartidos para Web/IO.

typedef ProgressCb = void Function(int received, int total);

class DownloadResult {
  final bool success;
  final String? data; // IO: path local (file:// permitido), Web: blob:
  final String? message; // error/diagnóstico (opcional)
  final int? bytesReceived; // recibidos (opcional)
  final int? totalBytes; // total (opcional)
  final Map<String, dynamic>? extra; // flags extra, e.g. {'isBlob': true}

  const DownloadResult({
    required this.success,
    this.data,
    this.message,
    this.bytesReceived,
    this.totalBytes,
    this.extra,
  });
}
