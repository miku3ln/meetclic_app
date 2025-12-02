import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/business_data.dart';
import 'package:meetclic_app/presentation/widgets/gamified-reward-card/organisms/rewards_list_view.dart';

class GamificationBusinessSection extends StatefulWidget {
  final BusinessData businessManagementData;

  const GamificationBusinessSection({
    super.key,
    required this.businessManagementData,
  });

  @override
  State<GamificationBusinessSection> createState() =>
      _GamificationBusinessSectionState();
}

class _GamificationBusinessSectionState
    extends State<GamificationBusinessSection> {
  final TextEditingController _searchController = TextEditingController();
  List<RewardItemModel> filteredItems = [];

  final List<RewardItemModel> rewardItems = [
    RewardItemModel(
      imageUrl:
          'https://static.vecteezy.com/system/resources/previews/015/452/522/non_2x/discount-icon-in-trendy-flat-style-isolated-on-background-discount-icon-page-symbol-for-your-web-site-design-discount-icon-logo-app-ui-discount-icon-eps-vector.jpg',
      title: '5% Descuento',
      description: 'Canjea 5% de descuento por solo 150 Yapitas.',
      onTap: () => print('Seleccionaste 5% descuento'),
      badgeText: '50 Yapitas',
    ),
    RewardItemModel(
      imageUrl:
          'https://www.shutterstock.com/image-vector/40-percent-promotional-discount-banner-600nw-2624041783.jpg',
      title: 'Reputación +',
      description: 'Mejora tu reputación en la comunidad por 300 Yapitas.',
      onTap: () => print('Reputación mejorada'),
      badgeText: '50 Yapitas',
    ),
    RewardItemModel(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQCJubKnz9sWwjr_11iDCqMywnm0wslZJDww&s',
      title: 'Reputación +',
      description: 'Mejora tu reputación en la comunidad por 300 Yapitas.',
      onTap: () => print('Reputación mejorada'),
      badgeText: '50 Yapitas',
    ),
    RewardItemModel(
      imageUrl:
          'https://www.shutterstock.com/image-vector/66-discount-flash-sale-background-260nw-2628707315.jpg',
      title: 'Descuento 66%',
      description: 'Descuento por tiempo limitado en productos especiales.',
      onTap: () => print('Descuento 66%'),
      badgeText: '50 Yapitas',
    ),
    RewardItemModel(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRLKI6E4mZUb6iCkm9sOHvdlCO_yvzdw4nQQ&s',
      title: 'Reputación Extra',
      description: 'Aumenta tu visibilidad en la plataforma.',
      onTap: () => print('Reputación extra'),
      badgeText: '50 Yapitas',
    ),
    RewardItemModel(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTZB4FBPzP-D0iP6fMFVOTxjNOZiAsSId_OA&s',
      title: 'Reputación Premium',
      description: 'Reputación nivel premium con solo 500 Yapitas.',
      onTap: () => print('Reputación premium'),
      badgeText: '50 Yapitas',
    ),
  ];

  @override
  void initState() {
    super.initState();
    filteredItems = rewardItems;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = rewardItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Campo de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Lista de Premios ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar recompensa...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        // 🧩 Lista de recompensas filtradas
        Expanded(child: RewardsListView(items: filteredItems)),
      ],
    );
  }
}
