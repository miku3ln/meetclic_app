import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../../shared/pagination_response.dart';
import '../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../organisms/items/pos_items_content.dart';
import '../../../organisms/ps_toogle_group.dart';

class PosItemsController extends ChangeNotifier {
  final PosItemsManagementApi api;

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

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
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
                _buildTaxChip(context, tax+"%"),
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
                    value: tax+"%",
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
                    icon: Icons.scale_outlined,
                    title: "Tipo de Medida",
                    value: measureType,
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
                    icon: Icons.inventory_2_outlined,
                    title: "Cantidad",
                    value: "$quantity $unit",
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
          ? Icon(Icons.inventory_2_outlined, color: colors.iconMuted, size: 30)
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

  Widget _buildTaxChip(BuildContext context, String value) {
    final colors = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.badge,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.badgeText,
        ),
      ),
    );
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

  const _InfoColumn({
    required this.icon,
    required this.title,
    required this.value,
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
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.iconPrimary),
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
