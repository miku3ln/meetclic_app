import 'package:flutter/material.dart';
import '../layouts/pos_main_controller.dart';

class PosOpenShiftDialog extends StatefulWidget {
  final PosMainController controller;

  const PosOpenShiftDialog({
    super.key,
    required this.controller,
  });

  @override
  State<PosOpenShiftDialog> createState() => _PosOpenShiftDialogState();
}

class _PosOpenShiftDialogState extends State<PosOpenShiftDialog> {
  final _controller = TextEditingController(text: '0.00');
  bool _isSaving = false;

  double _parseAmount() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0.0;
    return value < 0 ? 0.0 : value;
  }

  Future<void> _openShift() async {
    final amount = _parseAmount();

    setState(() => _isSaving = true);

    try {
      final response = await widget.controller.shift.openShift(
        initialCash: amount,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        Navigator.of(context).pop(true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'].toString())),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el turno: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Abrir el turno',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Especifique la cantidad de efectivo de la caja con el que empezará su turno',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _controller,
                    enabled: !_isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _openShift,
                      child: _isSaving
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('ABRIR EL TURNO'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}