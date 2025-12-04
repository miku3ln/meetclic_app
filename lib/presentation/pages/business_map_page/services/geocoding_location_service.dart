import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../models/search_location_info_model.dart';

class GeocodingLocationService {
  Future<SearchLocationInfoModel> getLocationInfoFromCoordinates(
    double lat,
    double lng,
  ) async {
    if (kIsWeb) {
      // 🌐 Fallback para web usando OpenStreetMap / Nominatim
      return _getFromNominatim(lat, lng);
    }

    // 📱 Android / iOS / otros soportados
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return SearchLocationInfoModel(latitude: lat, longitude: lng);
      }
      final place = placemarks.first;

      return SearchLocationInfoModel(
        latitude: lat,
        longitude: lng,
        street: place.street,
        city: place.locality ?? place.subAdministrativeArea,
        state: place.administrativeArea,
        country: place.country,
      );
    } catch (e) {
      print('❌ Error geocoding nativo: $e');
      return SearchLocationInfoModel(latitude: lat, longitude: lng);
    }
  }

  Future<SearchLocationInfoModel> _getFromNominatim(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=$lat&lon=$lng&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'meetclic-app/1.0'},
      );

      if (response.statusCode != 200) {
        print('⚠️ Nominatim status: ${response.statusCode}');
        return SearchLocationInfoModel(latitude: lat, longitude: lng);
      }

      final data = jsonDecode(response.body);
      final address = data['address'] ?? {};

      return SearchLocationInfoModel(
        latitude: lat,
        longitude: lng,
        street: address['road'],
        city:
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['suburb'],
        state: address['state'],
        country: address['country'],
      );
    } catch (e) {
      print('❌ Error en Nominatim: $e');
      return SearchLocationInfoModel(latitude: lat, longitude: lng);
    }
  }
}
