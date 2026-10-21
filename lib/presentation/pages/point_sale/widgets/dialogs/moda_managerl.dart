import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../state/product_modal_controller.dart';

import '../layouts/pos_main_controller.dart';
import '../molecules/inputs/ps_field_row.dart';
import '../molecules/inputs/ps_input.dart';
import '../organisms/items/pos_items_content.dart';
import '../sections/product/ps_section_card.dart';


class ModalManagerLayout extends StatelessWidget {
  final Widget? headerAction;
  final bool bodyScrollable;
  final String title;
  final Widget body;

  final VoidCallback? onSave;
  final String btnCancelTitle;
  final String btnSaveTitle;

  final bool showBack;
  final VoidCallback? onBack;
  final bool viewActions;

  const ModalManagerLayout({
    super.key,
    this.bodyScrollable = true,
    this.headerAction,
    required this.title,
    required this.body,
    required this.onSave,
    required this.btnCancelTitle,
    required this.btnSaveTitle,
    required this.showBack,
    required this.onBack,
    required this.viewActions,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);
    final media = MediaQuery.of(context);

    final isMobile = media.size.width < 600;

    return Dialog(
      // Ocupa toda el área disponible.
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.center,

      // Sin bordes redondeados en pantalla completa.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),

      clipBehavior: Clip.antiAlias,

      child: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
              isMobile ? 8 : AppSpacing.m,
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    if (showBack)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        onPressed: onBack,
                        visualDensity: VisualDensity.compact,
                      ),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title(context),
                      ),
                    ),

                    const SizedBox(width: 4),
                    if (headerAction != null)
                      Flexible(
                        fit: FlexFit.loose,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: headerAction!,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: c.iconPrimary,
                      ),
                      onPressed: () =>
                          closeCustomerModal(context),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                AppSpacing.spaceBetweenSections,
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: bodyScrollable
                        ? SingleChildScrollView(
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                      child: body,
                    )
                        : body,
                  ),
                ),

                if (viewActions) ...[
                  AppSpacing.spaceBetweenSections,

                  if (isMobile)
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: Text(
                              btnCancelTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: onSave == null
                                  ? c.disabled
                                  : c.secondary,
                            ),
                            child: Text(
                              btnSaveTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: Text(btnCancelTitle),
                        ),

                        SizedBox(width: AppSpacing.s),
                        ElevatedButton(
                          onPressed: onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onSave == null
                                ? c.disabled
                                : c.secondary,
                          ),
                          child: Text(btnSaveTitle),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void closeCustomerModal(BuildContext context) {
  if (!context.mounted) return;
  debugPrint('🔴 CUSTOMER MODAL: CERRANDO');
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(
    context,
    rootNavigator: true,
  ).pop();
}

Future<void> showCustomerModal({
  required BuildContext context,
  required CustomerModalController controller,
  required PosMainController controllerMain,
}) async {
  debugPrint('🟢 CUSTOMER MODAL: ABRIENDO');

  try {
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return ModalManagerLayout(
              title: _getTitle(controller),
              showBack: controller.view != CustomerViewType.list,
              onBack: controller.back,
              headerAction: _buildHeaderAction(
                controller,
                controllerMain,
                dialogContext,
              ),
              bodyScrollable: false,
              body: IndexedStack(
                index: controller.view == CustomerViewType.list ? 0 : 1,
                sizing: StackFit.expand,
                children: [
                  // LISTADO DE CLIENTES
                  CustomerListView(
                    controller,
                  ),
                  SingleChildScrollView(
                    child: _buildBody(
                      dialogContext,
                      controller,
                      controllerMain,
                    ),
                  ),
                ],
              ),
              btnCancelTitle: 'Cancelar',
              btnSaveTitle: controller.view == CustomerViewType.detail
                  ? ''
                  : _getTitleButtons(controller),
              viewActions:
              controller.view == CustomerViewType.create ||
                  controller.view == CustomerViewType.update,

              // =====================================
              // GUARDAR
              // =====================================
              onSave: controller.view == CustomerViewType.create &&
                  controller.canSubmit
                  ? () {
                if (controller.validate().success) {
                  controller.save();
                }
              }
                  : null,
            );
          },
        );
      },
    );
  } finally {
    debugPrint('🧹 CUSTOMER MODAL: CIERRE FINALIZADO');
  }
}
Widget _buildBody(
    BuildContext context,
    CustomerModalController controller,
    PosMainController controllerMain,
    ) {
  if (controller.view == CustomerViewType.list) {
    return const SizedBox.shrink();
  }

  if (controller.isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (controller.errorMessage != null) {
    return Center(
      child: Text(controller.errorMessage!),
    );
  }

  switch (controller.view) {
    case CustomerViewType.create:
    case CustomerViewType.update:
      return CustomerCreateView(controller);

    case CustomerViewType.detail:
      return CustomerDetailView(controller);

    case CustomerViewType.list:
      return const SizedBox.shrink();
  }
}

Widget? _buildHeaderAction(
  CustomerModalController c,
    PosMainController controllerMain,
    BuildContext context, // 👈 NECESARIO
) {
  if (c.view != CustomerViewType.detail) return null;

  final customer = c.selectedCustomer;
  if (customer == null) return null;

  final isSelected = c.isCustomerSelected(customer);

  return TextButton(
    onPressed: () {
      final wasSelected = c.isCustomerSelected(customer);

      c.toggleCustomerInTicket();
      controllerMain.setCustomerTicket(c.customerInTicket);

      /// 🔥 SOLO CIERRA SI AGREGA
      if (!wasSelected) {
        closeCustomerModal(context);
      }
    },
    child: Text(
      isSelected ? "Quitar del ticket" : "Agregar al ticket",
      style: TextStyle(
        color: isSelected ? Colors.red : Colors.green,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class CustomerDetailView extends StatelessWidget {
  final CustomerModalController controller;

  const CustomerDetailView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller.selectedCustomer;
    if (c == null) {
      return const Center(child: Text("No hay cliente seleccionado"));
    }

    final theme = AppThemeTokens.of(context);

    return Column(
      children: [
        /// 👤 HEADER PERFIL
        Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.border,
              child: const Icon(Icons.person, size: 30),
            ),
            const SizedBox(height: 8),
            Text(c.name, style: AppTextStyles.title(context)),
          ],
        ),

        AppSpacing.spaceBetweenSections,

        /// 🔥 TABS (CLAVE)
        _CustomerTabs(controller),

        AppSpacing.spaceBetweenSections,

        /// 🔥 CONTENIDO DINÁMICO
        _buildTabContent(context, controller, c),
      ],
    );
  }

  /// =========================
  /// CONTENT SWITCH
  /// =========================
  Widget _buildTabContent(
    BuildContext context,
    CustomerModalController controller,
    CustomerModelPosCurrent c,
  ) {
    switch (controller.detailTab) {
      case CustomerDetailTab.profile:
        return _buildProfile(c);

      case CustomerDetailTab.redeem:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Canjear puntos próximamente")),
          );
          controller.setDetailTab(CustomerDetailTab.profile);
        });
        return const SizedBox();

      case CustomerDetailTab.purchases:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ver compras próximamente")),
          );
          controller.setDetailTab(CustomerDetailTab.profile);
        });
        return const SizedBox();
    }
  }

  /// =========================
  /// PERFIL INFO
  /// =========================
  Widget _buildProfile(CustomerModelPosCurrent c) {
    return Column(
      children: [
        PsSectionCard(
          title: "Información",
          child: Column(
            children: [
              infoRow(Icons.email, c.email),
              infoRow(Icons.phone, c.phone),
              infoRow(Icons.location_on, c.city),
              infoRow(Icons.badge, c.id),
            ],
          ),
        ),

        AppSpacing.spaceBetweenSections,

        PsSectionCard(
          title: "Actividad",
          child: Column(
            children: [
              infoRow(Icons.star, "0.00 Puntos"),
              infoRow(Icons.shopping_bag, "0 Visitas"),
              infoRow(Icons.calendar_today, "Última visita: -"),
            ],
          ),
        ),
      ],
    );
  }


}

class CustomerCreateView extends StatelessWidget {
  final CustomerModalController controller;

  const CustomerCreateView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return PsSectionCard(
      title: "Información",
      child: Column(
        children: [
          PsInput(
            label: "Nombre",
            value: controller.name,
            onChanged: controller.setName,
            requiredField: true,
            isTouched: controller.nameTouched,
            error: controller.nameError,
            isValid: controller.nameError == null,
          ),

          AppSpacing.spaceBetweenInputs,

          PsInput(
            label: "Correo",
            value: controller.email,
            onChanged: controller.setEmail,
          ),

          AppSpacing.spaceBetweenInputs,
          PsFieldRow(
            children: [
              Expanded(
                child: PsInput(
                  label: "Teléfono",
                  value: controller.phone,
                  onChanged: controller.setPhone,

                ),
              ),

              const SizedBox(width: AppSpacing.s),

              Expanded(
                child: PsInput(
                  label: "Ciudad",
                  value: controller.city,
                  onChanged: controller.setCity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomerListView extends StatefulWidget {
  final CustomerModalController controller;


  const CustomerListView(
      this.controller, {
        super.key,

      });

  @override
  State<CustomerListView> createState() =>
      _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final ScrollController _scrollController = ScrollController();

  final List<CustomerModelPosCurrent> _items = [];
  final PosItemsManagementRepository _repository =
  PosItemsManagementRepository(total: 0);

  Timer? _searchDebounce;
  bool _isClosing = false;
  int _currentPage = 1;
  final int _rowCount = 10;
  int _total = 0;
  int _requestVersion = 0;

  String _searchCode = '';
  String? _errorMessage;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasInitialLoadFinished = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _searchCode = widget.controller.search;

    _scrollController.addListener(_onScroll);



      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadInitial();
        }
      });

  }

  // ============================================
  // INITIAL LOAD
  // ============================================

  Future<void> _loadInitial() async {
    if (_isLoading || _isLoadingMore) return;

    debugPrint('🟠 CUSTOMER LOAD INITIAL');

    await _loadPage(initial: true);
  }

  // ============================================
  // LOAD NEXT PAGE
  // ============================================

  Future<void> _loadMore() async {


    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _errorMessage != null) {
      return;
    }

    await _loadPage(initial: false);
  }
  Widget _buildOriginalCustomerList() {
    final controller = widget.controller;

    return ListView(
      children: [
        PsInput(
          label: "Buscar cliente",
          value: controller.search,
          onChanged: controller.setSearch,
        ),

        AppSpacing.spaceBetweenSections,

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: controller.goToCreate,
            child: const Text("AÑADIR CLIENTE NUEVO"),
          ),
        ),

        AppSpacing.spaceBetweenSections,

        ...controller.filteredCustomers.map((customer) {
          final isSelected =
          controller.isCustomerSelected(customer);

          return ListTile(
            tileColor: isSelected
                ? Colors.green.withOpacity(0.1)
                : null,
            title: Text(customer.name),
            subtitle: Text(customer.email ?? ""),
            trailing: isSelected
                ? const Icon(
              Icons.check,
              color: Colors.green,
            )
                : null,
            onTap: () => controller.goToDetail(customer),
          );
        }),
      ],
    );
  }
  // ============================================
  // FETCH PAGE
  // ============================================

  Future<void> _loadPage({required bool initial}) async {
    // =====================================
    // VALIDAR ESTADO DEL WIDGET
    // =====================================
    if (!mounted ||
        _isClosing ||
        _isLoading ||
        _isLoadingMore) {
      return;
    }

    final version = _requestVersion;
    final page = _currentPage;

    // =====================================
    // ACTIVAR ESTADO DE CARGA
    // =====================================
    setState(() {
      if (initial) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }

      _errorMessage = null;
    });

    try {
      // =====================================
      // CONSULTA DIRECTA AL REPOSITORIO
      // =====================================
      final response = await _repository.fetchCustomer(
        current: page,
        rowCount: _rowCount,
        searchPhrase: _searchCode,
      );

      // =====================================
      // VALIDAR RESPUESTA VIGENTE
      // =====================================
      if (!mounted ||
          _isClosing ||
          version != _requestVersion) {
        return;
      }

      // =====================================
      // MAPEAR CLIENTES
      // =====================================
      final existingIds = _items.map((e) => e.id).toSet();

      final newItems = <CustomerModelPosCurrent>[];

      for (final item in response.rows) {
        final data = item.data;

        if (data == null || data.isEmpty) {
          continue;
        }

        final customer = CustomerModelPosCurrent.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Evitar clientes duplicados.
        if (existingIds.add(customer.id)) {
          newItems.add(customer);
        }
      }

      // =====================================
      // VALIDAR ANTES DE ACTUALIZAR ESTADO
      // =====================================
      if (!mounted ||
          _isClosing ||
          version != _requestVersion) {
        return;
      }

      // =====================================
      // ACTUALIZAR PAGINACIÓN
      // =====================================
      setState(() {
        _items.addAll(newItems);

        _total = response.total;
        _currentPage = page + 1;

        _hasInitialLoadFinished = true;

        _hasMore =
            response.rows.isNotEmpty &&
                response.rows.length >= _rowCount &&
                page * _rowCount < _total;
      });

      debugPrint(
        '✅ CUSTOMER PAGE $page | '
            'LOADED ${_items.length} | '
            'TOTAL $_total | '
            'HAS MORE $_hasMore',
      );
    } catch (e, stackTrace) {
      // =====================================
      // IGNORAR ERRORES DE SOLICITUDES OBSOLETAS
      // =====================================
      if (!mounted ||
          _isClosing ||
          version != _requestVersion) {
        return;
      }

      setState(() {
        _errorMessage = e.toString();
        _hasInitialLoadFinished = true;
      });

      debugPrint('❌ CUSTOMER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // =====================================
      // FINALIZAR CARGA SI SIGUE VIGENTE
      // =====================================
      if (mounted &&
          !_isClosing &&
          version == _requestVersion) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });

        // =====================================
        // VERIFICAR SI HAY ESPACIO PARA MÁS CLIENTES
        // =====================================
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              _isClosing ||
              version != _requestVersion) {
            return;
          }

          _checkViewport();
        });
      }
    }
  }

  // ============================================
  // SCROLL LISTENER
  // ============================================

  void _onScroll() {
    // =====================================
    // VALIDAR ESTADO
    // =====================================
    if (!mounted || _isClosing) return;

    // =====================================
    // SOLO CARGAR EN LA VISTA DE LISTA
    // =====================================
    if (widget.controller.view != CustomerViewType.list) {
      return;
    }

    // =====================================
    // VALIDAR SCROLL
    // =====================================
    if (!_scrollController.hasClients) return;

    // =====================================
    // CARGAR SIGUIENTE PÁGINA
    // =====================================
    if (_scrollController.position.extentAfter <= 200) {
      _loadMore();
    }
  }

  void _checkViewport() {
    // =====================================
    // VALIDAR ESTADO
    // =====================================
    if (!mounted || _isClosing) return;

    // =====================================
    // SOLO EN LA VISTA DE LISTA
    // =====================================
    if (widget.controller.view != CustomerViewType.list) {
      return;
    }

    // =====================================
    // VALIDAR SCROLL
    // =====================================
    if (!_scrollController.hasClients) return;

    // =====================================
    // VALIDAR PAGINACIÓN
    // =====================================
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _errorMessage != null) {
      return;
    }

    // =====================================
    // CARGAR SI FALTA CONTENIDO
    // =====================================
    if (_scrollController.position.extentAfter <= 200) {
      _loadMore();
    }
  }

  // ============================================
  // SEARCH
  // ============================================

  void _onSearchChanged(String value) {
    // =====================================
    // VALIDAR ESTADO DEL WIDGET
    // =====================================
    if (!mounted || _isClosing) return;

    // =====================================
    // CANCELAR BÚSQUEDA ANTERIOR
    // =====================================
    _searchDebounce?.cancel();
    _searchDebounce = null;

    // =====================================
    // ACTUALIZAR CONTROLADOR
    // =====================================
    widget.controller.setSearch(value);

    // =====================================
    // ESPERAR ANTES DE CONSULTAR
    // =====================================
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
          () {
        if (!mounted || _isClosing) return;

        _resetAndLoad(value.trim());
      },
    );
  }

  void _resetAndLoad(String search) {
    // =====================================
    // VALIDAR ESTADO DEL WIDGET
    // =====================================
    if (!mounted || _isClosing) return;

    // =====================================
    // INVALIDAR SOLICITUDES ANTERIORES
    // =====================================
    _requestVersion++;

    // =====================================
    // REINICIAR ESTADO DE PAGINACIÓN
    // =====================================
    setState(() {
      // Nueva búsqueda
      _searchCode = search;

      // Reiniciar página
      _currentPage = 1;

      // Reiniciar total
      _total = 0;

      // Eliminar resultados anteriores
      _items.clear();

      // Reiniciar estados de carga
      _isLoading = false;
      _isLoadingMore = false;

      // Reiniciar paginación
      _hasMore = true;
      _hasInitialLoadFinished = false;

      // Limpiar errores anteriores
      _errorMessage = null;
    });

    // =====================================
    // REINICIAR POSICIÓN DEL SCROLL
    // =====================================
    if (mounted &&
        !_isClosing &&
        _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    // =====================================
    // CARGAR PRIMERA PÁGINA
    // =====================================
    if (!mounted || _isClosing) return;

    _loadInitial();
  }
  // ============================================
  // CUSTOMER LIST
  // ============================================

  Widget _buildCustomerList() {
    if (_isLoading && _items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar los clientes'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadInitial,
              child: const Text('REINTENTAR'),
            ),
          ],
        ),
      );
    }

    if (_hasInitialLoadFinished && _items.isEmpty) {
      return const Center(
        child: Text('No se encontraron clientes'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length +
          ((_isLoadingMore || _errorMessage != null) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          if (_errorMessage != null) {
            return Center(
              child: TextButton(
                onPressed: _loadMore,
                child: const Text('REINTENTAR CARGA'),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final customer = _items[index];

        final isSelected =
        widget.controller.isCustomerSelected(customer);

        return ListTile(
          tileColor: isSelected
              ? Colors.green.withOpacity(0.1)
              : null,
          leading: const CircleAvatar(
            child: Icon(Icons.person_outline),
          ),
          title: Text(
            customer.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            customer.phone?.isNotEmpty == true
                ? customer.phone!
                : customer.id,
          ),
          trailing: isSelected
              ? const Icon(
            Icons.check_circle,
            color: Colors.green,
          )
              : const Icon(Icons.chevron_right),
          onTap: () {
            widget.controller.goToDetail(customer);
          },
        );
      },
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {

   //   return _buildOriginalCustomerList();

    return Column(
      children: [
        PsInput(
          label: 'Buscar cliente',
          value: widget.controller.search,
          onChanged: _onSearchChanged,
        ),

        AppSpacing.spaceBetweenSections,

        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: widget.controller.goToCreate,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('AÑADIR CLIENTE NUEVO'),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_items.length} de $_total clientes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),

        Expanded(
          child: _buildCustomerList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    debugPrint('🧹 CUSTOMER LIST: iniciando limpieza');

    // Marcar el widget como cerrado.
    _isClosing = true;

    // Invalidar solicitudes pendientes.
    _requestVersion++;

    // Cancelar búsquedas programadas.
    _searchDebounce?.cancel();
    _searchDebounce = null;

    // Liberar controlador de scroll.
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Liberar datos temporales.
    _items.clear();

    debugPrint('🟢 CUSTOMER LIST: recursos liberados');

    super.dispose();
  }
}
String _getTitleButtons(CustomerModalController c) {
  switch (c.view) {
    case CustomerViewType.list:
      return "";
    case CustomerViewType.create:
      return "Guardar";
    case CustomerViewType.update:
      return "Actualizar ";
    case CustomerViewType.detail:
      return "Perfil";
  }
}
String _getTitle(CustomerModalController c) {
  switch (c.view) {
    case CustomerViewType.list:
      return "Añadir cliente al ticket";
    case CustomerViewType.create:
      return "Crear cliente";
    case CustomerViewType.update:
      return "Actualizar cliente";
    case CustomerViewType.detail:
      return "Perfil del cliente";
  }
}

class CustomerModelPosCurrent {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;

  CustomerModelPosCurrent({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
  });

  factory CustomerModelPosCurrent.fromJson(
      Map<String, dynamic> json,
      ) {
    String? optionalString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final firstName =
        optionalString(json['name']) ?? '';

    final lastName =
        optionalString(json['last_name']) ?? '';

    final fullName = '$firstName $lastName'.trim();

    return CustomerModelPosCurrent(
      id: json['id'].toString(),
      name: fullName,
      email: optionalString(json['email']),
      phone: optionalString(
        json['information_phone_value'] ?? json['phone'],
      ),
      address: optionalString(
        json['street_one'] ?? json['address'],
      ),
      city: optionalString(json['city']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
    };
  }
}

class _CustomerTabs extends StatelessWidget {
  final CustomerModalController controller;

  const _CustomerTabs(this.controller);


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;

        return Row(
          children: [
            Expanded(
              child: _tab(
                context,
                isMobile ? "EDITAR" : "EDITAR PERFIL",
                CustomerDetailTab.profile,
              ),
            ),

            Expanded(
              child: _tab(
                context,
                isMobile ? "CANJEAR" : "CANJEAR PUNTOS",
                CustomerDetailTab.redeem,
              ),
            ),

            Expanded(
              child: _tab(
                context,
                isMobile ? "COMPRAS" : "VER COMPRAS",
                CustomerDetailTab.purchases,
              ),
            ),
          ],
        );
      },
    );
  }


  // ============================================
  // CONSTRUIR TAB
  // ============================================
  Widget _tab(
      BuildContext context,
      String label,
      CustomerDetailTab tab,
      ) {
    final isActive = controller.detailTab == tab;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // =====================================
      // ACCIÓN DEL TAB
      // =====================================
      onTap: () {
        if (!context.mounted) return;

        switch (tab) {
        // =====================================
        // EDITAR PERFIL
        // =====================================
          case CustomerDetailTab.profile:
            controller.goToEdit();
            break;

        // =====================================
        // CANJEAR PUNTOS
        // =====================================
          case CustomerDetailTab.redeem:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    "Canjear puntos próximamente",
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            break;

        // =====================================
        // VER COMPRAS
        // =====================================
          case CustomerDetailTab.purchases:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    "Ver compras próximamente",
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            break;
        }
      },

      // =====================================
      // DISEÑO DEL TAB
      // =====================================
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 10,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

