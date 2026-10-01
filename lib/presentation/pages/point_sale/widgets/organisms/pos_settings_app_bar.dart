import 'package:flutter/material.dart';

/*
 * ================================================================
 * POPUP MENU ITEM
 * ================================================================
 */

class PosAppBarMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  const PosAppBarMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}

/*
 * ================================================================
 * STYLE
 * ================================================================
 */

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
      primaryIndicatorColor: Color(0xFFFFA000),
      // naranja
      secondaryIndicatorColor: Color(0xFFBDBDBD),
      // gris
      dividerColor: Color(0xFFFF6347), // tomato
    );
  }
}

/*
 * ================================================================
 * POS SETTINGS APP BAR
 * ================================================================
 */

class PosSettingsAppBar<T> extends StatelessWidget
    implements PreferredSizeWidget {
  final String titlePrimary;
  final String titleSecondary;

  final VoidCallback? onMenuTap;

  final PosSettingsAppBarStyle style;

  /*
   * ==============================================================
   * LEADING
   *
   * YA EXISTÍA
   * ==============================================================
   */

  final IconData? leadingIcon;
  final String? leadingTitle;
  final VoidCallback? onLeadingTap;

  /*
   * ==============================================================
   * FLEX
   *
   * YA EXISTÍA
   * ==============================================================
   */

  final int primaryFlex;
  final int secondaryFlex;

  /*
   * ==============================================================
   * ACCIÓN DERECHA 1
   *
   * NUEVO
   * ==============================================================
   */

  final IconData? firstActionIcon;
  final String? firstActionTooltip;
  final VoidCallback? onFirstActionTap;

  /*
   * ==============================================================
   * ACCIÓN DERECHA 2
   *
   * NUEVO
   * ==============================================================
   */

  final IconData? secondActionIcon;
  final String? secondActionTooltip;
  final VoidCallback? onSecondActionTap;

  /*
   * ==============================================================
   * POPUP MENU
   *
   * NUEVO
   * ==============================================================
   */

  final List<PosAppBarMenuItem<T>> popupMenuItems;

  final ValueChanged<T>? onPopupMenuSelected;
  final bool showDivider;

  /*
   * ==============================================================
   * CONSTRUCTOR
   * ==============================================================
   */

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

    /*
     * Ya existían
     */
    this.leadingIcon,
    this.leadingTitle,
    this.onLeadingTap,

    this.primaryFlex = 30,
    this.secondaryFlex = 70,

    /*
     * Nuevos
     */
    this.firstActionIcon,
    this.firstActionTooltip,
    this.onFirstActionTap,

    this.secondActionIcon,
    this.secondActionTooltip,
    this.onSecondActionTap,

    this.popupMenuItems = const [],
    this.onPopupMenuSelected,
    this.showDivider = true,
  });

  /*
   * ================================================================
   * PREFERRED SIZE
   * ================================================================
   */

  @override
  Size get preferredSize {
    return Size.fromHeight(style.toolbarHeight);
  }

  /*
   * ================================================================
   * BUILD
   * ================================================================
   */

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,

      elevation: 0,

      toolbarHeight: style.toolbarHeight,

      backgroundColor: style.bottomBackgroundColor,

      flexibleSpace: Column(
        children: [
          /*
           * ==========================================================
           * STATUS BAR
           * ==========================================================
           */
          Container(
            height: MediaQuery.of(context).padding.top,

            color: style.topBackgroundColor,
          ),

          /*
           * ==========================================================
           * CONTENIDO DEL APP BAR
           * ==========================================================
           */
          Expanded(
            child: Container(
              color: style.bottomBackgroundColor,

              child: Row(
                children: [
                  /*
                   * ==================================================
                   * PRIMARY SECTION
                   * ==================================================
                   */
                  Expanded(
                    flex: primaryFlex,

                    child: _PrimarySection(
                      title: titlePrimary,

                      onMenuTap: onMenuTap,

                      titleColor: style.primaryTitleColor,

                      iconColor: style.menuIconColor,

                      indicatorColor: style.primaryIndicatorColor,

                      indicatorHeight: style.indicatorHeight,

                      /*
                       * Mantiene lo que ya tenías.
                       */
                      leadingIcon: leadingIcon,

                      leadingTitle: leadingTitle,

                      onLeadingTap: onLeadingTap,
                    ),
                  ),

                  /*
                   * ==================================================
                   * DIVIDER
                   * ==================================================
                   */
                  if (showDivider)
                    Container(
                      width: style.dividerWidth,
                      height: style.dividerHeight,
                      color: style.dividerColor,
                    ),
                  /*
                   * ==================================================
                   * SECONDARY SECTION
                   *
                   * Aquí agregamos las acciones derechas.
                   * ==================================================
                   */
                  Expanded(
                    flex: secondaryFlex,

                    child: Row(
                      children: [
                        /*
                         * =============================================
                         * SECONDARY ORIGINAL
                         * =============================================
                         */
                        Expanded(
                          child: _SecondarySection(
                            title: titleSecondary,

                            titleColor: style.secondaryTitleColor,

                            indicatorColor: style.secondaryIndicatorColor,

                            indicatorHeight: style.indicatorHeight,
                          ),
                        ),

                        /*
                         * =============================================
                         * ACCIONES DERECHAS
                         * =============================================
                         */
                        _buildRightActions(),
                      ],
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

  /*
   * ================================================================
   * RIGHT ACTIONS
   * ================================================================
   */

  Widget _buildRightActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        /*
         * ============================================================
         * ACCIÓN 1
         * ============================================================
         */
        if (firstActionIcon != null)
          IconButton(
            tooltip: firstActionTooltip,

            onPressed: onFirstActionTap,

            icon: Icon(firstActionIcon, color: style.menuIconColor),
          ),

        /*
         * ============================================================
         * ACCIÓN 2
         * ============================================================
         */
        if (secondActionIcon != null)
          IconButton(
            tooltip: secondActionTooltip,

            onPressed: onSecondActionTap,

            icon: Icon(secondActionIcon, color: style.menuIconColor),
          ),

        /*
         * ============================================================
         * POPUP MENU
         * ============================================================
         */
        if (popupMenuItems.isNotEmpty)
          PopupMenuButton<T>(
            tooltip: 'Más opciones',

            /*
             * Icono de los tres puntos.
             */
            icon: Icon(Icons.more_vert, color: style.menuIconColor),

            /*
             * Callback al seleccionar.
             */
            onSelected: onPopupMenuSelected,

            /*
             * Opciones.
             */
            itemBuilder: (context) {
              return popupMenuItems
                  .map(
                    (item) => PopupMenuItem<T>(
                      value: item.value,

                      enabled: item.enabled,

                      child: Row(
                        children: [
                          /*
                           * Icono opcional.
                           */
                          if (item.icon != null) ...[
                            Icon(item.icon, size: 20),

                            const SizedBox(width: 12),
                          ],

                          /*
                           * Texto.
                           */
                          Expanded(child: Text(item.label)),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
          ),

        /*
         * Separación derecha.
         */
        if (firstActionIcon != null ||
            secondActionIcon != null ||
            popupMenuItems.isNotEmpty)
          const SizedBox(width: 8),
      ],
    );
  }
}

/*
 * ==================================================================
 * PRIMARY SECTION
 *
 * SE MANTIENE TU IMPLEMENTACIÓN
 * ==================================================================
 */

class _PrimarySection extends StatelessWidget {
  final String title;

  final VoidCallback? onMenuTap;

  final Color titleColor;
  final Color iconColor;
  final Color indicatorColor;

  final double indicatorHeight;

  final IconData? leadingIcon;

  final String? leadingTitle;

  final VoidCallback? onLeadingTap;

  const _PrimarySection({
    required this.title,
    required this.onMenuTap,
    required this.titleColor,
    required this.iconColor,
    required this.indicatorColor,
    required this.indicatorHeight,
    required this.leadingIcon,
    required this.leadingTitle,
    required this.onLeadingTap,
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
              /*
               * ========================================================
               * MENU / LEADING
               * ========================================================
               */
              IconButton(
                onPressed: leadingIcon != null ? onLeadingTap : onMenuTap,

                icon: Icon(leadingIcon ?? Icons.menu, color: iconColor),
              ),

              /*
               * ========================================================
               * TITLE
               * ========================================================
               */
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

          /*
           * ==========================================================
           * INDICATOR
           * ==========================================================
           */
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

/*
 * ==================================================================
 * SECONDARY SECTION
 *
 * SE MANTIENE TU IMPLEMENTACIÓN
 * ==================================================================
 */

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
          /*
           * ==========================================================
           * TITLE
           * ==========================================================
           */
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

          /*
           * ==========================================================
           * INDICATOR
           * ==========================================================
           */
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
