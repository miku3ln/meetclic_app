import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/util-manager.dart';

import '../../../../../../../shared/pagination_response.dart';
import '../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../organisms/items/pos_items_content.dart';
import '../../../organisms/ps_toogle_group.dart';

class PosItemsController extends ChangeNotifier {
  final PosItemsManagementRepository api;

  PosItemsController({required this.api});

  final List<GenericListItem<Map<String, dynamic>>> items = [];

  int currentPage = 1;
  final int rowCount = 10;
  int total = 0;

  bool isLoading = false;
  bool hasInitialLoadFinished = false;

  String searchCode = '';

  bool get hasData => items.isNotEmpty;

  bool get hasMore => items.length < total;

  Future<void> loadInitial() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    final response = await api.fetchPage(
      current: currentPage,
      rowCount: rowCount,
      searchPhrase: searchCode,
    );

    items.addAll(response.rows);
    total = response.total;

    hasInitialLoadFinished = true;
    isLoading = false;

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    currentPage++;

    final response = await api.fetchPage(
      current: currentPage,
      rowCount: rowCount,
      searchPhrase: searchCode,
    );

    items.addAll(response.rows);
    total = response.total;

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    currentPage = 1;
    total = 0;

    items.clear();

    hasInitialLoadFinished = false;

    notifyListeners();

    await loadInitial();
  }
}

class ProductListCard extends StatelessWidget {
  final GenericListItem<Map<String, dynamic>> item;
  final VoidCallback onTap;

  const ProductListCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final data = item.data ?? {};

    final stock = data['stock'] ?? {};
    final classification = data['classification'] ?? {};

    final quantity = stock['quantity'] ?? 0;
    final unit = stock['unit'] ?? '';

    final category = data['category'] ?? '';
    final subcategory = data['subcategory'] ?? '';

    final taxData = data['tax'];
    final tax = (taxData['value_percentage'].toString() ?? '');
    final measure_type_management = data["measure_type_management"];
    final measureType = measure_type_management["value"] ?? '';

    final inventoryType = classification['inventory_type'] ?? '';
    final details = jsonDecode(data['details_all']);

    Color colorIconTax = colors.buttonPrimaryBackground;
    Color colorAmount = Colors.orange;
    IconData iconAmount=Icons.inventory_2_outlined;
    if (quantity < 0) {
       colorAmount = Colors.redAccent;
       iconAmount=Icons.warning_amber_rounded;
    }
    if (details['product']['has_tax'] == 1) {
      colorIconTax = Colors.orange;
    }
    final productMeasureTypeRoot = details['product_measure_type'];
    var typeMeasureId = productMeasureTypeRoot['id'].toString();
    final configuration = MeasureTypeUtils.getConfiguration(
      typeMeasureId: typeMeasureId,
    );
    Color managerTypeMeasureColor = configuration.borderColor;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(color: configuration.borderColor, width: 6),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            /// HEADER
            Row(
              children: [
                _buildAvatar(context, item.image),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data['code']}",
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTypeChip(context, inventoryType),
                const SizedBox(width: 8),
                _buildStateManager(context, details),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _InfoColumn(
                    icon: Icons.category_outlined,
                    title: "Categoría",
                    value: category,
                  ),
                ),

                Expanded(
                  child: _InfoColumn(
                    icon: Icons.account_tree_outlined,
                    title: "Subcategoría",
                    value: subcategory,
                  ),
                ),

                Expanded(
                  child: _InfoColumn(
                    icon: Icons.receipt_long_outlined,
                    title: "Impuesto",
                    value: tax + "%",
                    colorIcon: colorIconTax,
                    backgroundIcon: AppColors.shade(colorIconTax, 90),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 2 FILAS - 3 COLUMNAS
            Row(
              children: [
                Expanded(
                  child: _InfoColumn(
                    icon: configuration.icon,
                    title: "Tipo de Medida",
                    value: measureType,
                    backgroundIcon: AppColors.shade(
                      managerTypeMeasureColor,
                      90,
                    ),
                    colorIcon: managerTypeMeasureColor,
                  ),
                ),
                Expanded(
                  child: _InfoColumn(
                    icon: Icons.widgets_outlined,
                    title: "Tipo",
                    value: _getInventoryLabel(inventoryType),
                  ),
                ),

                Expanded(
                  child: _InfoColumn(
                    icon: iconAmount,
                    title: "Cantidad",
                    value: "$quantity $unit",
                    colorIcon: colorAmount,
                    backgroundIcon: AppColors.shade(colorAmount, 90),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? image) {
    final colors = AppThemeTokens.of(context);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceMuted,
      ),
      clipBehavior: Clip.antiAlias,
      child: image == null
          ? Icon(Icons.error_outlined, color: colors.iconMuted, size: 30)
          : Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.inventory_2_outlined,
                  color: colors.iconMuted,
                );
              },
            ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String value) {
    final colors = AppThemeTokens.of(context);

    Color bgColor = colors.successBackground;
    Color textColor = colors.success;

    String text = value;

    if (value.contains(InventoryType.raw.id)) {
      bgColor = colors.successBackground;
      textColor = colors.success;
      text = InventoryType.raw.value;
    }

    if (value.contains(InventoryType.processed.id)) {
      bgColor = colors.warningBackground;
      textColor = colors.warning;
      text = InventoryType.processed.value;
    }

    if (value.contains(InventoryType.forSale.id)) {
      bgColor = colors.infoBackground;
      textColor = colors.info;
      text = InventoryType.forSale.value;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBadgeManager(
    BuildContext context,
    String value,
    Color colorBackground,
    Color colorText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorText,
        ),
      ),
    );
  }

  Widget _buildStateManager(BuildContext context, detailsData) {
    final colors = AppThemeTokens.of(context);
    final productData = detailsData['product'];
    bool isActive = productData['state'] == 'ACTIVE' ? true : false;
    final title = isActive ? 'ACTIVO' : 'INACTIVO';
    Color colorBackground = isActive ? colors.success : colors.warning;
    Color colorText = colors.badge;
    return _buildBadgeManager(context, title, colorBackground, colorText);
  }

  String _getInventoryLabel(String value) {
    if (value.contains(InventoryType.raw.id)) {
      return InventoryType.raw.value;
    }

    if (value.contains(InventoryType.processed.id)) {
      return InventoryType.processed.value;
    }

    if (value.contains(InventoryType.forSale.id)) {
      return InventoryType.forSale.value;
    }

    return '-';
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? backgroundIcon;
  final Color? colorIcon;

  const _InfoColumn({
    required this.icon,
    required this.title,
    required this.value,
    this.backgroundIcon,
    this.colorIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundIcon ?? colors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorIcon ?? colors.iconPrimary),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
