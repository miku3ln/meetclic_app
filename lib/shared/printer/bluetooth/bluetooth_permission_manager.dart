import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centraliza la preparación para descubrir impresoras Bluetooth Classic.
/// No modifica la lógica de escaneo, caché ni emparejamiento existente.
class BluetoothPermissionManager {
  BluetoothPermissionManager._();

  static const MethodChannel _channel =
  MethodChannel('pos/printer_bluetooth_classic');

  static Future<Map<String, dynamic>> _status() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      'getBluetoothStatus',
    );
    return raw ?? <String, dynamic>{};
  }

  static bool _enabled(Map<String, dynamic> data, String key) =>
      data[key] == true;

  static Future<bool> _ask(
      BuildContext context, {
        required String title,
        required String message,
        required String action,
      }) async {
    if (!context.mounted) return false;
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
        false;
  }

  static Future<void> _notice(BuildContext context, String message) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Configuración pendiente'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// true: se puede iniciar el descubrimiento Classic.
  /// false: el usuario canceló o falta una condición.
  static Future<bool> ensureReadyForScan(BuildContext context) async {
    try {
      var state = await _status();
      final sdk = (state['sdk'] as num?)?.toInt() ?? 0;

      if (!_enabled(state, 'bluetoothAvailable')) {
        await _notice(context, 'Este teléfono no dispone de Bluetooth.');
        return false;
      }

      // Permisos del sistema: solo los necesarios para escanear.
      if (sdk >= 31) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();
        final granted = statuses.values.every((status) => status.isGranted);
        if (!granted) {
          final open = await _ask(
            context,
            title: 'Permiso de dispositivos cercanos',
            message: 'Permite el acceso a dispositivos cercanos para buscar impresoras.',
            action: 'Abrir permisos',
          );
          if (open) await openAppSettings();
          return false;
        }
      } else {
        final permission = await Permission.locationWhenInUse.request();
        if (!permission.isGranted) {
          final open = await _ask(
            context,
            title: 'Permiso de ubicación',
            message: 'Android 11 o anterior requiere el permiso de ubicación para descubrir dispositivos Bluetooth.',
            action: 'Abrir permisos',
          );
          if (open) await openAppSettings();
          return false;
        }
      }

      state = await _status();
      if (!_enabled(state, 'bluetoothEnabled')) {
        final open = await _ask(
          context,
          title: 'Activar Bluetooth',
          message: 'Enciende Bluetooth para encontrar impresoras cercanas. Regresa a Yapitas cuando lo actives.',
          action: 'Abrir Bluetooth',
        );
        if (open) await _channel.invokeMethod('openBluetoothSettings');
        return false; // El usuario puede pulsar Buscar al regresar.
      }

      // Android 10/11: el servicio de ubicación debe estar ENCENDIDO.
      if (sdk < 31 && !_enabled(state, 'locationEnabled')) {
        final open = await _ask(
          context,
          title: 'Activar ubicación',
          message: 'Android requiere que la ubicación del teléfono esté activada para buscar dispositivos Bluetooth. Yapitas no necesita guardar tu ubicación para esta búsqueda.',
          action: 'Abrir ubicación',
        );
        if (open) await _channel.invokeMethod('openLocationSettings');
        return false; // Reintentar al volver, sin asumir que se activó.
      }

      if (!_enabled(state, 'scanPermissionGranted') ||
          !_enabled(state, 'connectPermissionGranted')) {
        await _notice(context, 'Faltan permisos Bluetooth. Revisa los permisos de Yapitas en Ajustes.');
        return false;
      }

      return true;
    } on PlatformException catch (error) {
      await _notice(context, error.message ?? error.code);
      return false;
    } catch (error) {
      await _notice(context, 'No se pudo comprobar Bluetooth: $error');
      return false;
    }
  }
}
