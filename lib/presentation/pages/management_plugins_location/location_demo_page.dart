import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

// Ajusta estos imports a tu estructura real:
import 'lib/management_plugins_location.dart';
import 'lib/src/data/repositories/device_sensors_repository_impl.dart';

class LocationDemoPage extends StatefulWidget {
  const LocationDemoPage({super.key});
  @override
  State<LocationDemoPage> createState() => _LocationDemoPageState();
}

class _LocationDemoPageState extends State<LocationDemoPage>
    with WidgetsBindingObserver {
  // Repos / UseCases
  late final DeviceSensorsRepository _repo;
  late final GetCurrentLocation _getCurrentLocation;
  late final EnsureLocationPermission _ensurePerm;
  late final CheckLocationServiceEnabled _checkService;
  late final IsAccelerometerAvailable _checkAccel;
  late final AccelerometerStream _accStreamUC;
  late final UserAccelerometerStream _userAccStreamUC;
  late final WatchLocationStream _watchLocationStream;

  // Subscripciones
  StreamSubscription? _accSub, _userAccSub;
  StreamSubscription<geo.ServiceStatus>? _locServiceSub;
  StreamSubscription<DeviceLocation>? _locStreamSub;

  // Estado sensores
  String _status = 'Inicializando...';
  bool _gpsServiceEnabled = false;
  bool _gpsPermissionOk = false;
  bool _accelerometerAvailable = false;
  bool _accRunning = false;
  bool _listeningLocation = false;
  bool _promptingGps = false;

  // Últimos valores
  DeviceLocation? _locManual; // ← botón "Ubicación"
  DeviceLocation? _locStreamLast; // ← botón "Escuchar GPS" (stream)
  ({double x, double y, double z})? _lastAcc, _lastUserAcc;

  // Flag visual de cambio en stream
  bool _streamChanging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _repo = DeviceSensorsRepositoryImpl();
    _getCurrentLocation = GetCurrentLocation(_repo);
    _ensurePerm = EnsureLocationPermission(_repo);
    _checkService = CheckLocationServiceEnabled(_repo);
    _checkAccel = IsAccelerometerAvailable(_repo);
    _accStreamUC = AccelerometerStream(_repo);
    _userAccStreamUC = UserAccelerometerStream(_repo);
    _watchLocationStream = WatchLocationStream(_repo);

    _bootstrap();
    _listenLocationService();
  }

  // ------------------ Bootstrap / Listeners ------------------

  Future<void> _bootstrap() async {
    await _refreshGpsStates();
    await _refreshAccelState();
    _syncStatusText();

    if (!(_gpsServiceEnabled && _gpsPermissionOk)) {
      _autoPromptGps();
    }
  }

  void _listenLocationService() {
    _locServiceSub = geo.Geolocator.getServiceStatusStream().listen((
      status,
    ) async {
      final enabled = (status == geo.ServiceStatus.enabled);
      final permOk = await _ensurePerm();
      if (!mounted) return;
      setState(() {
        _gpsServiceEnabled = enabled;
        _gpsPermissionOk = permOk;
      });
      _syncStatusText();
      if (!(_gpsServiceEnabled && _gpsPermissionOk)) {
        _autoPromptGps();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshGpsStates() async {
    final serviceOn = await _checkService();
    final permOk = await _ensurePerm();
    if (!mounted) return;
    setState(() {
      _gpsServiceEnabled = serviceOn;
      _gpsPermissionOk = permOk;
    });
  }

  Future<void> _refreshAccelState() async {
    final avail = await _checkAccel();
    if (!mounted) return;
    setState(() => _accelerometerAvailable = avail);
  }

  void _syncStatusText() {
    setState(() {
      _status =
          'GPS ${_gpsServiceEnabled ? 'OK' : 'OFF'} • '
          'Permiso ${_gpsPermissionOk ? 'OK' : 'PEND'} • '
          'Acelerómetro ${_accelerometerAvailable ? 'OK' : 'N/D'}';
    });
  }

  // ------------------ Prompts / Permisos ------------------

  Future<void> _autoPromptGps() async {
    if (_promptingGps || !mounted) return;
    _promptingGps = true;

    final needsService = !_gpsServiceEnabled;
    final needsPerm = !_gpsPermissionOk;

    final action = await showDialog<_GpsAction>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Activar ubicación'),
          content: Text(
            [
              if (needsService)
                '• El servicio de ubicación (GPS) está APAGADO.',
              if (needsPerm) '• La app no tiene permiso de ubicación.',
              '¿Deseas activarlo ahora?',
            ].join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_GpsAction.cancel),
              child: const Text('Luego'),
            ),
            if (needsService)
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(_GpsAction.openLocationSettings),
                child: const Text('Abrir ajustes GPS'),
              ),
            if (!needsService && needsPerm)
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(_GpsAction.requestPermission),
                child: const Text('Pedir permiso'),
              ),
          ],
        );
      },
    );

    if (action == _GpsAction.openLocationSettings) {
      await _repo.openLocationSettings();
    } else if (action == _GpsAction.requestPermission) {
      await _ensurePerm();
      await _refreshGpsStates();
      _syncStatusText();
    }

    _promptingGps = false;
  }

  // ------------------ Acciones: Ubicación ------------------

  Future<void> _readLocation() async {
    if (!(_gpsServiceEnabled && _gpsPermissionOk)) {
      _autoPromptGps();
      return;
    }
    setState(() => _status = 'Obteniendo ubicación...');
    try {
      final loc = await _getCurrentLocation(
        timeout: const Duration(seconds: 8),
        accuracy: LocationAccuracyLevel.best,
      );
      setState(() {
        _locManual = loc; // ← guarda en variable manual
        _syncStatusText();
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  void _startLocationStream() {
    if (!(_gpsServiceEnabled && _gpsPermissionOk)) {
      _autoPromptGps();
      return;
    }

    // ⚠️ Para probar, pon filtros “agresivos” a cero: cada ~1s debería llegar algo
    final cfg = const LocationStreamConfig(
      accuracy: LocationAccuracyLevel.best,
      distanceFilterMeters: 0, // 0 = emite aunque casi no te muevas
      interval: Duration(seconds: 1), // Android: 1s
    );

    DeviceLocation? prev = _locStreamLast;

    _locStreamSub = _watchLocationStream(config: cfg).listen(
      (loc) {
        final changed = _meaningfulChange(prev, loc);
        prev = loc;

        setState(() {
          _locStreamLast = loc; // valor del “escuchar GPS”
          _streamChanging = changed; // chip “cambiando/estable”
        });
      },
      onError: (e) {
        _showSnack('Error stream GPS: $e');
        _stopLocationStream();
      },
    );

    setState(() => _listeningLocation = true);
  }

  Future<void> _stopLocationStream() async {
    await _locStreamSub?.cancel();
    _locStreamSub = null;
    setState(() {
      _listeningLocation = false;
      _streamChanging = false;
    });
  }

  // Cambios significativos: distancia horizontal > 2m o altitud > 0.5m
  bool _meaningfulChange(DeviceLocation? a, DeviceLocation b) {
    if (a == null) return true;
    final horiz = _haversineMeters(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    final dz = (b.altitude - a.altitude).abs();
    return horiz > 2.0 || dz > 0.5;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // m
    double d2r(double d) => d * pi / 180.0;
    final p1 = d2r(lat1), p2 = d2r(lat2);
    final dphi = d2r(lat2 - lat1);
    final dlam = d2r(lon2 - lon1);
    final a =
        sin(dphi / 2) * sin(dphi / 2) +
        cos(p1) * cos(p2) * sin(dlam / 2) * sin(dlam / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // ------------------ Acciones: Acelerómetro ------------------

  void _startAccelerometers() {
    if (!_accelerometerAvailable) {
      _showSnack('Acelerómetro no disponible en este dispositivo.');
      return;
    }
    _accSub = _accStreamUC().listen((a) => setState(() => _lastAcc = a));
    _userAccSub = _userAccStreamUC().listen(
      (ua) => setState(() => _lastUserAcc = ua),
    );
    setState(() => _accRunning = true);
  }

  Future<void> _stopAccelerometers() async {
    await _accSub?.cancel();
    await _userAccSub?.cancel();
    _accSub = _userAccSub = null;
    setState(() => _accRunning = false);
  }

  // ------------------ Helpers ------------------

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locServiceSub?.cancel();
    _locStreamSub?.cancel();
    _stopAccelerometers();
    super.dispose();
  }

  // ---------- UI Styles dinámicos ----------
  ButtonStyle _gpsActionStyle(bool gpsReady) => ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith(
      (_) => gpsReady ? Colors.green : Colors.red,
    ),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );

  ButtonStyle _locationBtnStyle(bool enabled) => ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) return Colors.grey.shade400;
      return Colors.green;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );

  ButtonStyle _accelerometerStyle({
    required bool available,
    required bool running,
  }) => ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (!available || states.contains(MaterialState.disabled)) {
        return Colors.grey.shade400;
      }
      return running ? Colors.orange : Colors.blue;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );

  ButtonStyle _listenGpsStyle({
    required bool listening,
    required bool gpsReady,
  }) => ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (!gpsReady || states.contains(MaterialState.disabled)) {
        return Colors.grey.shade400;
      }
      return listening ? Colors.deepPurple : Colors.indigo;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    final gpsReady = _gpsServiceEnabled && _gpsPermissionOk;
    final accelReady = _accelerometerAvailable;

    final acc = _lastAcc == null
        ? '-'
        : 'acc: ${_lastAcc!.x.toStringAsFixed(2)}, ${_lastAcc!.y.toStringAsFixed(2)}, ${_lastAcc!.z.toStringAsFixed(2)}';
    final uacc = _lastUserAcc == null
        ? '-'
        : 'userAcc: ${_lastUserAcc!.x.toStringAsFixed(2)}, ${_lastUserAcc!.y.toStringAsFixed(2)}, ${_lastUserAcc!.z.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Location & Accelerometer Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Estado: $_status'),

            const SizedBox(height: 16),
            Text(
              'Ubicación MANUAL (botón):',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_locManual == null ? '—' : _locManual.toString()),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Ubicación STREAM (escuchar):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_streamChanging ? 'cambiando' : 'estable'),
                  backgroundColor: _streamChanging
                      ? Colors.amber
                      : Colors.grey.shade300,
                ),
              ],
            ),
            Text(_locStreamLast == null ? '—' : _locStreamLast.toString()),

            const SizedBox(height: 16),
            Text(
              'Acelerómetro:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(acc),
            Text(uacc),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: _gpsActionStyle(gpsReady),
                  onPressed: _autoPromptGps,
                  icon: const Icon(Icons.location_on_outlined),
                  label: Text(
                    gpsReady ? 'GPS / Permiso OK' : 'Activar GPS / Permiso',
                  ),
                ),
                ElevatedButton(
                  style: _locationBtnStyle(gpsReady),
                  onPressed: gpsReady ? _readLocation : null,
                  child: const Text('Ubicación'),
                ),
                ElevatedButton(
                  style: _listenGpsStyle(
                    listening: _listeningLocation,
                    gpsReady: gpsReady,
                  ),
                  onPressed: gpsReady
                      ? (_listeningLocation
                            ? _stopLocationStream
                            : _startLocationStream)
                      : null,
                  child: Text(
                    _listeningLocation ? 'Detener escucha GPS' : 'Escuchar GPS',
                  ),
                ),
                ElevatedButton(
                  style: _accelerometerStyle(
                    available: accelReady,
                    running: _accRunning,
                  ),
                  onPressed: accelReady
                      ? (_accRunning
                            ? _stopAccelerometers
                            : _startAccelerometers)
                      : null,
                  child: Text(
                    _accRunning
                        ? 'Detener acelerómetro'
                        : 'Iniciar acelerómetro',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _GpsAction { cancel, openLocationSettings, requestPermission }
