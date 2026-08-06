import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/printer/printer_service.dart';
import '../../../state/pos_settings_controller.dart';
import '../../sections/settings/pos_settings_customer_screen_section.dart';
import '../../sections/settings/pos_settings_general_section.dart';
import '../../sections/settings/pos_settings_printers_section.dart';
import '../../sections/settings/pos_settings_taxes_section.dart';
import 'dart:async';

class PosSettingsContent extends StatelessWidget {
  const PosSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final section = context.watch<PosSettingsController>().section;
    return Container(
      color: Colors.white,
      child: Column(
        children: [Expanded(child: _buildSection(section, context))],
      ),
    );
  }

  Widget _buildSection(PosSettingsSection s, BuildContext context) {
    switch (s) {
      case PosSettingsSection.printers:
        final printerService = context.read<PrinterService>();

        return PosSettingsPrintersSection(printerService: printerService);

      case PosSettingsSection.customerScreen:
        return const PosSettingsCustomerScreenSection();
      case PosSettingsSection.taxes:
        return const PosSettingsTaxesSection();
      case PosSettingsSection.general:
        return const PosSettingsGeneralSection();
    }
  }
}

class FakePrintersApi {
  final int total;

  const FakePrintersApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final start = (current - 1) * rowCount;
    final end = (start + rowCount) > total ? total : (start + rowCount);

    if (start >= total) {
      return PaginatedResponse(
        current: current,
        rowCount: rowCount,
        rows: const [],
        total: total,
      );
    }

    final rows = List.generate(end - start, (index) {
      final itemNumber = start + index + 1;

      return GenericListItem<Map<String, dynamic>>(
        id: itemNumber,
        title: 'Impresora $itemNumber',
        subtitle: 'Estado: activa',
        description: 'Impresora de recibos y cocina #$itemNumber',
        image: null,
        data: {
          'id': itemNumber,
          'source': '/uploads/printers/default/printer-$itemNumber.png',
          'title': 'Impresora $itemNumber',
          'subtitle': 'Estado: activa',
          'description': 'Impresora simulada #$itemNumber',
          'state': 'ACTIVE',
          'business_name': 'MEETCLIC',
          'points': 40,
        },
      );
    });

    return PaginatedResponse(
      current: current,
      rowCount: rowCount,
      rows: rows,
      total: total,
    );
  }
}
