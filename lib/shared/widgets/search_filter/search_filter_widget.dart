
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/widgets/search_filter/search_input.dart';

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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterDrawer(
          controller: widget.controller,
          config: widget.config,
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
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.config.showSearch)
              Expanded(
                child: SearchInput(
                  controller: widget.controller,
                  config: widget.config,
                ),
              ),

            if (widget.config.showSearch &&
                widget.config.showFilterButton)
              const SizedBox(width: 12),

            if (widget.config.showFilterButton)
              FilterButton(
                controller: widget.controller,
                onPressed: _openFilters,
              ),
          ],
        ),

        if (widget.config.showFilterChips)
          AnimatedBuilder(
            animation: widget.controller.searchController,
            builder: (_, __) {
              if (widget.controller.filters.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.controller.filters.map((filter) {
                    return InputChip(
                      label: Text(filter.displayValue),
                      onDeleted: () {
                        widget.controller.removeFilter(
                          filter.fieldId,
                        );

                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }

}

