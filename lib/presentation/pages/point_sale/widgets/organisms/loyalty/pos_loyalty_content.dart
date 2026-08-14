import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_discounts_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_modifiers_management_section.dart';

import '../../../../../../shared/pagination_response.dart';

import 'dart:async';

import '../../../state/pos_loyalty_controller.dart';

import '../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../sections/loyalty/pos_cupons_management_section.dart';
import '../../sections/loyalty/pos_dashboard_management_section.dart';

class PosLoyaltyContent extends StatelessWidget {
  final PosLoyaltySection section;

  const PosLoyaltyContent({super.key,required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [Expanded(child: _buildSection(section))]),
    );
  }

  Widget _buildSection(PosLoyaltySection s) {
    switch (s) {
      case PosLoyaltySection.dashboard:
        return const PosDashboardManagementSection();
      case PosLoyaltySection.cupon:
        return const PosCuponsManagementSection();
      case PosLoyaltySection.gamification:
        return const PosModifiersManagementSection();
      case PosLoyaltySection.tracking:
        return const PosDiscountsManagementSection();

    }
  }
}

class FakeCuponsApi {
  final int total;

  const FakeCuponsApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final coupons = PosTabletLandscapeFixtures.getCouponsData();

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
      /// 🔥 aquí hacemos "loop" sobre los cupones reales
      final coupon = coupons[(start + index) % coupons.length];

      return GenericListItem<Map<String, dynamic>>(
        id: coupon.id, // evitar ids repetidos
        title: '${coupon.name}(${coupon.code})' ,
        subtitle: 'Código: ${coupon.code}',
        description: 'Descuento: ${coupon.discount}',
        image: 'https://meetclic.com/public//uploads/business/gamification/default/tinkuy-encuentro-08.jpg',
        businessId: '1',
        countData: coupon.discount.toInt(),
        data: {
          'productId': coupon.productId,
          'expiresAt': coupon.expiresAt?.toIso8601String(),
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

class FakeItemsApi {
  final int total;

  const FakeItemsApi({required this.total});

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
        title: 'Producto $itemNumber',
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
