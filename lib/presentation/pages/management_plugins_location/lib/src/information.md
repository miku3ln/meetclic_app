# Raíz del plugin
lib/
├── management_plugins_location.dart        # Barrel: exports públicos del plugin
└── src/
├── core/
│   └── errors/
│       └── failures.dart              # Tipos de errores (PermissionFailure, etc.)
│
├── domain/
│   ├── entities/
│   │   ├── device_location.dart       # Entidad DeviceLocation (lat, lon, alt, timestamp)
│   │   └── location_stream_config.dart# Config para stream de GPS (accuracy, distancia, intervalo)
│   │
│   ├── repositories/
│   │   └── device_sensors_repository.dart  # Interfaz DeviceSensorsRepository + enum LocationAccuracyLevel
│   │
│   └── usecases/
│       ├── check_location_service_enabled.dart  # UC: ¿GPS del dispositivo está ON?
│       ├── ensure_location_permission.dart      # UC: pide/verifica permiso de ubicación
│       ├── get_current_location.dart           # UC: obtiene una sola ubicación actual
│       ├── is_accelerometer_available.dart     # UC: verifica si existe acelerómetro
│       ├── accelerometer_stream.dart           # UC: stream acelerómetro (con gravedad)
│       ├── user_accelerometer_stream.dart      # UC: stream acelerómetro usuario (sin gravedad)
│       └── watch_location_stream.dart          # UC NUEVO: stream de ubicación en vivo (GPS)
│
├── data/
│   ├── services/
│   │   └── device_sensors_service.dart        # Implementa DeviceSensorsRepository usando:
│   │                                           # - geolocator (GPS)
│   │                                           # - permission_handler (permisos)
│   │                                           # - sensors_plus (acelerómetro)
│   │                                           # e implementa el stream de GPS robusto
│   │
│   └── repositories/
│       └── device_sensors_repository_impl.dart # Repo que delega todo a DeviceSensorsService
│
└── presentation/                               # (opcional si quieres poner widgets aquí)
# Por ahora la demo la tenemos fuera, en example/

# Ejemplo de uso en tu app / paquete
example/
└── location_demo_page.dart                 # LocationDemoPage: pantalla demo usando todo lo anterior
