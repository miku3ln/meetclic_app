
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PsInfoCardType {
  simple, // sin close ni footer
  closable, // con close
  closableWithFooter, // close + footer
}
const successCard = PsInfoCardConfig(
  backgroundColor: Color(0xFFF0FDF4),
  borderColor: Color(0xFFBBF7D0),
  iconBackgroundColor: Color(0xFFDCFCE7),
  iconColor: Color(0xFF16A34A),
  titleColor: Color(0xFF166534),
  descriptionColor: Color(0xFF15803D),
);
const warningCard = PsInfoCardConfig(
  backgroundColor: Color(0xFFFFFBEB),
  borderColor: Color(0xFFFDE68A),
  iconBackgroundColor: Color(0xFFFEF3C7),
  iconColor: Color(0xFFD97706),
  titleColor: Color(0xFF92400E),
  descriptionColor: Color(0xFFB45309),
);
const errorCard = PsInfoCardConfig(
  backgroundColor: Color(0xFFFEF2F2),
  borderColor: Color(0xFFFECACA),
  iconBackgroundColor: Color(0xFFFEE2E2),
  iconColor: Color(0xFFDC2626),
  titleColor: Color(0xFF991B1B),
  descriptionColor: Color(0xFFB91C1C),
);
class PsInfoCardConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color descriptionColor;

  const PsInfoCardConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.descriptionColor,
  });
}
class PsInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  final PsInfoCardType type;
  final PsInfoCardConfig config;

  final Widget? footer;

  final VoidCallback? onClose;
  final VoidCallback? onTap;

  /// Opcionales
  /// Ejemplo:
  /// widthPercent: 0.8 -> 80% del ancho
  /// heightPercent: 0.3 -> 30% del alto
  final double? widthPercent;
  final double? heightPercent;

  const PsInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.config,
    this.footer,
    this.onClose,
    this.onTap,
    this.widthPercent,
    this.heightPercent,
  });

  bool get _showClose =>
      type == PsInfoCardType.closable ||
          type == PsInfoCardType.closableWithFooter;

  bool get _showFooter =>
      type == PsInfoCardType.closableWithFooter;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final cardWidth = widthPercent != null
        ? size.width * widthPercent!
        : double.infinity;

    final cardHeight = heightPercent != null
        ? size.height * heightPercent!
        : null;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: config.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: cardHeight == null
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: config.iconBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: config.iconColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: config.titleColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: config.descriptionColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_showClose)
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),

                if (_showFooter && footer != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}