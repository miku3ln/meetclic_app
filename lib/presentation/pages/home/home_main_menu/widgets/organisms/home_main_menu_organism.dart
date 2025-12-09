// presentation/pages/home/home_main_menu/widgets/organisms/home_main_menu_organism.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic_app/aplication/services/access_manager_service.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/infrastructure/deep_links/deep_link_handler.dart';
import 'package:meetclic_app/presentation/controllers/menu_tab_up_controller.dart';
import 'package:meetclic_app/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import 'package:meetclic_app/shared/utils/deep_link_type.dart';

import '../../models/home_tab_definition.dart';
import '../../models/home_tab_id.dart';
import '../../services/home_deep_link_service.dart';
import '../../services/home_tab_factory.dart';
import '../../state/home_shell_state.dart';

/// Organism principal que representa la “cáscara” del Home:
/// - Maneja tabs
/// - Maneja deep links
/// - Renderiza el BottomNavigationBar
/// - Se conecta con el SessionService
class HomeMainMenuOrganism extends StatefulWidget {
  const HomeMainMenuOrganism({super.key});

  @override
  State<HomeMainMenuOrganism> createState() => _HomeMainMenuOrganismState();
}

class _HomeMainMenuOrganismState extends State<HomeMainMenuOrganism> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final HomeDeepLinkService _deepLinkService;
  StreamSubscription<Uri>? _linkSubscription;

  late final AccessManagerService _accessManager;
  late final AppConfig _config;

  /// Estado lógico del shell (tab actual + deep link pendiente).
  HomeShellState _state = HomeShellState.initial();

  /// Caché de widgets por tab para no reconstruirlos cada vez.
  final Map<HomeTabId, Widget> _tabCache = {};

  @override
  void initState() {
    super.initState();

    _deepLinkService = HomeDeepLinkService(DeepLinkHandler());

    // ✅ Inicializamos dependencias que usan context con listen:false
    _accessManager = AccessManagerService(context);
    _config = Provider.of<AppConfig>(context, listen: false);

    // Deep links se configuran después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDeepLinkListeners();
    });
  }

  Future<void> _setupDeepLinkListeners() async {
    // Escuchar deep links en caliente
    _linkSubscription = _deepLinkService.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint('❌ Error en uriLinkStream: $err'),
    );

    // Manejar el link inicial (si la app fue abierta desde un deep link)
    final initialUri = await _deepLinkService.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Link recibido: $uri");

    final info = _deepLinkService.parse(uri, context);
    if (info == null) {
      debugPrint("⚠️ DeepLink no reconocido: $uri");
      Fluttertoast.showToast(
        msg: "Enlace no válido o no soportado.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "Redirigido desde: ${uri.toString()}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );

    // Ejemplo: si el deep link apunta a detalle de negocio => tab Explore (mapa)
    if (info.type == DeepLinkType.businessDetails) {
      setState(() {
        _state = _state.copyWith(
          currentTab: HomeTabId.explore,
          pendingDeepLink: info,
        );
        // Invalidar caché del tab de mapa si quieres reconstruirlo
        _tabCache.remove(HomeTabId.explore);
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Construye el menú superior custom usando MenuTabUpController.
  List<MenuTabUpItem> _buildMenuItems(SessionService session) {
    return MenuTabUpController.buildMenu(
      context: context,
      config: _config,
      session: session,
      setFlagCallback: _onFlagChanged,
    );
  }

  /// Se llamará desde el modal de idioma
  void _onFlagChanged(VoidCallback fn) {
    setState(() {
      fn(); // lo que ya hacía antes (ej: actualizar lista, etc.)
      _tabCache.clear(); // 👈 MUY IMPORTANTE: forzar rebuild de todos los tabs
    });
  }

  /// Construye (o recupera desde caché) el widget del tab actual.
  Widget _buildCurrentTabWidget({
    required SessionService session,
    required List<MenuTabUpItem> menuItems,
    required List<HomeTabDefinition> visibleDefs,
    required AppLocalizations l10n,
  }) {
    // Buscar la definición del tab actual entre los visibles
    HomeTabDefinition currentDef = visibleDefs.firstWhere(
      (def) => def.id == _state.currentTab,
      orElse: () => visibleDefs.first,
    );

    // Si el tab actual ya no existe (por visibilidad, sesión, etc.), actualizamos el estado
    if (currentDef.id != _state.currentTab) {
      _state = _state.copyWith(currentTab: currentDef.id);
    }

    // Revisar si ya tenemos ese tab en caché
    if (_tabCache.containsKey(currentDef.id)) {
      return _tabCache[currentDef.id]!;
    }

    // Construir por primera vez
    final widget = currentDef.builder(
      session,
      menuItems,
      _state.pendingDeepLink,
      l10n,
    );

    _tabCache[currentDef.id] = widget;
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Consumer<SessionService>(
      builder: (context, session, _) {
        final menuItems = _buildMenuItems(session);

        // Definición de todos los tabs (con visibilidad).
        final allDefs = HomeTabFactory.buildTabs(context: context, l10n: l10n);

        final visibleDefs = allDefs
            .where((def) => def.isVisible(session))
            .toList(growable: false);

        // Aseguramos que el tab actual sea uno de los visibles
        if (!visibleDefs.any((def) => def.id == _state.currentTab)) {
          _state = _state.copyWith(currentTab: visibleDefs.first.id);
        }

        // Construir el body del tab actual
        final currentBody = _buildCurrentTabWidget(
          session: session,
          menuItems: menuItems,
          visibleDefs: visibleDefs,
          l10n: l10n,
        );

        // Items del BottomNavigationBar
        final itemsMenu = visibleDefs
            .map((def) => def.navItemBuilder(l10n))
            .toList(growable: false);

        final currentIndex = visibleDefs.indexWhere(
          (d) => d.id == _state.currentTab,
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: const HomeDrawerWidget(),
          body: currentBody,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.primary,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                _state = _state.copyWith(currentTab: visibleDefs[index].id);
              });
            },
            items: itemsMenu,
          ),
        );
      },
    );
  }
}
