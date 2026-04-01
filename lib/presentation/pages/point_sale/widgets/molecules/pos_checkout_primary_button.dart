import 'package:flutter/material.dart';
import '../../state/pos_checkout_state.dart';
import '../layouts/pos_main_controller.dart';

class PosCheckoutPrimaryButton extends StatelessWidget {
  final PosMainController controller;
  final double height;

  const PosCheckoutPrimaryButton({
    super.key,
    required this.controller,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colors = controller.checkout.toggleColors;

    final isPay = controller.checkout.checkoutAction == PosCheckoutAction.pay;

    final String label = isPay ? 'Cobrar' : 'Guardar';
    final Color bg = isPay ? colors.payActiveBg : colors.saveActiveBg;
    final Color fg = isPay ? colors.payActiveFg : colors.saveActiveFg;

    final bool enabled = controller.allowManagementPost();

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled
            ? () => controller.onPrimaryCheckoutTap(context)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withOpacity(0.4),
          disabledForegroundColor: fg.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}