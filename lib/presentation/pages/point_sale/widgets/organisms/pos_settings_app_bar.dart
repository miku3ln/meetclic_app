import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PosSettingsAppBarStyle {
  final Color topBackgroundColor;
  final Color bottomBackgroundColor;

  final Color primaryTitleColor;
  final Color secondaryTitleColor;
  final Color menuIconColor;

  final Color primaryIndicatorColor;
  final Color secondaryIndicatorColor;
  final Color dividerColor;

  final double dividerWidth;
  final double dividerHeight;

  final double indicatorHeight;
  final double toolbarHeight;

  const PosSettingsAppBarStyle({
    required this.topBackgroundColor,
    required this.bottomBackgroundColor,
    required this.primaryTitleColor,
    required this.secondaryTitleColor,
    required this.menuIconColor,
    required this.primaryIndicatorColor,
    required this.secondaryIndicatorColor,
    required this.dividerColor,
    this.dividerWidth = 2,
    this.dividerHeight = 100,
    this.indicatorHeight = 4,
    this.toolbarHeight = 64,
  });

  factory PosSettingsAppBarStyle.defaults() {
    return const PosSettingsAppBarStyle(
      topBackgroundColor: Color(0xFF2E7D32),
      bottomBackgroundColor: Color(0xFF4CAF50),
      primaryTitleColor: Colors.white,
      secondaryTitleColor: Colors.white,
      menuIconColor: Colors.white,
      primaryIndicatorColor: Color(0xFFFFA000), // naranja
      secondaryIndicatorColor: Color(0xFFBDBDBD), // gris
      dividerColor: Color(0xFFFF6347), // tomato
    );
  }
}

class PosSettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titlePrimary;
  final String titleSecondary;
  final VoidCallback? onMenuTap;
  final PosSettingsAppBarStyle style;

  const PosSettingsAppBar({
    super.key,
    required this.titlePrimary,
    required this.titleSecondary,
    this.onMenuTap,
    this.style = const PosSettingsAppBarStyle(
      topBackgroundColor: Color(0xFF2E7D32),
      bottomBackgroundColor: Color(0xFF4CAF50),
      primaryTitleColor: Colors.white,
      secondaryTitleColor: Colors.white,
      menuIconColor: Colors.white,
      primaryIndicatorColor: Color(0xFFFFA000),
      secondaryIndicatorColor: Color(0xFFBDBDBD),
      dividerColor: Color(0xFFFF6347),
    ),
  });

  @override
  Size get preferredSize => Size.fromHeight(style.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: style.toolbarHeight,
      backgroundColor: style.bottomBackgroundColor,
      flexibleSpace: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: style.topBackgroundColor,
          ),
          Expanded(
            child: Container(
              color: style.bottomBackgroundColor,
              child: Row(
                children: [
                  Expanded(
                    flex: 30,
                    child: _PrimarySection(
                      title: titlePrimary,
                      onMenuTap: onMenuTap,
                      titleColor: style.primaryTitleColor,
                      iconColor: style.menuIconColor,
                      indicatorColor: style.primaryIndicatorColor,
                      indicatorHeight: style.indicatorHeight,
                    ),
                  ),
                  Container(
                    width: style.dividerWidth,
                    height: style.dividerHeight,
                    color: style.dividerColor,
                  ),
                  Expanded(
                    flex: 70,
                    child: _SecondarySection(
                      title: titleSecondary,
                      titleColor: style.secondaryTitleColor,
                      indicatorColor: style.secondaryIndicatorColor,
                      indicatorHeight: style.indicatorHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      title: const SizedBox.shrink(),
    );
  }
}

class _PrimarySection extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final Color titleColor;
  final Color iconColor;
  final Color indicatorColor;
  final double indicatorHeight;

  const _PrimarySection({
    required this.title,
    required this.onMenuTap,
    required this.titleColor,
    required this.iconColor,
    required this.indicatorColor,
    required this.indicatorHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(Icons.menu, color: iconColor),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 56,
            bottom: 6,
            child: Container(
              width: 84,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondarySection extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color indicatorColor;
  final double indicatorHeight;

  const _SecondarySection({
    required this.title,
    required this.titleColor,
    required this.indicatorColor,
    required this.indicatorHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 6,
            child: Container(
              width: 140,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}