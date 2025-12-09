// more_navigation.dart
import 'package:flutter/material.dart';

import '../../../../shared/localization/app_localizations.dart';
import '../../dictionary_page.dart';
import '../../projects_pages.dart';
import '../models/more_item_id.dart';

class MoreNavigation {
  // Punto ÚNICO para manejar taps según el id
  static void handleItemTap(BuildContext context, int itemId) {
    final process = MoreItemProcessId.fromValue(itemId);
    if (process == null) {
      debugPrint('⚠️ MoreNavigation: id desconocido: $itemId');
      return;
    }

    switch (process) {
      case MoreItemProcessId.addBusiness:
        _toAddBusiness(context);
        break;
      case MoreItemProcessId.exploreBusiness:
        _toExploreBusiness(context);
        break;
      case MoreItemProcessId.dictionary:
        _toDictionary(context);
        break;
      case MoreItemProcessId.eliteSquad:
        _toEliteProgram(context);
        break;
      case MoreItemProcessId.friendsCheckins:
        _toFriendsActivity(context);
        break;
      case MoreItemProcessId.chat:
        _toChat(context);
        break;
      case MoreItemProcessId.events:
        _toEvents(context);
        break;
      case MoreItemProcessId.settings:
        _toSettings(context);
        break;
      case MoreItemProcessId.helpCenter:
        _toHelpCenter(context);
        break;

      case MoreItemProcessId.arBusiness:
        _toHelpCenter(context);
        break;

      case MoreItemProcessId.projects:
        _toProjectsBusiness(context);
        break;

      case MoreItemProcessId.dictionaryCenter:
        _toDictionary(context);
        break;
    }
  }

  // ====== Rutas privadas ======

  static void _toAddBusiness(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text("Añadir negocio"))),
      ),
    );
  }

  static void _toExploreBusiness(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text("Explorar negocios"))),
      ),
    );
  }

  static void _toDictionary(BuildContext context) {
    final translationApi = AppLocalizations.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DictionaryPage(
          title: translationApi.translate('pages.dictionary'),
          itemsStatus: [],
        ),
      ),
    );
  }

  static void _toProjectsBusiness(BuildContext context) {
    final translationApi = AppLocalizations.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectsPages(
          title: translationApi.translate('pages.projects'),
          itemsStatus: [],
        ),
      ),
    );
  }

  static void _toEliteProgram(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Escuadra Elite MeetClic")),
        ),
      ),
    );
  }

  static void _toFriendsActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Actividad de mis amigos")),
        ),
      ),
    );
  }

  static void _toChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text("Conversaciones"))),
      ),
    );
  }

  static void _toEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text("Eventos"))),
      ),
    );
  }

  static void _toSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text("Ajustes"))),
      ),
    );
  }

  static void _toHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text("Centro de ayuda"))),
      ),
    );
  }
}
