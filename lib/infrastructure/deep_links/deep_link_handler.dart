import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic_app/shared/utils/deep_link_type.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;

  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialAppLink();
    } catch (e) {
      debugPrint('❌ Error obteniendo link inicial: $e');
      return null;
    }
  }

  DeepLinkInfo? parseUri(Uri uri, BuildContext context) {
    debugPrint("🔗 Link recibido: $uri");
    final info = DeepLinkUtils.fromUri(uri);
    if (info != null) {
      Fluttertoast.showToast(
        msg: "Redirigido desde: ${uri.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Enlace no válido o no soportado.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
    return info;
  }
}
