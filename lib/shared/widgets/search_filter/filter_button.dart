import 'package:flutter/material.dart';

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

    final totalFilters = widget.controller.totalFilters;

    return Badge(
      isLabelVisible: totalFilters > 0,
      label: Text(totalFilters.toString()),
      child: OutlinedButton.icon(
        onPressed: () {

          widget.controller.emit(
            SearchFilterEvents.drawerOpened,
          );

          widget.onPressed?.call();

        },
        icon: const Icon(Icons.tune_rounded),
        label: const Text("Filtros"),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(110, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}