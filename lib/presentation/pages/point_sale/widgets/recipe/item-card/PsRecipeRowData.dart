import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../shared/responsive/device_gesture_observer.dart';
import '../../../models/product_management_measure.dart';
import '../../molecules/inputs/ps_dropdown.dart';
import '../../molecules/inputs/ps_field_row.dart';
import '../../molecules/inputs/ps_input.dart';

class PsRecipeAction {
  final IconData icon;

  final VoidCallback?  onPressed;

  final Color color;

  final double size;

  final String? tooltip;

  const PsRecipeAction({
    required this.icon,
    required this.onPressed,
    this.color = Colors.black,
    this.size = 20,
    this.tooltip,
  });
}

class PsRecipeLeading {
  final IconData icon;

  final String title;

  final Color backgroundColor;

  final Color iconColor;

  final double radius;

  const PsRecipeLeading({
    required this.icon,
    required this.title,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.radius = 28,
  });
}

class PsRecipeFooterItem {
  final String title;

  final String value;

  final Color titleColor;

  final Color valueColor;

  final FontWeight titleWeight;

  final FontWeight valueWeight;

  const PsRecipeFooterItem({
    required this.title,
    required this.value,
    this.titleColor = Colors.red,
    this.valueColor = Colors.black,
    this.titleWeight = FontWeight.w500,
    this.valueWeight = FontWeight.w600,
  });
}

class PsRecipeRowData<T> {
  /// Left Border
  final Color leftBorderColor;

  /// Header
  final String title;

  final String badgeTitle;

  final Color badgeBackground;

  final Color badgeTextColor;

  final List<PsRecipeAction> actions;

  /// Leading
  final PsRecipeLeading leading;

  /// Input
  final String inputLabel;

  final String? inputValue;

  final ValueChanged<String>? onInputChanged;

  /// Dropdown
  final String dropdownLabel;

  final List<T> dropdownItems;

  final T? dropdownValue;

  final String Function(T) dropdownItemLabel;

  final ValueChanged<T?> onDropdownChanged;

  /// Equivalence
  final String equivalenceTitle;

  final String equivalenceValue;

  /// Footer
  final List<PsRecipeFooterItem> footerItems;

  final RecipeIngredientItem item;
  final List<MeasureCategoryModel> measureCategories;

  const PsRecipeRowData({
    required this.leftBorderColor,
    required this.title,

    required this.badgeTitle,
    required this.badgeBackground,
    required this.badgeTextColor,

    this.actions = const [],

    required this.leading,

    required this.inputLabel,
    this.inputValue,
    this.onInputChanged,
    required this.dropdownLabel,
    required this.dropdownItems,
    required this.dropdownValue,
    required this.dropdownItemLabel,
    required this.onDropdownChanged,
    required this.equivalenceTitle,
    required this.equivalenceValue,
    this.footerItems = const [],
    required this.item,
    required this.measureCategories,
  });
}

class UnitItem {
  final int id;
  final String name;

  const UnitItem({required this.id, required this.name});
}
class PsRecipeRowItem<T> extends StatelessWidget {
  final PsRecipeRowData<T> data;
  final DeviceSnapshot deviceSnapshot;

  const PsRecipeRowItem({
    super.key,
    required this.data,
    required this.deviceSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: data.leftBorderColor,
            width: 6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: deviceSnapshot.isTablet
          ? _buildTabletLayout(context)
          : _buildMobileLayout(context),
    );
  }

  // =========================================================
  // TABLET
  // SE MANTIENE EL DISEÑO ACTUAL
  // =========================================================

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),

        const SizedBox(height: 20),

        _buildBody(context),

        const SizedBox(height: 20),

        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                data.title,
                style: AppTextStyles.title(context),
              ),

              const SizedBox(width: 10),

              _buildBadgeManager(
                context,
                data.badgeTitle,
                data.badgeBackground,
                data.badgeTextColor,
              ),
            ],
          ),
        ),

        Wrap(
          spacing: 4,
          children: data.actions
              .map(
                (e) => IconButton(
              tooltip: e.tooltip,
              onPressed: e.onPressed,
              icon: Icon(
                e.icon,
                color: e.color,
                size: e.size,
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeading(),

        const SizedBox(width: 24),

        Expanded(
          child: PsFieldRow(
            children: [
              PsFieldItem(
                flex: 3,
                child: PsInput(
                  label: data.inputLabel,
                  value: data.inputValue,
                  onChanged: data.onInputChanged,
                ),
              ),

              PsFieldItem(
                flex: 3,
                child: PsDropdown<T>(
                  label: data.dropdownLabel,
                  items: data.dropdownItems,
                  value: data.dropdownValue,
                  getLabel: data.dropdownItemLabel,
                  onChanged: data.onDropdownChanged,
                ),
              ),

              PsFieldItem(
                flex: 2,
                child: _buildBaseInfo(
                  data.item,
                  data.measureCategories,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeading() {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CircleAvatar(
            radius: data.leading.radius,
            backgroundColor: data.leading.backgroundColor,
            child: Icon(
              data.leading.icon,
              color: data.leading.iconColor ?? Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.leading.title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOBILE
  // NUEVO DISEÑO
  //
  // Producto
  // Creación
  // acciones
  //
  // [ tipo de medida ]
  //
  // Cantidad
  // [____________]
  //
  // Unidad
  // [____________]
  //
  // Equiv. Base
  // [____________]
  // =========================================================

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMobileHeader(context),

        const SizedBox(height: 16),

        _buildMobileActions(context),

        const SizedBox(height: 16),

        _buildMobileMeasureType(context),

        const SizedBox(height: 20),

        PsInput(
          label: data.inputLabel,
          value: data.inputValue,
          onChanged: data.onInputChanged,
        ),

        const SizedBox(height: 16),

        PsDropdown<T>(
          label: data.dropdownLabel,
          items: data.dropdownItems,
          value: data.dropdownValue,
          getLabel: data.dropdownItemLabel,
          onChanged: data.onDropdownChanged,
        ),

        const SizedBox(height: 16),

        _buildBaseInfo(
          data.item,
          data.measureCategories,
        ),

        if (data.footerItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildMobileFooter(context),
        ],
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: AppTextStyles.title(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        _buildBadgeManager(
          context,
          data.badgeTitle,
          data.badgeBackground,
          data.badgeTextColor,
        ),
      ],
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: data.actions
            .map(
              (e) => IconButton(
            tooltip: e.tooltip,
            onPressed: e.onPressed,
            icon: Icon(
              e.icon,
              color: e.color,
              size: e.size,
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildMobileMeasureType(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: data.leading.backgroundColor.withOpacity(.35),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: data.leading.backgroundColor,
            child: Icon(
              data.leading.icon,
              color: data.leading.iconColor ?? Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              data.leading.title,
              style: AppTextStyles.body(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMMON
  // =========================================================

  Widget _buildBaseInfo(
      RecipeIngredientItem item,
      List<MeasureCategoryModel> measureCategories,
      ) {
    if (item.inputUnit == null || item.baseUnit == null) {
      return const SizedBox.shrink();
    }

    final baseValue =
        item.quantityInput * item.conversionFactor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equiv. Base'),

          const SizedBox(height: 8),

          Text(
            '${baseValue.toStringAsFixed(2)} ${item.baseUnit!.symbol}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalenceCard(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: c.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            data.equivalenceTitle,
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: 8),
          Text(
            data.equivalenceValue,
            style: AppTextStyles.title(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 90),

        Expanded(
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            children: data.footerItems
                .map(
                  (item) => _buildFooterItem(
                context,
                item,
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.footerItems
          .map(
            (item) => _buildFooterItem(
          context,
          item,
        ),
      )
          .toList(),
    );
  }

  Widget _buildFooterItem(
      BuildContext context,
      dynamic item,
      ) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${item.title}: ',
            style: AppTextStyles.bodySecondary(context).copyWith(
              color:
              item.titleColor ??
                  AppThemeTokens.of(context).textSecondary,
              fontWeight: item.titleWeight,
            ),
          ),
          TextSpan(
            text: item.value,
            style: AppTextStyles.body(context).copyWith(
              color:
              item.valueColor ??
                  AppThemeTokens.of(context).textPrimary,
              fontWeight: item.valueWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeManager(
      BuildContext context,
      String value,
      Color background,
      Color textColor,
      ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
class PsRecipeRowItem2<T> extends StatelessWidget {
  final PsRecipeRowData<T> data;

  const PsRecipeRowItem2({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: data.leftBorderColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildBody(context),

          const SizedBox(height: 20),

          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(data.title, style: AppTextStyles.title(context)),

              const SizedBox(width: 10),

              _buildBadgeManager(
                context,
                data.badgeTitle,
                data.badgeBackground,
                data.badgeTextColor,
              ),
            ],
          ),
        ),

        Wrap(
          spacing: 4,
          children: data.actions
              .map(
                (e) => IconButton(
                  tooltip: e.tooltip,
                  onPressed: e.onPressed,
                  icon: Icon(e.icon, color: e.color, size: e.size),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeading(),

        const SizedBox(width: 24),

        Expanded(
          child: PsFieldRow(
            children: [
              PsFieldItem(
                flex: 3,
                child: PsInput(
                  label: data.inputLabel,
                  value: data.inputValue,
                  onChanged: data.onInputChanged,
                ),
              ),

              PsFieldItem(
                flex: 3,
                child: PsDropdown<T>(
                  label: data.dropdownLabel,
                  items: data.dropdownItems,
                  value: data.dropdownValue,
                  getLabel: data.dropdownItemLabel,
                  onChanged: data.onDropdownChanged,
                ),
              ),

              PsFieldItem(
                flex: 2,
                child: _buildBaseInfo(data.item, data.measureCategories),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeading() {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CircleAvatar(
            radius: data.leading.radius,
            backgroundColor: data.leading.backgroundColor,
            child: Icon(
              data.leading.icon,
              color: data.leading.iconColor ?? Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(data.leading.title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBaseInfo(
    RecipeIngredientItem item,
    List<MeasureCategoryModel> measureCategories,
  ) {
    if (item.inputUnit == null || item.baseUnit == null) {
      return const SizedBox.shrink();
    }

    final baseValue = item.quantityInput * item.conversionFactor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equiv. Base'),
          const SizedBox(height: 8),
          Text(
            '${baseValue.toStringAsFixed(2)} ${item.baseUnit!.symbol}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalenceCard(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            data.equivalenceTitle,
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: 8),
          Text(data.equivalenceValue, style: AppTextStyles.title(context)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 90),

        Expanded(
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            children: data.footerItems
                .map(
                  (item) => RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${item.title}: ",
                          style: AppTextStyles.bodySecondary(context).copyWith(
                            color:
                                item.titleColor ??
                                AppThemeTokens.of(context).textSecondary,
                            fontWeight: item.titleWeight,
                          ),
                        ),
                        TextSpan(
                          text: item.value,
                          style: AppTextStyles.body(context).copyWith(
                            color:
                                item.valueColor ??
                                AppThemeTokens.of(context).textPrimary,
                            fontWeight: item.valueWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeManager(
    BuildContext context,
    String value,
    Color background,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
