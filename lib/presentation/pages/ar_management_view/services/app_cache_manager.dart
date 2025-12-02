import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache Manager propio para GLB/recursos 3D.
/// NOTA: En flutter_cache_manager v3, extiende de CacheManager (NO de BaseCacheManager).
class AppCacheManager extends CacheManager {
  static const key = 'app_glb_cache_v1';

  // Singleton
  static final AppCacheManager _instance = AppCacheManager._internal();
  factory AppCacheManager() => _instance;

  AppCacheManager._internal()
    : super(
        Config(
          key,
          // Periodo tras el cual un objeto se considera “viejo” y se revalida (ETag/Last-Modified)
          stalePeriod: const Duration(days: 7),
          // Número máximo (aprox.) de objetos en caché (no es tamaño en MB).
          // Ajusta según tu app; 400-800 suele ir bien para modelos/imagenes.
          maxNrOfCacheObjects: 600,
          // Si necesitas headers/tokens personalizados, puedes crear un FileService propio.
          fileService: HttpFileService(),
          // Si quisieras aislar DB: CacheObjectProvider(databaseName: key)
          // repo: CacheObjectProvider(databaseName: key),
        ),
      );
}
