import 'package:flutter/material.dart';
import '../layouts/pos_header_default.dart';
import '../layouts/pos_header_mobile_portrait.dart';
import '../../helpers/pos_responsive.dart';

class PosHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> dropdownItems;
  final String selectedItem;

  final VoidCallback onMenuTap;
  final VoidCallback onUserTap;
  final VoidCallback onMoreTap;

  final ValueChanged<String?> onDropdownChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const PosHeaderBar({
    super.key,
    required this.dropdownItems,
    required this.selectedItem,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
    required this.onDropdownChanged,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final showMobilePortraitHeader =
    PosResponsive.isMobile(context);

    if (showMobilePortraitHeader) {
      // ✅ Mobile Portrait (sin Ticket)
      return PosHeaderMobilePortraitLayout(
        dropdownItems: dropdownItems,
        selectedItem: selectedItem,
        onMenuTap: onMenuTap,
        onDropdownChanged: onDropdownChanged,
        onSearchChanged: onSearchChanged,
        onSearchSubmitted: onSearchSubmitted,
        onUserTap: onUserTap,
        onMoreTap: onMoreTap,
      );
    }

    // ✅ Default: mobile landscape + tablet portrait + tablet landscape
    return PosHeaderDefaultLayout(
      dropdownItems: dropdownItems,
      selectedItem: selectedItem,
      onMenuTap: onMenuTap,
      onDropdownChanged: onDropdownChanged,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      onUserTap: onUserTap,
      onMoreTap: onMoreTap,
    );
  }
}