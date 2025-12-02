import 'package:geolocator/geolocator.dart';
import '../../../domain/models/result_model.dart';

class GeolocatorService {
  Future<ResultModel<void>> checkAndRequestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return ResultModel.error(
          message: 'GPS desactivado. Actívalo para continuar.',
          type: 'gps_disabled',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return ResultModel.error(
            message: 'Permiso de ubicación denegado.',
            type: 'permission_denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return ResultModel.error(
          message: 'Permiso bloqueado permanentemente.',
          type: 'permission_denied_forever',
        );
      }

      if (permission == LocationPermission.unableToDetermine) {
        return ResultModel.error(
          message: 'No se pudo determinar el estado del permiso.',
          type: 'permission_unknown',
        );
      }

      return ResultModel.success(message: 'Permiso concedido y GPS activo.');
    } catch (e) {
      return ResultModel.error(
        message: 'Error al verificar permisos: ${e.toString()}',
        type: 'exception',
      );
    }
  }
}
