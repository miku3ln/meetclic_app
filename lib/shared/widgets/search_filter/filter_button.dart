import 'package:flutter/material.dart';

import '../../theme/configuration/app_theme_tokens.dart';
import 'controller/search_filter_controller.dart';
import 'controller/search_filter_events.dart';


class FilterButton extends StatefulWidget {
  final SearchFilterController controller;

  final VoidCallback? onPressed;

  const FilterButton({
    super.key,
    required this.controller,
    this.onPressed,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {

  @override
  void initState() {
    super.initState();

    widget.controller.events.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final totalFilters = widget.controller.totalFilters;
    final hasFilters = totalFilters > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),

      decoration: BoxDecoration(
        color: hasFilters
            ? tokens.primary
            : tokens.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: hasFilters
              ? tokens.primary
              : tokens.border,
        ),

        boxShadow: [
          BoxShadow(
            color: hasFilters
                ? tokens.primary.withOpacity(.12)
                : tokens.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            widget.controller.emit(
              SearchFilterEvents.drawerOpened,
            );

            widget.onPressed?.call();
          },

          icon: Icon(
            Icons.tune_rounded,
            size: 20,
            color: hasFilters
                ? tokens.white
                : tokens.primary,
          ),

          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "Filtros",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: hasFilters
                      ? tokens.white
                      : tokens.textPrimary,
                ),
              ),

              if (hasFilters) ...[
                const SizedBox(width: 4),
                Text(
                  "($totalFilters)",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: tokens.white,
                  ),
                ),
              ],

            ],
          ),

          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,

            minimumSize: const Size(140, 56),

            backgroundColor: Colors.transparent,

            foregroundColor: hasFilters
                ? tokens.white
                : tokens.textPrimary,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}