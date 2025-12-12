// presentation/pages/business_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/domain/usecases/get_nearby_businesses_usecase.dart';
import 'package:meetclic_app/infrastructure/repositories/implementations/business_repository_impl.dart';
import 'package:meetclic_app/presentation/pages/services/presentation_services_all.dart';
import 'package:meetclic_app/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../../../shared/utils/deep_link_type.dart';
import '../../aplication/usecases/check_location_permission_usecase.dart';
import '../../infrastructure/assets/app_images.dart';
import '../../infrastructure/services/geolocator_service.dart';
import '../../shared/language/language_modal_mixin.dart';
import '../../shared/models/app_config.dart';
import '../../shared/providers_session.dart';
import '../../shared/themes/app_colors.dart';
import 'business_detail_page.dart';
import 'business_map_page/helpers/business_marker_visual_resolver.dart';
import 'business_map_page/helpers/map_refresh_helper.dart';
import 'business_map_page/helpers/marker_helper.dart';
import 'business_map_page/models/business_position.dart';
import 'business_map_page/models/business_search_params.dart';
import 'business_map_page/models/search_location_info_model.dart';
import 'business_map_page/services/business_map_service.dart';
import 'business_map_page/services/geocoding_location_service.dart';
import 'business_map_page/services/manager_business.dart';
import 'business_map_page/state/business_filters_state.dart';
import 'business_map_page/state/business_map_state.dart';
import 'business_map_page/widgets/atoms/current_location_fab_atom.dart';
import 'business_map_page/widgets/atoms/loading_overlay_atom.dart';
import 'business_map_page/widgets/molecules/business_popup_card_molecule.dart';
import 'business_map_page/widgets/molecules/top_search_bar_molecule.dart';
import 'business_map_page/widgets/organisms/business_filters_bottom_sheet_organism.dart';

class BusinessMapPage extends StatefulWidget {
  final DeepLinkInfo? info;
  final List<MenuTabUpItem> itemsStatus;

  const BusinessMapPage({super.key, this.info, required this.itemsStatus});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage>
    with LanguageModalMixin {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;
  late final AppConfig config = Provider.of<AppConfig>(context, listen: false);

  /// Manager responsable de la posición “principal” del mapa
  late final ManagerBusiness manager = ManagerBusiness();

  /// Servicio de negocios cerca (capa de dominio/infra)
  late final BusinessMapService _businessMapService = BusinessMapService(
    useCase: GetNearbyBusinessesUseCase(repository: BusinessRepositoryImpl()),
  );
  late final GeocodingLocationService locationService =
      GeocodingLocationService();

  /// Helper para decidir cuándo refrescar en base a movimiento/zoom
  late final MapRefreshHelper _refreshHelper = MapRefreshHelper(
    minDistanceMeters: 400,
    minZoomDelta: 0.7,
  );

  /// Estado del mapa (negocios, markers, loading, etc.)
  BusinessMapState _state = BusinessMapState.initial();

  /// ✅ Estado de filtros PERSISTENTE en la página
  BusinessFiltersState _filtersState = BusinessFiltersState.initial();

  Map<String, dynamic> get currentPosition => manager.currentPositionAsMap;

  // ============================================================
  //   INIT / DISPOSE
  // ============================================================
  void _onSearchChanged(String value) {
    setState(() {
      _filtersState = _filtersState.copyWith(searchQuery: value);
    });
  }

  Future<void> _onSearchSubmit() async {
    // Reutilizamos el centro actual del manager
    final center = LatLng(
      manager.currentPosition.latitude,
      manager.currentPosition.longitude,
    );
    await _refreshFromCenter(center, zoom: manager.currentZoom);
  }

  Future<void> _openFilters() async {
    final updated = await showModalBottomSheet<BusinessFiltersState>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.6,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return BusinessFiltersBottomSheetOrganism(
            initialState: _filtersState,
          );
        },
      ),
    );

    if (updated != null) {
      setState(() {
        _filtersState = updated;
      });

      final center = LatLng(
        manager.currentPosition.latitude,
        manager.currentPosition.longitude,
      );
      await _refreshFromCenter(center, zoom: manager.currentZoom);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyBusinesses();
    });
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helpers para setear estado de forma limpia
  void _setLoading(bool value) {
    setState(() {
      _state = _state.copyWith(isLoading: value);
    });
  }

  void _setGpsEnabled(bool value) {
    setState(() {
      _state = _state.copyWith(isGpsEnabled: value);
    });
  }

  void _setBusinessData({
    required List<BusinessModel> businesses,
    required List<Marker> businessMarkers,
    required Marker currentLocationMarker,
  }) {
    setState(() {
      _state = _state.copyWith(
        businesses: businesses,
        businessMarkers: businessMarkers,
        currentLocationMarker: currentLocationMarker,
      );
    });
  }

  // ============================================================
  //   CORE / DATA
  // ============================================================

  /// Aplica data a:
  /// - manager (posición principal)
  /// - marker principal
  /// - lista de negocios + markers
  /// - cámara (opcional)
  void _applyBusinessData(
    LatLng center,
    List<BusinessModel> newBusinesses, {
    double? zoom,
    bool moveCamera = true,
  }) {
    manager.updateCurrentPosition(
      BusinessPosition(
        latitude: center.latitude,
        longitude: center.longitude,
        zoom: zoom ?? manager.currentZoom,
      ),
    );

    final currentMarker = MarkerHelper.buildCurrentLocationMarker(center);

    final businessMarkers = MarkerHelper.buildBusinessMarkers(
      businesses: newBusinesses,
      mapController: _mapController,
      popupController: _popupController,
      resolveVisual: BusinessMarkerVisualResolver.resolve,
    );

    if (moveCamera) {
      _mapController.move(center, zoom ?? manager.currentZoom);
    }

    _setBusinessData(
      businesses: newBusinesses,
      businessMarkers: businessMarkers,
      currentLocationMarker: currentMarker,
    );
  }

  /// Punto ÚNICO que:
  /// - Usa el centro dado
  /// - Llama a backend (servicio) con filtros actuales
  /// - Actualiza manager, markers y mapa
  Future<void> _refreshFromCenter(
    LatLng center, {
    double? zoom,
    bool moveCamera = false,
  }) async {
    // Guard anti-spam (scroll / zoom muy rápido)
    if (_state.isLoading) return;

    _setLoading(true);
    try {
      // 1) Primero obtenemos info de dirección de ese center
      final SearchLocationInfoModel locationInfo = await locationService
          .getLocationInfoFromCoordinates(center.latitude, center.longitude);
      // 2) Guardamos esa info en el estado
      setState(() {
        _state = _state.copyWith(currentLocationInfo: locationInfo);
      });

      setState(() {
        _filtersState = _filtersState.copyWith(
          currentLocationInfo: locationInfo,
        );
      });
      late final filters = BusinessSearchParams(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusKm: _filtersState.radiusKm,
        searchQuery: _filtersState.searchQuery,
        categoriesIds: _filtersState.categoriesIds,
        onlyWithGamesActive: _filtersState.onlyWithGamesActive,
        onlyWithRedeemableRewards: _filtersState.onlyWithRedeemableRewards,
        onlyAlliedCompanies: _filtersState.onlyAlliedCompanies,
      );

      final data = await _businessMapService.fetchBusinesses(filters);

      _applyBusinessData(center, data, zoom: zoom, moveCamera: moveCamera);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar negocios: $e')),
        );
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  // ============================================================
  //   CARGA INICIAL
  // ============================================================

  Future<void> _loadNearbyBusinesses() async {
    if (_state.isLoading) return;

    // ✅ SIEMPRE PARTIMOS DE LA POSICIÓN POR DEFECTO
    double latitude = currentPosition["latitude"];
    double longitude = currentPosition["longitude"];

    try {
      final useCaseCheckLocation = CheckLocationPermissionUseCase(
        GeolocatorService(),
      );

      final resultPermission = await useCaseCheckLocation.execute();
      _setGpsEnabled(resultPermission.success);

      if (!resultPermission.success) {
        // Avisamos, pero NO hacemos return (queremos usar el fallback)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resultPermission.message)));

        if (resultPermission.type == 'permission_denied_forever') {
          try {
            await Geolocator.openAppSettings();
          } catch (e) {
            debugPrint("No se pudo abrir configuración: $e");
          }
        }
        // 👇 IMPORTANTE: NO retornamos, seguimos con la lat/long por defecto
      }

      // Si tenemos permiso y servicios OK → intentamos obtener ubicación real
      if (_state.isGpsEnabled) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          latitude = position.latitude;
          longitude = position.longitude;
        } catch (_) {
          // Si falla, nos quedamos con la lat/long por defecto ya seteadas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener tu ubicación actual.'),
            ),
          );
        }
      }

      // ✅ SIEMPRE LLEGAMOS AQUÍ CON ALGÚN CENTER VÁLIDO
      final center = LatLng(latitude, longitude);
      await _refreshFromCenter(center, zoom: 16, moveCamera: true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar negocios: $e')));
    }
  }

  // ============================================================
  //   EVENTOS DEL MAPA (MOVE / ZOOM)
  // ============================================================

  /// Se llama cada vez que cambia la posición del mapa (move / zoom)
  /// `hasGesture` true = viene de interacción del usuario.
  void _onMapPositionChanged(MapPosition pos, bool hasGesture) async {
    if (!hasGesture) return; // solo cambios por usuario
    if (_state.isLoading) return;

    final center = pos.center;
    final zoom = pos.zoom;
    if (center == null || zoom == null) return;

    // 🔥 Aquí decidimos si realmente vale la pena refrescar
    if (!_refreshHelper.shouldRefresh(center, zoom)) {
      return;
    }

    await _refreshFromCenter(
      center,
      zoom: zoom,
      moveCamera: false, // ya está en esa posición
    );
  }

  // ============================================================
  //   MARCADORES COMBINADOS
  // ============================================================

  List<Marker> get _allMarkers {
    final list = [..._state.businessMarkers];
    if (_state.currentLocationMarker != null) {
      list.add(_state.currentLocationMarker!);
    }
    return list;
  }

  get currentLocationInfo => null;

  // ============================================================
  //   FAB: CENTRAR EN UBICACIÓN ACTUAL
  // ============================================================

  Future<void> _centerToCurrentLocation() async {
    if (_state.isLoading) return;

    final useCaseCheckLocation = CheckLocationPermissionUseCase(
      GeolocatorService(),
    );
    final resultPermission = await useCaseCheckLocation.execute();
    _setGpsEnabled(resultPermission.success);

    try {
      if (_state.isGpsEnabled) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final newCenter = LatLng(position.latitude, position.longitude);
        await _refreshFromCenter(newCenter, zoom: 16, moveCamera: true);
      } else {
        // Si no hay GPS, recentramos en el default y cargamos desde ahí
        final center = LatLng(
          currentPosition["latitude"],
          currentPosition["longitude"],
        );

        await _refreshFromCenter(center, zoom: 16, moveCamera: true);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación actual.'),
        ),
      );
    }
  }

  // ============================================================
  //   UI
  // ============================================================
  void _onSearch(String value) {
    print('Buscar definitivamente: $value');
    // aquí tu lógica real de búsqueda
  }

  void _onFlagChanged(VoidCallback fn) {
    setState(() {
      fn(); // lo que ya hacía antes (ej: actualizar lista, etc.)
    });
  }

  void onLanguage() {
    showLanguageModal(config: config, menuTabUpItems: []);
  }

  searchAppButtons(appConfig) {
    return SearchableHeaderAppBar(
      layoutBuilder: (ctx) {
        final String urlFlag = appConfig.getUrlFlag();
        // BOTONES NORMALES (modo normal)
        final normalActions = <HeaderActionItem>[
          HeaderActionItem(
            icon: Image.asset(urlFlag, width: 22, height: 22),
            onTap: onLanguage,
          ),
          HeaderActionItem(
            icon: Image.asset(
              AppImages.rewardTypeTrophy,
              width: 22,
              height: 22,
            ),
            onTap: () => print('gamificación'),
          ),
          HeaderActionItem(
            icon: Image.asset(AppImages.basketEcommerce, width: 24, height: 28),
            onTap: () => print('ventas'),
          ),
        ];

        const searchStyle = HeaderSearchVisualConfig(
          hintText: 'Buscar tareas',
          fieldHeight: 44,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          textStyle: TextStyle(fontSize: 16, color: AppColors.azulClic),
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          cursorColor: AppColors.azulClic,
          backIcon: Icons.arrow_back,
          backIconSize: 20,
          backIconColor: AppColors.azulClic,
          backIconPadding: EdgeInsets.only(right: 4),
        );

        if (ctx.isSearching) {
          // 👉 AQUÍ entra el layout 20/50/30 para búsqueda
          return buildSearchHeaderLayout20_50_302(
            ctx: ctx,
            searchActions: [],
            searchStyle: searchStyle,
            onChangedSearch: (v) => print('onChangedSearch $v'),
            onSubmittedSearch: (v) => print('onSubmittedSearch $v'),
          );
        }

        // 👉 modo normal: título + botones (20/50/30 clásico)
        return buildNormalHeaderLayout20_50_30(
          ctx: ctx,
          config: appConfig,
          rightActions: normalActions,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = AppLocalizations.of(
      context,
    ).translate('pages.business');
    final appConfig = Provider.of<AppConfig>(context);

    return Scaffold(
      appBar: searchAppButtons(appConfig),
      body: Stack(
        children: [
          // MAPA
          AbsorbPointer(
            absorbing: _state.isLoading,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(
                  manager.currentPosition.latitude,
                  manager.currentPosition.longitude,
                ),
                zoom: manager.currentZoom,
                onTap: (_, __) => _popupController.hideAllPopups(),
                onPositionChanged: _onMapPositionChanged,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.meetclic.meetclic',
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: _allMarkers,
                    popupController: _popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (context, marker) {
                        late BusinessModel business;
                        late int typeMarker = -1;
                        final markerKey = marker.key;
                        late final keyCurrent =
                            (markerKey as ValueKey<int>).value;
                        if (keyCurrent == -1) {
                          typeMarker = 0;
                          return const SizedBox.shrink(); // no muestra nada
                        } else {
                          typeMarker = 1;
                          business = _state.businesses.firstWhere(
                            (b) => b.id == keyCurrent,
                            orElse: () => _state.businesses.first,
                          );
                          return BusinessPopupCardMolecule(
                            business: business,
                            type: typeMarker,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BusinessDetailPage(
                                    businessId: business.id,
                                  ),
                                ),
                              );
                            },
                            verticalOffset:
                                40.0, // prueba 32–56 hasta que te guste
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔵 Barra superior de búsqueda + filtros
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: TopSearchBarMolecule(
              filtersState: _filtersState,
              onSearchChanged: _onSearchChanged,
              onSearchSubmit: _onSearchSubmit,
              onOpenFilters: _openFilters,
            ),
          ),

          // Overlay de carga
          LoadingOverlayAtom(
            isLoading: _state.isLoading,
            type: LoadingOverlayType.image,
          ),
        ],
      ),
      floatingActionButton: CurrentLocationFabAtom(
        isLoading: _state.isLoading,
        isGpsEnabled: _state.isGpsEnabled,
        onPressed: _centerToCurrentLocation,
      ),
    );
  }
}
