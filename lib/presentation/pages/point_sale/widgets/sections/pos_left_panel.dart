import 'package:flutter/material.dart';
import '../molecules/pos_product_grid.dart';
import '../models/pos_product_item.dart';

class PosLeftPanel extends StatelessWidget {
  final bool isShiftOpen;

  /// ✅ evento: el panel pide abrir turno (el layout muestra modal)
  final VoidCallback onOpenShiftTap;

  /// productos visibles (ya filtrados por controller)
  final List<PosProductItem> products;
  final ValueChanged<PosProductItem> onProductTap;

  /// UI
  final int columns;

  const PosLeftPanel({
    super.key,
    required this.isShiftOpen,
    required this.onOpenShiftTap,
    required this.products,
    required this.onProductTap,
    this.columns = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ seguro si vive dentro de scroll
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isShiftOpen)
            _ShiftClosedView(onOpenTap: onOpenShiftTap)
          else
            PosProductGrid(
              products: products,
              columns: columns,
              onProductTap: onProductTap,
            ),
        ],
      ),
    );
  }
}

class _ShiftClosedView extends StatelessWidget {
  final VoidCallback onOpenTap;
  const _ShiftClosedView({required this.onOpenTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 72, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'El turno está cerrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Abra el turno para realizar ventas',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onOpenTap,
              child: const Text('ABRIR EL TURNO'),
            ),
          ],
        ),
      ),
    );
  }
}