import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/state/product_modal_controller.dart';
import '../repositories/config_repository.dart';
import '../shared/utils.dart';
import '../widgets/dialogs/moda_managerl.dart';
import '../widgets/dialogs/pos_draft_tickets_modal.dart';
import '../widgets/layouts/pos_main_controller.dart';

class PosUiState extends ChangeNotifier {
  final ValueNotifier<bool> isSummaryExpanded = ValueNotifier<bool>(false);

  VoidCallback? onRequestOpenDrawer;

  void toggleSummary() {
    isSummaryExpanded.value = !isSummaryExpanded.value;
  }

  void onMenuTap() {
    debugPrint('onMenuTap -> click');
    onRequestOpenDrawer?.call();
  }

  void onMoreTap(      BuildContext context,
      dynamic data,
      PosMainController controllerMain) {
    final result = 'onMoreTap -> click..${controllerMain.hasCustomerSelected}';
    final hasCustomer = controllerMain.hasCustomerSelected;
    debugPrint(result);
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 20, 0),
      items: [
        BuildItemIconMenu(
          icon: Icons.delete,
          text: 'Despejar el ticket',
          enabled: hasCustomer,
          value: 'clear',
        ),
        BuildItemIconMenu(
          icon: Icons.sync,
          text: 'Tickets Pendientes',
          enabled: true,
          value: 'ticketDraft',
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'clear':
          debugPrint('CLICK -> Despejar ticket');
          break;

        case 'ticketDraft':
          PosDraftTicketsModal.show(
            context,
            widthFactor: 0.95,
            heightFactor: 0.90,

            loadTickets: () async {
              return {
                'total': 5,
                'current': 1,
                'rowCount': 5,

                'rows': [
                  {
                    'header': {
                      'id': 14,
                      'customer_id': 1,
                      'invoice_code': '51',
                      'invoice_value': '0.0000',
                      'discount_value': '0.0000',
                      'status': 'DRAFT',
                      'user_id': 41,
                      'subtotal': '1.2500',
                      'value_taxes': '0.0000',
                      'invoice_date': '2026-10-06 20:40:10',
                      'debt': 1,
                      'customer_name': 'Admin',
                      'customer_last_name': 'Admin',
                      'employee_user_name': 'Liliana Mesa',
                    },
                    'meta': {
                      'ticket_code': 'TICKET-14',
                      'service_type': 'DINE_IN',
                    },
                    'payments': [],
                    'details': [
                      {
                        'id': 13,
                        'product_id': 1,
                        'code': '2',
                        'name': 'alex',
                        'quantity': '1.0000',
                        'unit_price': '1.2500',
                        'subtotal': '1.2500',
                        'total': '1.2500',
                        'tax_percentage': 0,
                        'product_type': 'UNIT',
                      },
                    ],
                  },

                  {
                    'header': {
                      'id': 13,
                      'customer_id': 1,
                      'invoice_code': '50',
                      'invoice_value': '0.0000',
                      'discount_value': '0.0000',
                      'status': 'DRAFT',
                      'subtotal': '1.2500',
                      'value_taxes': '0.0000',
                      'invoice_date': '2026-10-06 20:38:39',
                      'debt': 1,
                      'customer_name': 'Admin',
                      'customer_last_name': 'Admin',
                      'employee_user_name': 'Liliana Mesa',
                    },
                    'meta': {
                      'ticket_code': 'TICKET-13',
                      'service_type': 'DINE_IN',
                    },
                    'payments': [],
                    'details': [
                      {
                        'id': 12,
                        'product_id': 1,
                        'name': 'alex',
                        'quantity': '1.0000',
                        'unit_price': '1.2500',
                        'subtotal': '1.2500',
                        'total': '1.2500',
                      },
                    ],
                  },

                  {
                    'header': {
                      'id': 12,
                      'customer_id': 1,
                      'invoice_code': '49',
                      'invoice_value': '0.0000',
                      'discount_value': '0.0000',
                      'status': 'DRAFT',
                      'subtotal': '1.2500',
                      'value_taxes': '0.0000',
                      'invoice_date': '2026-10-06 20:37:49',
                      'debt': 1,
                      'customer_name': 'Admin',
                      'customer_last_name': 'Admin',
                      'employee_user_name': 'Liliana Mesa',
                    },
                    'meta': {
                      'ticket_code': 'TICKET-12',
                      'service_type': 'DINE_IN',
                    },
                    'payments': [],
                    'details': [
                      {
                        'id': 11,
                        'product_id': 1,
                        'name': 'alex',
                        'quantity': '1.0000',
                        'unit_price': '1.2500',
                        'subtotal': '1.2500',
                        'total': '1.2500',
                      },
                    ],
                  },

                  {
                    'header': {
                      'id': 15,
                      'customer_id': 1,
                      'invoice_code': '52',
                      'invoice_value': '0.0000',
                      'discount_value': '0.0000',
                      'status': 'PENDING',
                      'subtotal': '2.5000',
                      'value_taxes': '0.0000',
                      'invoice_date': '2026-10-06 20:45:40',
                      'debt': 0,
                      'customer_name': 'Admin',
                      'customer_last_name': 'Admin',
                      'employee_user_name': 'Liliana Mesa',
                    },
                    'meta': {
                      'ticket_code': 'TICKET-15',
                      'service_type': 'DINE_IN',
                    },
                    'payments': [
                      {
                        'type_payment_id': 1,
                        'amount': '2.50',
                      },
                    ],
                    'details': [
                      {
                        'id': 14,
                        'product_id': 1,
                        'name': 'alex',
                        'quantity': '2.0000',
                        'unit_price': '1.2500',
                        'subtotal': '2.5000',
                        'total': '2.5000',
                      },
                    ],
                  },

                  {
                    'header': {
                      'id': 19,
                      'customer_id': 1,
                      'invoice_code': '56',
                      'invoice_value': '0.0000',
                      'discount_value': '0.0000',
                      'status': 'PENDING',
                      'subtotal': '1.2500',
                      'value_taxes': '0.0000',
                      'invoice_date': '2026-10-06 21:10:31',
                      'debt': 0,
                      'customer_name': 'Admin',
                      'customer_last_name': 'Admin',
                      'employee_user_name': 'Liliana Mesa',
                    },
                    'meta': {
                      'ticket_code': 'TICKET-19',
                      'service_type': 'DINE_IN',
                    },
                    'payments': [
                      {
                        'type_payment_id': 1,
                        'amount': '1.25',
                      },
                    ],
                    'details': [
                      {
                        'id': 18,
                        'product_id': 1,
                        'name': 'alex',
                        'quantity': '1.0000',
                        'unit_price': '1.2500',
                        'subtotal': '1.2500',
                        'total': '1.2500',
                      },
                    ],
                  },
                ],
              };
            },

            onCollect: (ticket) async {
              final header = Map<String, dynamic>.from(
                ticket['header'],
              );

              final invoiceSaleId = header['id'];

              debugPrint('COBRAR TICKET ID: $invoiceSaleId');
              debugPrint('TICKET: $ticket');
            },
          );
          break;
      }
    });
  }

  void onUserTap(
      BuildContext context,
      dynamic data,
      PosMainController controllerMain,
      ) async {//PROCESS-INIT

    final service = CustomerServiceModal();
    final controller = CustomerModalController(service);

    /// 🔥 DECIDES TODO AQUÍ (no en UI)
    if (controllerMain.hasCustomerSelected) {
      controller.initWithCustomer(controllerMain.selectedCustomer!);
    } else {
      controller.initLoadData(); // sin await → loading

    }

    await showCustomerModal(
      controllerMain: controllerMain,
      context: context,
      controller: controller,
    );
  }
}
