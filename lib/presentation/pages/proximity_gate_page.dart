/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../ar_capture_page.dart';
import '../../core/utils/geo_utils.dart';

class ProximityGatePage extends StatefulWidget {
  const ProximityGatePage({super.key});

  @override
  State<ProximityGatePage> createState() => _ProximityGatePageState();
}

class _ProximityGatePageState extends State<ProximityGatePage> {
  // Coordenadas objetivo (ejemplo)
  static const double targetLat = -0.349500;
  static const double targetLng = -78.122000;

  // Reglas de proximidad:
  // Usa SOLO UNA de las siguientes:
  // 1) Radio 10 m:
  // static const double allowedRadiusMeters = 10.0;
  // 2) Diámetro 10 m (=> radio 5 m):
  static const double allowedRadiusMeters = 5.0;

  Position? _me;
  double? _distance;
  StreamSubscription<Position>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    // Permisos de ubicación
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    _updatePosition(pos);

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen(_updatePosition);
  }

  void _updatePosition(Position pos) {
    final d = distanceMeters(pos.latitude, pos.longitude, targetLat, targetLng);
    setState(() {
      _me = pos;
      _distance = d;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canEnterAR = (_distance ?? 1e9) <= allowedRadiusMeters;

    return Scaffold(
      appBar: AppBar(title: const Text('Totem AR – Proximidad')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Objetivo: ($targetLat, $targetLng)'),
            const SizedBox(height: 8),
            if (_distance == null)
              const CircularProgressIndicator()
            else
              Text('Distancia: ${_distance!.toStringAsFixed(2)} m'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Abrir AR'),
              onPressed: canEnterAR
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ARCapturePage(
                          glbAssetPath: 'assets/totems/examples/HORNET.glb',
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            if (!canEnterAR)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Debes estar dentro del área permitida para invocar el tótem.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/