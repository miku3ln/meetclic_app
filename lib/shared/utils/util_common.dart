// lib/shared/utils/util_common.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilCommon {
  static Future<void> handleTap({
    required BuildContext context,
    required String type,
    required String text,
  }) async {
    Uri url;
    try {
      switch (type) {
        case 'whatsapp':
          final phone = text.replaceAll(RegExp(r'\s|\+'), '');
          const message = 'Hola, estoy interesado en tu empresa desde la app MeetClic 😊';
          final encoded = Uri.encodeComponent(message);

          // Intentar con la app de WhatsApp
          url = Uri.parse('whatsapp://send?phone=$phone&text=$encoded');

          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            // Fallback al navegador si no está instalada la app
            final fallbackUrl = Uri.parse('https://wa.me/$phone?text=$encoded');
            if (!await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication)) {
              _showError(context, 'No se pudo abrir WhatsApp.');
            }
          }
          return;

        case 'email':
          url = Uri.parse('mailto:$text');
          break;

        case 'web':
          url = Uri.parse(text.startsWith('http') ? text : 'https://$text');
          break;

        case 'map':
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(text)}');
          break;

        default:
          _showError(context, 'Tipo de enlace no reconocido.');
          return;
      }

      // Manejo general para email, web, mapa
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showError(context, 'No se pudo abrir el enlace.');
      }
    } catch (e) {
      debugPrint('Error en CommonLauncher: $e');
      _showError(context, 'Ocurrió un error inesperado.');
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  static final RegExp _ecuadorianCedulaRegex =
  RegExp(r'^(0[1-9]|1[0-9]|2[0-4])[0-6]\d{6}\d$');

  /// Valida si el número ingresado es una cédula ecuatoriana válida (solo por patrón)
  static bool isValidCedulaEcuatoriana(String cedula) {
    if (cedula.length != 10) return false;
    return _ecuadorianCedulaRegex.hasMatch(cedula);
  }
}
