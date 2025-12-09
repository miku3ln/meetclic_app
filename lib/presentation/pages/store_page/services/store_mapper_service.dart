import 'package:flutter/material.dart';

import '../models/store_category_model.dart';
import '../models/store_product_model.dart';

class StoreMapperService {
  const StoreMapperService();

  List<StoreCategoryModel> buildCategories() {
    return const [
      StoreCategoryModel(id: 0, name: 'Store', icon: Icons.storefront_rounded),
      StoreCategoryModel(id: 1, name: 'Combo', icon: Icons.dashboard_customize),
      StoreCategoryModel(id: 2, name: 'Meat', icon: Icons.set_meal_outlined),
      StoreCategoryModel(id: 3, name: 'Fruit', icon: Icons.apple_outlined),
      StoreCategoryModel(id: 4, name: 'Vegetables', icon: Icons.eco_outlined),
    ];
  }

  List<StoreProductModel> buildProducts() {
    return const [
      StoreProductModel(
        id: 1,
        name: 'Beef',
        unit: '1 kg',
        price: 64,
        origin: 'Australia',
        imageUrl:
            'https://images.pexels.com/photos/65175/pexels-photo-65175.jpeg',
        categoryId: 2,
      ),
      StoreProductModel(
        id: 2,
        name: 'Cabbage',
        unit: '1 kg',
        price: 5,
        origin: 'Australia',
        imageUrl:
            'https://images.pexels.com/photos/41123/cabbage-vegetable-food-healthy-41123.jpeg',
        categoryId: 4,
      ),
      StoreProductModel(
        id: 3,
        name: 'Banana',
        unit: '1 kg',
        price: 18,
        origin: 'Australia',
        imageUrl:
            'https://images.pexels.com/photos/41957/banana-fruit-yellow-healthy-41957.jpeg',
        categoryId: 3,
      ),
      StoreProductModel(
        id: 4,
        name: 'Apples',
        unit: '1 kg',
        price: 21,
        origin: 'America',
        imageUrl:
            'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg',
        categoryId: 3,
      ),
      // Tarjeta promo (isPromo = true)
      StoreProductModel(
        id: 999,
        name: 'Promo 30% OFF',
        unit: '',
        price: 0,
        origin: '',
        imageUrl: '',
        categoryId: 0,
        isPromo: true,
      ),
    ];
  }
}
