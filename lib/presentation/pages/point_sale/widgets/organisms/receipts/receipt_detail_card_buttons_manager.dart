import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReceiptManagementActions extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onWhatsApp;
  final VoidCallback onElectronicInvoice;

  const ReceiptManagementActions({
    required this.onPrint,
    required this.onDownload,
    required this.onWhatsApp,
    required this.onElectronicInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión del comprobante',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ReceiptActionButton(
              icon: Icons.print_outlined,
              label: 'Imprimir',
              onPressed: onPrint,
            ),

            _ReceiptActionButton(
              icon: Icons.download_outlined,
              label: 'Descargar',
              onPressed: onDownload,
            ),

            _ReceiptActionButton(
              icon: Icons.chat_outlined,
              label: 'WhatsApp',
              onPressed: onWhatsApp,
            ),

            _ReceiptActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Facturar electrónicamente',
              onPressed: onElectronicInvoice,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReceiptActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ReceiptActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}