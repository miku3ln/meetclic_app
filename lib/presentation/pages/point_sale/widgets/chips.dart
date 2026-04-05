import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/pos_product_item.dart';
class PosCouponChips extends StatelessWidget {
  final List<PostTicketItem> items;
  final void Function(PostTicketItem item) onRemove;

  const PosCouponChips({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final itemsWithCoupon =
    items.where((e) => e.coupon != null).toList();

    if (itemsWithCoupon.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: itemsWithCoupon.map((item) {
        final coupon = item.coupon!; // 👈 seguro aquí

        return _CouponChip(
          code: coupon.code,
          name: coupon.name,
          onRemove: () => onRemove(item),
        );
      }).toList(),
    );
  }
}
class _CouponChip extends StatelessWidget {
  final String code;
  final String name;
  final VoidCallback onRemove;

  const _CouponChip({
    required this.code,
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF22C55E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer,
            size: 14,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 6),

          /// código
          Text(
            code,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF16A34A),
            ),
          ),

          const SizedBox(width: 6),

          /// nombre
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),

          const SizedBox(width: 6),

          /// cerrar
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}