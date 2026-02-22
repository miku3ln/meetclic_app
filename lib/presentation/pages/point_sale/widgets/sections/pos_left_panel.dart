import 'package:flutter/material.dart';
import '../dialogs/pos_open_shift_dialog.dart';

class PosLeftPanel extends StatelessWidget {
  final bool isShiftOpen;

  /// ✅ devuelve al padre el efectivo inicial (o null si canceló)
  final ValueChanged<double> onOpenShift;

  const PosLeftPanel({
    super.key,
    required this.isShiftOpen,
    required this.onOpenShift,
  });

  Future<void> _showOpenShiftDialog(BuildContext context) async {
    final amount = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PosOpenShiftDialog(),
    );

    if (amount != null) {
      onOpenShift(amount); // ✅ vuelve al principal
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isShiftOpen) {
      return _ShiftClosedView(
        onTapOpen: () => _showOpenShiftDialog(context),
      );
    }

    return const _ShiftOpenView();
  }
}

class _ShiftClosedView extends StatelessWidget {
  final VoidCallback onTapOpen;

  const _ShiftClosedView({required this.onTapOpen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 84),
              const SizedBox(height: 16),
              Text(
                'El turno está cerrado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Abra el turno para realizar ventas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 240,
                height: 44,
                child: ElevatedButton(
                  onPressed: onTapOpen,
                  child: const Text('ABRIR EL TURNO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftOpenView extends StatelessWidget {
  const _ShiftOpenView();

  @override
  Widget build(BuildContext context) {
    // ✅ luego aquí van categorías / productos (Grid/List)
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Aquí van Categorías / Productos'),
    );
  }
}