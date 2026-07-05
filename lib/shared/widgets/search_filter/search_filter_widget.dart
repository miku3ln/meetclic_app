import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/widgets/search_filter/search_input.dart';

import '../../theme/configuration/app_theme_tokens.dart';
import 'controller/search_filter_controller.dart';
import 'filter_button.dart';
import 'filter_drawer.dart';
import 'models/search_filter_config.dart';

class SearchFilterWidget extends StatefulWidget {
  final SearchFilterController controller;

  final SearchFilterConfig config;

  const SearchFilterWidget({
    super.key,
    required this.controller,
    required this.config,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  Future<void> _openFilters() async {
    widget.controller.openDrawer();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filtros",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return FilterDrawer(
          controller: widget.controller,
          config: widget.config,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );

    widget.controller.closeDrawer();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        //-------------------------------------------------
        // BUSCADOR + BOTON
        //-------------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            if (widget.config.showSearch)
              Expanded(
                child: SearchInput(
                  controller: widget.controller,

                  config: widget.config,
                ),
              ),

            if (widget.config.showSearch && widget.config.showFilterButton)
              const SizedBox(width: 16),

            if (widget.config.showFilterButton)
              FilterButton(
                controller: widget.controller,

                onPressed: _openFilters,
              ),
          ],
        ),

        //-------------------------------------------------
        // CHIPS
        //-------------------------------------------------
//-------------------------------------------------
// FILTROS ACTIVOS
//-------------------------------------------------

        AnimatedBuilder(
          animation: widget.controller.searchController,
          builder: (_, __) {
            if (widget.controller.filters.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //-------------------------------------------------
                  // TITULO + LIMPIAR TODOS
                  //-------------------------------------------------

                  Row(
                    children: [

                      Text(
                        "FILTROS ACTIVOS",
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () {

                          widget.controller.resetFilters();

                          setState(() {});

                        },

                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),

                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: tokens.primary,
                        ),

                        label: Text(
                          "Limpiar todos",
                          style: TextStyle(
                            color: tokens.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  //-------------------------------------------------
                  // CHIPS
                  //-------------------------------------------------

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.controller.filters.map((filter) {

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _FilterChip(
                            label: filter.displayValue,
                            onDelete: () {

                              widget.controller.removeFilter(
                                filter.fieldId,
                              );

                              setState(() {});

                            },
                          ),
                        );

                      }).toList(),
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _FilterChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          const SizedBox(width: 8),

          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: tokens.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
