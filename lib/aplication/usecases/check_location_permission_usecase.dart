import '../../../domain/models/result_model.dart';
import '../../infrastructure/services/geolocator_service.dart';

class CheckLocationPermissionUseCase {
  final GeolocatorService _geolocatorService;

  CheckLocationPermissionUseCase(this._geolocatorService);

  Future<ResultModel<void>> execute() async {
    return await _geolocatorService.checkAndRequestLocationPermission();
  }
}
