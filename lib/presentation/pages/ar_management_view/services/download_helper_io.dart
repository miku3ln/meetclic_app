import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'app_cache_manager.dart';
import 'download_models.dart';

class DownloadHelper {
  // 🔸 Memo en memoria: URL → resultado exitoso (path local)
  static final Map<String, DownloadResult> _memo = {};

  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    Map<String, String>? headers,
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 15), // no-op aquí
    Duration receiveTimeout = const Duration(seconds: 60), // no-op aquí
    int maxRetries = 1,
    bool forceRefresh = false,
  }) async {
    // 0) Respuesta inmediata desde memo
    if (!forceRefresh && _memo.containsKey(url)) {
      final cached = _memo[url]!;
      final p = await _validateFilePath(cached.data);
      if (p != null) {
        // emite 100% para que el UI muestre “listo”
        onProgress?.call(1, 1);
        return cached;
      } else {
        _memo.remove(url); // limpiamos si el archivo ya no existe
      }
    }

    // 1) CacheManager (FS, con ETag)
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final stream = AppCacheManager().getFileStream(
          url,
          withProgress: true,
          headers: headers,
        );

        File? file;
        int lastR = 0, lastT = 0;

        await for (final resp in stream) {
          if (resp is DownloadProgress) {
            lastR = resp.downloaded;
            lastT = resp.totalSize ?? 0;
            onProgress?.call(lastR, lastT);
          } else if (resp is FileInfo) {
            file = resp.file;
          }
        }

        if (file != null && await file!.exists()) {
          final total = lastT > 0 ? lastT : await file!.length();
          final result = DownloadResult(
            success: true,
            data: file!.path,
            bytesReceived: total,
            totalBytes: total,
            extra: const {'isDataUri': false, 'source': 'fs'},
          );
          _memo[url] = result; // 🔸 guardamos para reuso instantáneo
          return result;
        }
        return const DownloadResult(
          success: false,
          message: 'No se pudo cachear recurso',
        );
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(success: false, message: e.toString());
        }
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }
    return const DownloadResult(success: false, message: 'Descarga cancelada.');
  }

  static Future<String?> _validateFilePath(String? path) async {
    if (path == null) return null;
    try {
      final f = File(path);
      if (await f.exists() && (await f.length()) > 0) return path;
    } catch (_) {}
    return null;
  }

  static void revokeIfNeeded(String? url) {
    /* noop en IO */
  }
}
