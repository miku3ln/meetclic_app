import 'package:flutter/material.dart';

class ReceiptManagementActions extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onWhatsApp;
  final VoidCallback onElectronicInvoice;

  final bool isVertical;

  const ReceiptManagementActions({
    super.key,
    required this.onPrint,
    required this.onDownload,
    required this.onWhatsApp,
    required this.onElectronicInvoice,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ReceiptActionButton(
        icon: Icons.print_outlined,
        label: 'Imprimir',
        onPressed: onPrint,
        isVertical: isVertical,
      ),
      _ReceiptActionButton(
        icon: Icons.download_outlined,
        label: 'Descargar',
        onPressed: onDownload,
        isVertical: isVertical,
      ),
      _ReceiptActionButton(
        icon: Icons.chat_outlined,
        label: 'WhatsApp',
        onPressed: onWhatsApp,
        isVertical: isVertical,
      ),
      _ReceiptActionButton(
        icon: Icons.receipt_long_outlined,
        label: 'Facturar electrónicamente',
        onPressed: onElectronicInvoice,
        isVertical: isVertical,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isVertical)
        Text(
          'Gestión del comprobante',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        if (isVertical)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                actions[i],
                if (i < actions.length - 1)
                  const SizedBox(height: 8),
              ],
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions,
          ),
      ],
    );
  }
}

class _ReceiptActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isVertical;

  const _ReceiptActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Tooltip(
        message: label,
        child: SizedBox(
          width: 42,
          height: 42,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: 21,
            ),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}