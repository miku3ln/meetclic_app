import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../domain/services/session_service.dart';
import '../../../../infrastructure/config/server_config.dart';
import '../models/product_category.dart';
import '../models/product_subcategory.dart';

class ProductCatalogService {
  Future<List<ProductCategory>> getCategories() async {
    try {
      final token = SessionService().apiToken;
      final businessId = SessionService().businessId;

      final uri = Uri.parse(
        '${ServerConfig.baseUrl}/pointsales/products-categories-by-business',
      ).replace(
        queryParameters: {
          'current': '-1',
          'rowCount': '-1',
          'searchPhrase': '',
          'business_id': businessId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final List<dynamic> rows = jsonDecode(response.body);

      return rows
          .map((e) => ProductCategory.fromMap(e))
          .toList();
    } catch (e, s) {
      debugPrint('Error getCategories: $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }

}