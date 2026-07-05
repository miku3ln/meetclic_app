import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/configuration/app_theme_tokens.dart';
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
  void initState() {
    super.initState();

    widget.controller.searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

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
    final tokens = AppThemeTokens.of(context);

    final hasFocus = widget.controller.searchFocusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: 56,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: hasFocus ? tokens.primary : tokens.border,
          width: hasFocus ? 1.4 : 1,
        ),

        boxShadow: [
          BoxShadow(
            color: hasFocus
                ? tokens.primary.withOpacity(.08)
                : tokens.shadow,
            blurRadius: hasFocus ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: TextField(
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
          border: InputBorder.none,

          hintText: widget.config.hint,

          hintStyle: TextStyle(
            color: tokens.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 58,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 8,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: tokens.iconMuted,
            ),
          ),

          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller.searchController,
            builder: (_, value, __) {
              if (value.text.isEmpty) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: IconButton(
                  splashRadius: 18,

                  onPressed: _onClear,

                  icon: Container(
                    width: 26,
                    height: 26,

                    decoration: BoxDecoration(
                      color: tokens.surfaceMuted,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: tokens.iconMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}