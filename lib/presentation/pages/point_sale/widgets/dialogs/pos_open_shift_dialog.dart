import 'package:flutter/material.dart';

class PosOpenShiftDialog extends StatefulWidget {
  const PosOpenShiftDialog({super.key});

  @override
  State<PosOpenShiftDialog> createState() => _PosOpenShiftDialogState();
}

class _PosOpenShiftDialogState extends State<PosOpenShiftDialog> {
  final _controller = TextEditingController(text: '0.00');

  double _parseAmount() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0.0;
    return value < 0 ? 0.0 : value;
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
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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

            // BODY
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      onPressed: () {
                        Navigator.pop(context, _parseAmount()); // ✅ devuelve monto
                      },
                      child: const Text('ABRIR EL TURNO'),
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