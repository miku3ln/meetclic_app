import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic_app/aplication/services/access_manager_service.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/infrastructure/deep_links/deep_link_handler.dart';
import 'package:meetclic_app/presentation/controllers/menu_tab_up_controller.dart';
import 'package:meetclic_app/presentation/pages/ar_management_view/ar_management_view.dart';
import 'package:meetclic_app/presentation/pages/business_map_page.dart';
import 'package:meetclic_app/presentation/pages/dictionary_page.dart';
import 'package:meetclic_app/presentation/pages/home/home_infinity.dart';
import 'package:meetclic_app/presentation/pages/profile_page.dart';
import 'package:meetclic_app/presentation/pages/project_lake_page.dart';
import 'package:meetclic_app/presentation/pages/rive-example/vehicles_page.dart';
import 'package:meetclic_app/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic_app/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:meetclic_app/shared/utils/deep_link_type.dart';

import '../../../../shared/providers_session.dart';
import 'home_page.dart';

/// Identificador lógico de cada tab.
/// Así el deep link y la navegación NO dependen de índices.
enum HomeTabId { home, explore, shop, gaming, projects, dictionary, profile }

/// Definición de un tab: cómo se construye la pantalla,
/// cómo se ve el item del BottomNavigationBar y cuándo es visible.
class _HomeTabDefinition {
  final HomeTabId id;
  final Widget Function(SessionService session, List<MenuTabUpItem> menuItems)
  builder;
  final BottomNavigationBarItem Function(AppLocalizations l10n) navItemBuilder;
  final bool Function(SessionService session) isVisible;

  const _HomeTabDefinition({
    required this.id,
    required this.builder,
    required this.navItemBuilder,
    required this.isVisible,
  });
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  StreamSubscription<Uri>? _linkSubscription;

  /// En vez de guardar el índice, guardamos el tab lógico actual.
  HomeTabId _currentTab = HomeTabId.home;
  DeepLinkInfo? _pendingDeepLink;

  late AppConfig config;
  late AccessManagerService accessManager;

  /// Caché de widgets por tab para no reconstruirlos cada vez.
  final Map<HomeTabId, Widget> _tabCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDependencies();
      _setupListeners();
      _handleInitialLink();
    });
  }

  void _setupDependencies() {
    accessManager = AccessManagerService(context);
  }

  void _setupListeners() {
    _linkSubscription = _deepLinkHandler.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint('❌ Error en uriLinkStream: $err'),
    );
  }

  Future<void> _handleInitialLink() async {
    final initialUri = await _deepLinkHandler.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Link recibido: $uri");
    final info = _deepLinkHandler.parseUri(uri, context);
    if (info != null) {
      Fluttertoast.showToast(
        msg: "Redirigido desde: ${uri.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );

      if (info.type == DeepLinkType.businessDetails) {
        setState(() {
          _pendingDeepLink = info;
          _currentTab = HomeTabId.explore; // Tab del mapa
        });
      }
    } else {
      debugPrint("⚠️ DeepLink no reconocido: $uri");
      Fluttertoast.showToast(
        msg: "Enlace no válido o no soportado.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Construye el menú superior custom (no se toca tu lógica).
  List<MenuTabUpItem> _buildMenuItems(SessionService session) {
    config = Provider.of<AppConfig>(context, listen: false);
    return MenuTabUpController.buildMenu(
      context: context,
      config: config,
      session: session,
      setFlagCallback: setState,
    );
  }

  Widget _buildHomeContent(List<MenuTabUpItem> menuItems) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('pages.home'),
        items: menuItems,
      ),
      body: const HomeScrollView(),
    );
  }

  /// Definimos todos los tabs posibles.
  /// Si quieres customizar orden o agregar/quitar tabs, lo haces AQUÍ
  /// y automáticamente se refleja en pantallas + bottom nav.
  List<_HomeTabDefinition> _buildTabDefinitions(AppLocalizations l10n) {
    return [
      _HomeTabDefinition(
        id: HomeTabId.home,
        isVisible: (_) => true,
        builder: (session, menuItems) => _buildHomeContent(menuItems),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.translate('pages.home'),
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.explore,
        isVisible: (_) => true,
        builder: (session, menuItems) =>
            BusinessMapPage(info: _pendingDeepLink, itemsStatus: menuItems),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.language),
          label: l10n.translate('pages.explore'),
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.shop,
        isVisible: (_) => true,
        builder: (session, menuItems) => const ARManagementView(),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: l10n.translate('pages.shop'),
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.gaming,
        isVisible: (_) => true,
        builder: (session, menuItems) => VehiclesScreenPage(
          title: l10n.translate('pages.aboutUs'),
          itemsStatus: menuItems,
        ),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.emoji_events),
          label: l10n.translate('pages.gaming'),
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.projects,
        isVisible: (session) => session.isLoggedIn,
        builder: (session, menuItems) => ProjectLakePage(
          title: l10n.translate('pages.projects'),
          itemsStatus: menuItems,
        ),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.emoji_events),
          label: l10n.translate('pages.projects'),
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.dictionary,
        isVisible: (_) => true,
        builder: (session, menuItems) =>
            DictionaryPage(title: "Diccionario", itemsStatus: menuItems),
        navItemBuilder: (_) => const BottomNavigationBarItem(
          icon: Icon(Icons.dangerous),
          label: "Diccionario",
        ),
      ),
      _HomeTabDefinition(
        id: HomeTabId.profile,
        isVisible: (session) => session.isLoggedIn,
        builder: (session, menuItems) => ProfilePage(
          title: AppLocalizations.of(context).translate('pages.profile'),
          itemsStatus: menuItems,
          session: session, // 🔥 aquí ya pasas el SessionService
        ),
        navItemBuilder: (l10n) => BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.translate('pages.profile'),
        ),
      ),
    ];
  }

  /// Solo construye (o recupera del caché) el tab ACTUAL.
  Widget _buildCurrentTabWidget(
    SessionService session,
    List<MenuTabUpItem> menuItems,
    List<_HomeTabDefinition> visibleDefs,
  ) {
    // Buscar la definición del tab actual entre los visibles
    _HomeTabDefinition? currentDef = visibleDefs.firstWhere(
      (def) => def.id == _currentTab,
      orElse: () {
        // fallback: si por alguna razón no está, usamos el primero
        return visibleDefs.first;
      },
    );

    // Si por cambio de visibilidad el id cambio, actualizamos _currentTab
    if (currentDef.id != _currentTab) {
      _currentTab = currentDef.id;
    }

    // Usar caché: si ya se construyó antes, lo reutilizamos
    if (_tabCache.containsKey(currentDef.id)) {
      return _tabCache[currentDef.id]!;
    }

    // Construir por primera vez y guardar en caché
    final widget = currentDef.builder(session, menuItems);
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

        // Definiciones de todos los tabs según reglas de visibilidad
        final allDefs = _buildTabDefinitions(l10n);
        final visibleDefs = allDefs
            .where((def) => def.isVisible(session))
            .toList(growable: false);

        // Aseguramos que el tab actual siga existiendo;
        // si no, lo movemos al primero visible.
        if (!visibleDefs.any((def) => def.id == _currentTab)) {
          _currentTab = visibleDefs.first.id;
        }

        // 🔥 Solo se construye el widget del tab actual (lazy)
        final currentBody = _buildCurrentTabWidget(
          session,
          menuItems,
          visibleDefs,
        );

        final itemsMenu = visibleDefs
            .map((def) => def.navItemBuilder(l10n))
            .toList(growable: false);

        final currentIndex = visibleDefs.indexWhere((d) => d.id == _currentTab);

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
                _currentTab = visibleDefs[index].id;
              });
            },
            items: itemsMenu,
          ),
        );
      },
    );
  }
}
