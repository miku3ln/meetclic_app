import 'dart:async';

import 'package:flutter/material.dart';

import 'controller/search_filter_controller.dart';
import 'controller/search_filter_events.dart';
import 'models/search_filter_config.dart';


class SearchInput extends StatefulWidget {
  final SearchFilterController controller;

  final SearchFilterConfig config;

  const SearchInput({
    super.key,
    required this.controller,
    required this.config,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.controller.emit(
      SearchFilterEvents.searchChanged,
      value,
    );

    if (!widget.config.autoSearch) {
      return;
    }

    _debounce?.cancel();

    _debounce = Timer(
      widget.config.searchDelay,
          () {
        widget.controller.submitSearch();
      },
    );
  }

  void _onClear() {
    widget.controller.clearSearch();

    if (widget.config.autoSearch) {
      widget.controller.submitSearch();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller.searchController,
      focusNode: widget.controller.searchFocusNode,
      enabled: !widget.controller.loading,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      onSubmitted: (_) {
        widget.controller.submitSearch();
      },
      onTap: () {
        widget.controller.emit(
          SearchFilterEvents.searchFocus,
        );
      },
      decoration: InputDecoration(
        hintText: widget.config.hint,

        prefixIcon: const Icon(
          Icons.search_rounded,
        ),

        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller.searchController,
          builder: (_, value, __) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: _onClear,
            );
          },
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}