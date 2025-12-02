// download_helper.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'download_models.dart';

class DownloadHelper {
  // 🔹 Este valor ya no se usa para data:URI, pero lo dejamos por si luego quieres
  static const int _defaultDataUriMaxBytes = 8 * 1024 * 1024; // 8 MB

  /// Cache en memoria de archivos descargados: url -> entry
  static final Map<String, _FileCacheEntry> _fileCache = {};

  /// Cliente HTTP global para reutilizar conexiones (keep-alive)
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.bytes,
      followRedirects: true,
      receiveDataWhenStatusError: true,
    ),
  );

  /// Descarga un recurso binario (GLB) y lo guarda en archivo local (cache).
  ///
  /// - Primera vez para una URL:
  ///    → GET con progreso real
  ///    → guarda en /cache/ar_mdl_XXXX.glb
  ///    → devuelve la ruta del archivo local
  ///
  /// - Siguientes veces:
  ///    → si el archivo sigue existiendo, NO descarga
  ///    → reporta 100% al callback y devuelve la ruta local
  ///
  /// El parámetro [dataUriMaxBytes] se mantiene por compatibilidad,
  /// pero en esta versión siempre se usa archivo local, no data:URI.
  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    Map<String, String>? headers,
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 60),
    int maxRetries = 1,
    int dataUriMaxBytes =
        _defaultDataUriMaxBytes, // 👈 no se usa, pero se mantiene
    bool forceRefresh = false,
  }) async {
    // Actualizar opciones globales de Dio para esta llamada
    _dio.options.connectTimeout = connectTimeout;
    _dio.options.receiveTimeout = receiveTimeout;
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    // ===============================
    // 0) Si ya está en cache y no se fuerza refresh
    // ===============================
    if (!forceRefresh && _fileCache.containsKey(url)) {
      final entry = _fileCache[url]!;
      final file = File(entry.localPath);

      if (await file.exists()) {
        // Notificamos 100%
        onProgress?.call(entry.sizeBytes, entry.sizeBytes);

        return DownloadResult(
          success: true,
          data: entry.localPath, // 👈 ruta local del archivo
          bytesReceived: entry.sizeBytes,
          totalBytes: entry.sizeBytes,
          extra: const {'isFile': true, 'source': 'cache-file'},
        );
      } else {
        // Si el archivo desapareció del sistema, limpiamos cache en memoria
        _fileCache.remove(url);
      }
    }

    // ===============================
    // 1) Descarga real (GET con progreso)
    // ===============================
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        int? totalFromServer;

        final res = await _dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            // headers específicos por request (si quisieras sobreescribir)
            // headers: headers,
          ),
          onReceiveProgress: (received, total) {
            // Dio intenta leer Content-Length:
            //  - si total > 0 → tenemos tamaño real
            //  - si total <= 0 → el server no lo mandó
            if (total > 0) {
              totalFromServer = total;
              onProgress?.call(received, total);
            } else {
              // Sin tamaño conocido; reportamos lo recibido con total=0
              onProgress?.call(received, 0);
            }
          },
        );

        final status = res.statusCode ?? 0;
        final data = res.data;

        if (status != 200 || data == null) {
          return DownloadResult(
            success: false,
            message: 'HTTP $status',
            extra: const {'phase': 'get'},
          );
        }

        final bytes = data;
        final len = totalFromServer ?? bytes.length;

        // ===============================
        // 2) Guardar en archivo local (cache)
        // ===============================
        final dir = await getTemporaryDirectory();

        // Nombre determinista a partir de la URL (para reuso)
        final safeHash = url.hashCode;
        final filePath = '${dir.path}/ar_mdl_$safeHash.glb';

        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        final entry = _FileCacheEntry(
          url: url,
          localPath: filePath,
          sizeBytes: len,
          downloadedAt: DateTime.now(),
        );

        _fileCache[url] = entry;

        // Aseguramos 100% al final
        onProgress?.call(len, len);

        return DownloadResult(
          success: true,
          data: entry.localPath, // 👈 siempre ruta local
          bytesReceived: bytes.length,
          totalBytes: len,
          extra: const {'isFile': true, 'source': 'file/new'},
        );
      } on DioException catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(
            success: false,
            message: e.toString(),
            extra: {
              'phase': 'get',
              'dioType': e.type.toString(),
              if (e.response?.statusCode != null)
                'status': e.response!.statusCode,
            },
          );
        }
        // Pequeño backoff antes del reintento
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(
            success: false,
            message: e.toString(),
            extra: {'phase': 'get', 'errorType': e.runtimeType.toString()},
          );
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    return const DownloadResult(success: false, message: 'Descarga cancelada.');
  }

  /// Hook para, si más adelante quieres, borrar archivos de cache asociados.
  static void revokeIfNeeded(String? url) {
    // Por ahora noop
  }
}

class _FileCacheEntry {
  final String url;
  final String localPath;
  final int sizeBytes;
  final DateTime downloadedAt;

  _FileCacheEntry({
    required this.url,
    required this.localPath,
    required this.sizeBytes,
    required this.downloadedAt,
  });
}

enum ARLoadStatus { idle, loading, success, error }
/* =============================================================================
 * UI Helpers
 * ========================================================================== */

class UiHelpers {
  UiHelpers._();

  static void showSnack(
    BuildContext context,
    String msg, {
    bool error = false,
  }) {
    final sb = SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red[700] : Colors.black87,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  static Color statusColor(ARLoadStatus s) {
    switch (s) {
      case ARLoadStatus.loading:
        return Colors.amber[700]!;
      case ARLoadStatus.success:
        return Colors.green[700]!;
      case ARLoadStatus.error:
        return Colors.red[700]!;
      case ARLoadStatus.idle:
      default:
        return Colors.blueGrey[600]!;
    }
  }

  static String statusText(ARLoadStatus s) {
    switch (s) {
      case ARLoadStatus.loading:
        return 'Cargando…';
      case ARLoadStatus.success:
        return 'Listo';
      case ARLoadStatus.error:
        return 'Error';
      case ARLoadStatus.idle:
      default:
        return 'Listo';
    }
  }
}
