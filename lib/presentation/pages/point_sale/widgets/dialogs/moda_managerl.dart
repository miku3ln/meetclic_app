import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../state/product_modal_controller.dart';

import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../molecules/inputs/ps_field_row.dart';
import '../molecules/inputs/ps_input.dart';
import '../sections/product/ps_section_card.dart';

class ModalManagerLayout extends StatelessWidget {
  final Widget? headerAction;

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
    this.headerAction, // 👈 IMPORTANTE (no required)
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

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// =========================
            /// HEADER
            /// =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// 🔙 BACK + TITLE
                Row(
                  children: [
                    if (showBack)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),

                    Text(title, style: AppTextStyles.title(context)),
                  ],
                ),

                /// 🔥 ACTIONS (CLAVE)
                Row(
                  children: [
                    if (headerAction != null) ...[
                      headerAction!,
                      const SizedBox(width: 8),
                    ],

                    IconButton(
                      icon: Icon(Icons.close, color: c.iconPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),

            AppSpacing.spaceBetweenSections,

            /// =========================
            /// BODY
            /// =========================
            Flexible(child: SingleChildScrollView(child: body)),

            AppSpacing.spaceBetweenSections,

            /// =========================
            /// FOOTER
            /// =========================
            if (viewActions)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(btnCancelTitle),
                  ),

                  const SizedBox(width: AppSpacing.s),

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
        ),
      ),
    );
  }
}

Future<void> showCustomerModal({
  required BuildContext context,
  required CustomerModalController controller,
  required PosTabletLandscapeController controllerMain,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return ModalManagerLayout(
          title: _getTitle(controller),
          showBack: controller.view != CustomerViewType.list,
          onBack: controller.back,
          headerAction: _buildHeaderAction(controller, controllerMain),
          body: _buildBody(context, controller, controllerMain),
          btnCancelTitle: "Cancelar",
          btnSaveTitle: controller.view == CustomerViewType.detail
              ? ""
              :  _getTitleButtons(controller),
          viewActions: controller.view == CustomerViewType.create||controller.view == CustomerViewType.update,
          onSave:
              controller.view == CustomerViewType.create && controller.canSubmit
              ? () {
                  if (controller.validate().success) {
                    controller.save();
                  }
                }
              : null,
        );
      },
    ),
  );
}

Widget _buildBody(
  BuildContext context,
  CustomerModalController controller,
  PosTabletLandscapeController controllerMain,
) {
  /// 🔥 LOADING GLOBAL
  if (controller.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  /// 🔥 ERROR
  if (controller.errorMessage != null) {
    return Center(child: Text(controller.errorMessage!));
  }

  switch (controller.view) {
    case CustomerViewType.list:
      return CustomerListView(controller);

    case CustomerViewType.create:
      return CustomerCreateView(controller);
    case CustomerViewType.update:
      return CustomerCreateView(controller);
    case CustomerViewType.detail:
      return CustomerDetailView(controller);


  }
}

Widget? _buildHeaderAction(
  CustomerModalController c,
  PosTabletLandscapeController controllerMain,
) {
  if (c.view != CustomerViewType.detail) return null;

  final customer = c.selectedCustomer;
  if (customer == null) return null;

  final isSelected = c.isCustomerSelected(customer);

  return TextButton(
    onPressed: () {
      c.toggleCustomerInTicket();
      controllerMain.setCustomerTicket(c.customerInTicket);
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
              _infoRow(Icons.email, c.email),
              _infoRow(Icons.phone, c.phone),
              _infoRow(Icons.location_on, c.city),
              _infoRow(Icons.badge, c.id),
            ],
          ),
        ),

        AppSpacing.spaceBetweenSections,

        PsSectionCard(
          title: "Actividad",
          child: Column(
            children: [
              _infoRow(Icons.star, "0.00 Puntos"),
              _infoRow(Icons.shopping_bag, "0 Visitas"),
              _infoRow(Icons.calendar_today, "Última visita: -"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
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
              PsInput(
                label: "Teléfono",
                value: controller.phone,
                onChanged: controller.setPhone,
              ),
              PsInput(
                label: "Ciudad",
                value: controller.city,
                onChanged: controller.setCity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomerListView extends StatelessWidget {
  final CustomerModalController controller;

  const CustomerListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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

        Column(
          children: controller.filteredCustomers.map((c) {
            final isSelected = controller.isCustomerSelected(c);

            return ListTile(
              tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,

              title: Text(c.name),
              subtitle: Text(c.email ?? ""),

              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,

              onTap: () => controller.goToDetail(c),
            );
          }).toList(),
        )
      ],
    );
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
}

class _CustomerTabs extends StatelessWidget {
  final CustomerModalController controller;

  const _CustomerTabs(this.controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tab("EDITAR PERFIL", CustomerDetailTab.profile),
        _tab("CANJEAR PUNTOS", CustomerDetailTab.redeem),
        _tab("VER COMPRAS", CustomerDetailTab.purchases),
      ],
    );
  }

  Widget _tab(String label, CustomerDetailTab tab) {
    final isActive = controller.detailTab == tab;

    return GestureDetector(
      onTap: () {
        if (tab == CustomerDetailTab.profile) {
          controller.goToEdit(); // 👈 CAMBIO IMPORTANTE
        } else {
          controller.setDetailTab(tab);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class CustomerService {
  Future<List<CustomerModelPosCurrent>> fetchCustomers() async {
    /// Simula delay de API
    await Future.delayed(const Duration(seconds: 2));

    /// Data mock (simulación backend)
    return [
      CustomerModelPosCurrent(
        id: "1",
        name: "Juan Pérez",
        email: "juan@mail.com",
        phone: "0999999999",
        city: "Quito",
      ),
      CustomerModelPosCurrent(
        id: "2",
        name: "María López",
        email: "maria@mail.com",
        phone: "0888888888",
        city: "Otavalo",
      ),
      CustomerModelPosCurrent(
        id: "3",
        name: "Carlos Andrade",
        email: "carlos@mail.com",
        phone: "0777777777",
        city: "Ibarra",
      ),
    ];
  }
}
