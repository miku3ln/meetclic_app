import 'package:dio/dio.dart';

import 'download_models.dart';

class DownloadHelper {
  static const int _defaultDataUriMaxBytes = 8 * 1024 * 1024; // 8 MB

  // Memos en memoria
  static final Map<String, _MemoEntry> _dataMemo = {};
  static final Map<String, int> _lenMemo = {};

  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    Map<String, String>? headers,
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 60),
    int maxRetries = 1,
    int dataUriMaxBytes = _defaultDataUriMaxBytes,
    bool forceRefresh = false,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout, // Dio v5: Duration?
        receiveTimeout: receiveTimeout, // Dio v5: Duration?
        responseType: ResponseType.bytes,
        headers: headers,
        followRedirects: true,
        receiveDataWhenStatusError: true,
        // Evita que un 206 se considere error
        validateStatus: (code) => code != null && code >= 200 && code < 400,
      ),
    );

    // 1) Determinar tamaño total (HEAD -> Content-Length) o (Range -> Content-Range)
    int? contentLength;
    if (!forceRefresh && _lenMemo.containsKey(url)) {
      contentLength = _lenMemo[url];
    } else {
      contentLength = await _probeContentLength(dio, url);
      if (contentLength != null) _lenMemo[url] = contentLength!;
    }

    final canDataUri =
        (contentLength != null &&
        contentLength > 0 &&
        contentLength <= dataUriMaxBytes);

    // 2) Reusar data:URI memorizado
    if (!forceRefresh && canDataUri && _dataMemo.containsKey(url)) {
      final m = _dataMemo[url]!;
      onProgress?.call(m.contentLength, m.contentLength); // 100%
      return DownloadResult(
        success: true,
        data: m.dataUri,
        bytesReceived: m.contentLength,
        totalBytes: m.contentLength,
        extra: const {'isDataUri': true, 'source': 'mem'},
      );
    }

    // 3) Si es grande o no conocemos tamaño → que lo cargue directo el viewer (https)
    if (!canDataUri) {
      return DownloadResult(
        success: true,
        data: url,
        extra: const {'isDataUri': false, 'source': 'https'},
      );
    }

    // 4) Descargar con % y construir data:URI
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final res = await dio.get<List<int>>(
          url,
          onReceiveProgress: (r, t) => onProgress?.call(r, t),
          options: Options(responseType: ResponseType.bytes),
        );

        final status = res.statusCode ?? 0;
        final data = res.data;

        if (status == 200 && data != null) {
          final dataUri = Uri.dataFromBytes(
            data,
            mimeType: 'model/gltf-binary',
          ).toString();

          final len = contentLength ?? data.length;
          _dataMemo[url] = _MemoEntry(dataUri: dataUri, contentLength: len);

          return DownloadResult(
            success: true,
            data: dataUri,
            bytesReceived: data.length,
            totalBytes: len,
            extra: const {'isDataUri': true, 'source': 'mem/new'},
          );
        }
        return DownloadResult(success: false, message: 'HTTP $status');
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(success: false, message: e.toString());
        }
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }

    return const DownloadResult(success: false, message: 'Descarga cancelada.');
  }

  /// Intenta obtener el tamaño total del archivo:
  /// - HEAD -> Content-Length
  /// - si falla, GET Range bytes=0-0 -> Content-Range: bytes 0-0/<TOTAL>
  static Future<int?> _probeContentLength(Dio dio, String url) async {
    // 1) HEAD
    try {
      final head = await dio.head(url);
      final lenStr = head.headers.value('content-length');
      if (lenStr != null) {
        final val = int.tryParse(lenStr);
        if (val != null && val > 0) return val;
      }
    } catch (_) {
      // HEAD puede estar bloqueado por el CDN
    }

    // 2) GET Range 0-0 (requiere que el servidor soporte Accept-Ranges)
    try {
      final res = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'range': 'bytes=0-0'},
        ),
      );
      // Buscamos Content-Range: "bytes 0-0/12345"
      final cr = res.headers.value('content-range');
      if (cr != null) {
        final slash = cr.lastIndexOf('/');
        if (slash != -1 && slash + 1 < cr.length) {
          final totalStr = cr.substring(slash + 1).trim();
          final total = int.tryParse(totalStr);
          if (total != null && total > 0) return total;
        }
      }
      // Si por alguna razón devolvió 200 sin Content-Range, probamos Content-Length del GET
      final lenStr = res.headers.value('content-length');
      if (lenStr != null) {
        final val = int.tryParse(lenStr);
        if (val != null && val > 0) return val;
      }
    } catch (_) {
      // El servidor no soporta rango o CORS bloquea leer headers
    }

    // No hay manera fiable de obtener tamaño
    return null;
  }

  static void revokeIfNeeded(String? url) {
    /* noop */
  }
}

class _MemoEntry {
  final String dataUri;
  final int contentLength;
  const _MemoEntry({required this.dataUri, required this.contentLength});
}
