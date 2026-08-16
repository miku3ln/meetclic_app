import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/pagination_response.dart';

class PosResponsive {
  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    return shortest >= tabletBreakpoint;
  }

  static bool isMobile(BuildContext context) => !isTablet(context);

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isMobilePortrait(BuildContext context) =>
      isMobile(context) && isPortrait(context);
}


class ReceiptUtils {
  ReceiptUtils._();

  // ============================================================
  // ROOT
  // ============================================================
// ============================================================
// EMPLOYEE
// ============================================================

  static Map<String, dynamic> employeeCustomer(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = employee(receipt)['customer'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

// ============================================================
// ORDER
// ============================================================

  static String orderType(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    switch (serviceType(receipt)) {
      case 'DINE_IN':
        return 'Para Servirse';

      case 'TAKEAWAY':
        return 'Para Llevar';

      case 'DELIVERY':
        return 'Delivery';

      default:
        return serviceType(receipt);
    }
  }

  static IconData orderIcon(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    switch (serviceType(receipt)) {
      case 'DINE_IN':
        return Icons.restaurant;

      case 'TAKEAWAY':
        return Icons.shopping_bag;

      case 'DELIVERY':
        return Icons.delivery_dining;

      default:
        return Icons.shopping_bag_outlined;
    }
  }

// ============================================================
// PAYMENT
// ============================================================

  static String paymentProvider(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return payment(receipt)['provider']?.toString() ?? '';
  }

  static String paymentReference(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return payment(receipt)['reference']?.toString() ?? '';
  }

// ============================================================
// STATUS
// ============================================================

  static String statusName(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = status(receipt).toUpperCase();

    switch (value) {
      case 'PENDING':
        return 'Pendiente';

      case 'ISSUED':
        return 'Emitido';

      case 'COLLECTED':
        return 'Cobrado';

      case 'CANCELED':
        return 'Cancelado';

      case 'ELECTRONIC_REJECTED':
        return 'Rechazado';

      case 'ELECTRONIC_ISSUED':
        return 'Facturado';

      default:
        return status(receipt);
    }
  }
  static Map<String, dynamic> data(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return receipt?.data ?? {};
  }

  static Map<String, dynamic> all(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = data(receipt)['all'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  // ============================================================
  // HEADER
  // ============================================================

  static Map<String, dynamic> header(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['header'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static String receiptNumber(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return header(receipt)['id']?.toString() ?? '';
  }

  static String invoiceCode(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return header(receipt)['invoice_code']?.toString() ?? '';
  }

  static String status(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return header(receipt)['status']?.toString() ?? '';
  }

  static String invoiceDate(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return header(receipt)['invoice_date']?.toString() ?? '';
  }

  // ============================================================
  // META
  // ============================================================

  static Map<String, dynamic> meta(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['meta'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static String ticketCode(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return meta(receipt)['ticket_code']?.toString() ?? '';
  }

  static String serviceType(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return meta(receipt)['service_type']?.toString() ?? '';
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  static Map<String, dynamic> customer(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['customer'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static Map<String, dynamic> employee(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['employee'];

    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static String customerName(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return _fullName(customer(receipt));
  }

  static String employeeName(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final employeeData = employee(receipt);

    final user = employeeData['user'];

    if (user is Map && user['name'] != null) {
      return user['name'].toString();
    }

    return _fullName(
      employeeData['customer'] is Map
          ? Map<String, dynamic>.from(employeeData['customer'])
          : {},
    );
  }

  static String customerDocument(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return customer(receipt)['identification_document']?.toString() ?? '';
  }

  static String customerIdentificationType(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = customer(receipt)['identification_type'];

    if (value is Map) {
      return value['name']?.toString() ?? '';
    }

    return '';
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  static List<Map<String, dynamic>> products(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['details'];

    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String productName(Map<String, dynamic> product) {
    return product['name']?.toString() ?? 'Producto';
  }

  static String productCode(Map<String, dynamic> product) {
    return product['code']?.toString() ?? '';
  }

  static double productQuantity(Map<String, dynamic> product) {
    return _double(product['quantity']);
  }

  static double productUnitPrice(Map<String, dynamic> product) {
    return _double(product['unit_price']);
  }

  static double productTotal(Map<String, dynamic> product) {
    return _double(product['total']);
  }

  static String productType(Map<String, dynamic> product) {
    return product['product_type']?.toString() ?? '';
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  static List<Map<String, dynamic>> payments(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = all(receipt)['payments'];

    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Map<String, dynamic> payment(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final items = payments(receipt);

    return items.isNotEmpty ? items.first : {};
  }

  static String paymentMethod(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return payment(receipt)['payment_method']?.toString() ?? '';
  }

  static double paymentAmount(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return _double(payment(receipt)['amount']);
  }

  // ============================================================
  // TOTALS
  // ============================================================

  static double subtotal(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return _double(header(receipt)['subtotal']);
  }

  static double discount(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return _double(header(receipt)['discount_value']);
  }

  static double taxes(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    return _double(header(receipt)['value_taxes']);
  }

  static double total(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final invoiceTotal = _double(
      header(receipt)['invoice_value'],
    );

    if (invoiceTotal > 0) {
      return invoiceTotal;
    }

    return products(receipt).fold<double>(
      0,
          (sum, product) {
        return sum + productTotal(product);
      },
    );
  }

  // ============================================================
  // FORMATOS
  // ============================================================

  static String currency(dynamic value) {
    final number = _double(value);

    final formatter = NumberFormat('#,##0.00', 'en_US');

    return '\$${formatter.format(number)}';
  }

  static String date(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = DateTime.tryParse(invoiceDate(receipt));

    if (value == null) {
      return '';
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  static String hour(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final value = DateTime.tryParse(invoiceDate(receipt));

    if (value == null) {
      return '';
    }

    return DateFormat('HH:mm').format(value);
  }

  // ============================================================
  // PRIVADOS
  // ============================================================

  static String _fullName(Map<String, dynamic> customer) {
    final people = customer['people'];

    if (people is! Map) {
      return '';
    }

    final name = people['name']?.toString() ?? '';
    final lastName = people['last_name']?.toString() ?? '';

    return [
      name,
      lastName,
    ].where((value) => value.trim().isNotEmpty).join(' ');
  }

  static double _double(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class BusinessManagerUtil {
  final Map<String, dynamic> _data;

  BusinessManagerUtil(dynamic data)
      : _data = data is Map
      ? Map<String, dynamic>.from(data)
      : {};

  // ============================================================
  // GENERAL
  // ============================================================

  dynamic get(String key) => _data[key];

  Map<String, dynamic> get raw => _data;

  // ============================================================
  // BUSINESS
  // ============================================================

  Map<String, dynamic> get business {
    final value = _data['business'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  dynamic businessValue(String key) {
    return business[key];
  }

  int? get businessId => _toInt(business['id']);

  String get description => _toString(business['description']);

  String get title => _toString(business['title']);

  String get email => _toString(business['email']);

  String get phone => _toString(business['phone_value']);

  String get street1 => _toString(business['street_1']);

  String get street2 => _toString(business['street_2']);

  double? get latitude => _toDouble(business['street_lat']);

  double? get longitude => _toDouble(business['street_lng']);

  int? get userId => _toInt(business['user_id']);

  int? get businessSubcategoryId =>
      _toInt(business['business_subcategories_id']);

  String get status => _toString(business['status']);

  double? get qualification =>
      _toDouble(business['qualification']);

  String get source => _toString(business['source']);

  String get country => _toString(business['countries']);

  int? get countryId => _toInt(business['countries_id']);

  String get zone => _toString(business['zone']);

  int? get zoneId => _toInt(business['zone_id']);

  String get city => _toString(business['city']);

  int? get cityId => _toInt(business['city_id']);

  String get province => _toString(business['province']);

  int? get provinceId => _toInt(business['province_id']);

  String get businessSubcategory =>
      _toString(business['business_subcategories']);

  String get businessCategory =>
      _toString(business['business_categories']);

  String get pageUrl => _toString(business['page_url']);

  String get optionsMap => _toString(business['options_map']);

  // ============================================================
  // SCHEDULES
  // ============================================================

  List<Map<String, dynamic>> get schedules {
    final value = _data['schedules'];

    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int get schedulesCount => schedules.length;

  Map<String, dynamic>? scheduleAt(int index) {
    if (index < 0 || index >= schedules.length) {
      return null;
    }

    return schedules[index];
  }

  // ============================================================
  // DATE CURRENT DATA
  // ============================================================

  Map<String, dynamic> get dateCurrentData {
    final value = _data['dateCurrentData'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  String get currentDateFormat =>
      _toString(dateCurrentData['format']);

  String get currentDateNotFormat =>
      _toString(dateCurrentData['not-format']);

  // ============================================================
  // CASH
  // ============================================================

  List<dynamic> get cash {
    final value = _data['cash'];

    if (value is List) {
      return value;
    }

    return [];
  }

  int get cashCount => cash.length;

  // ============================================================
  // CONVERSIONES SEGURAS
  // ============================================================

  static String _toString(dynamic value) {
    if (value == null) return '';

    return value.toString();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}


String? _toString(dynamic value) {
  return value?.toString();
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString());
}

class BusinessCurrentDateModel {
  final String? format;
  final String? notFormat;

  const BusinessCurrentDateModel({this.format, this.notFormat});

  factory BusinessCurrentDateModel.fromJson(Map<String, dynamic> json) {
    return BusinessCurrentDateModel(
      format: _toString(json['format']),
      notFormat: _toString(json['not-format']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'format': format, 'not-format': notFormat};
  }
}

class BusinessScheduleTimeModel {
  final int? id;
  final String? modelBreakdown;
  final bool? error;
  final String? msj;
  final bool? init;

  const BusinessScheduleTimeModel({
    this.id,
    this.modelBreakdown,
    this.error,
    this.msj,
    this.init,
  });

  factory BusinessScheduleTimeModel.fromJson(Map<String, dynamic> json) {
    return BusinessScheduleTimeModel(
      id: _toInt(json['id']),
      modelBreakdown: _toString(json['modelBreakdown']),
      error: json['error'] as bool?,
      msj: _toString(json['msj']),
      init: json['init'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelBreakdown': modelBreakdown,
      'error': error,
      'msj': msj,
      'init': init,
    };
  }
}

class BusinessScheduleDataModel {
  final BusinessScheduleTimeModel? startTime;
  final BusinessScheduleTimeModel? endTime;

  const BusinessScheduleDataModel({this.startTime, this.endTime});

  factory BusinessScheduleDataModel.fromJson(Map<String, dynamic> json) {
    return BusinessScheduleDataModel(
      startTime: json['start_time'] is Map
          ? BusinessScheduleTimeModel.fromJson(
        Map<String, dynamic>.from(json['start_time']),
      )
          : null,
      endTime: json['end_time'] is Map
          ? BusinessScheduleTimeModel.fromJson(
        Map<String, dynamic>.from(json['end_time']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'start_time': startTime?.toJson(), 'end_time': endTime?.toJson()};
  }
}

class BusinessScheduleConfigModel {
  final bool? type;
  final List<BusinessScheduleDataModel> data;

  const BusinessScheduleConfigModel({this.type, this.data = const []});

  factory BusinessScheduleConfigModel.fromJson(Map<String, dynamic> json) {
    return BusinessScheduleConfigModel(
      type: json['type'] as bool?,
      data: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map>()
          .map(
            (item) => BusinessScheduleDataModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'data': data.map((item) => item.toJson()).toList()};
  }
}

class BusinessScheduleModel {
  final int? id;
  final String? name;
  final String? text;
  final int? type;
  final bool? modelDay;
  final int? businessId;
  final String? status;
  final int? weightDay;
  final BusinessScheduleConfigModel? configTypeSchedule;

  const BusinessScheduleModel({
    this.id,
    this.name,
    this.text,
    this.type,
    this.modelDay,
    this.businessId,
    this.status,
    this.weightDay,
    this.configTypeSchedule,
  });

  factory BusinessScheduleModel.fromJson(Map<String, dynamic> json) {
    return BusinessScheduleModel(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      text: _toString(json['text']),
      type: _toInt(json['type']),
      modelDay: json['modelDay'] as bool?,
      businessId: _toInt(json['business_id']),
      status: _toString(json['status']),
      weightDay: _toInt(json['weight_day']),
      configTypeSchedule: json['configTypeSchedule'] is Map
          ? BusinessScheduleConfigModel.fromJson(
        Map<String, dynamic>.from(json['configTypeSchedule']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'type': type,
      'modelDay': modelDay,
      'business_id': businessId,
      'status': status,
      'weight_day': weightDay,
      'configTypeSchedule': configTypeSchedule?.toJson(),
    };
  }
}

class BusinessModelInformation {
  final int? id;
  final dynamic optionsMap;
  final String? description;
  final String? title;
  final String? email;
  final String? pageUrl;
  final String? phoneValue;
  final String? street1;
  final String? street2;
  final double? streetLat;
  final double? streetLng;
  final int? userId;
  final int? businessSubcategoriesId;
  final String? status;
  final double? qualification;
  final String? source;
  final String? countries;
  final int? countriesId;
  final String? zone;
  final int? zoneId;
  final String? city;
  final int? cityId;
  final String? province;
  final int? provinceId;
  final String? businessSubcategories;
  final String? businessCategories;

  const BusinessModelInformation({
    this.id,
    this.optionsMap,
    this.description,
    this.title,
    this.email,
    this.pageUrl,
    this.phoneValue,
    this.street1,
    this.street2,
    this.streetLat,
    this.streetLng,
    this.userId,
    this.businessSubcategoriesId,
    this.status,
    this.qualification,
    this.source,
    this.countries,
    this.countriesId,
    this.zone,
    this.zoneId,
    this.city,
    this.cityId,
    this.province,
    this.provinceId,
    this.businessSubcategories,
    this.businessCategories,
  });

  factory BusinessModelInformation.fromJson(Map<String, dynamic> json) {
    return BusinessModelInformation(
      id: _toInt(json['id']),
      optionsMap: json['options_map'],
      description: _toString(json['description']),
      title: _toString(json['title']),
      email: _toString(json['email']),
      pageUrl: _toString(json['page_url']),
      phoneValue: _toString(json['phone_value']),
      street1: _toString(json['street_1']),
      street2: _toString(json['street_2']),
      streetLat: _toDouble(json['street_lat']),
      streetLng: _toDouble(json['street_lng']),
      userId: _toInt(json['user_id']),
      businessSubcategoriesId: _toInt(json['business_subcategories_id']),
      status: _toString(json['status']),
      qualification: _toDouble(json['qualification']),
      source: _toString(json['source']),
      countries: _toString(json['countries']),
      countriesId: _toInt(json['countries_id']),
      zone: _toString(json['zone']),
      zoneId: _toInt(json['zone_id']),
      city: _toString(json['city']),
      cityId: _toInt(json['city_id']),
      province: _toString(json['province']),
      provinceId: _toInt(json['province_id']),
      businessSubcategories: _toString(json['business_subcategories']),
      businessCategories: _toString(json['business_categories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'options_map': optionsMap,
      'description': description,
      'title': title,
      'email': email,
      'page_url': pageUrl,
      'phone_value': phoneValue,
      'street_1': street1,
      'street_2': street2,
      'street_lat': streetLat,
      'street_lng': streetLng,
      'user_id': userId,
      'business_subcategories_id': businessSubcategoriesId,
      'status': status,
      'qualification': qualification,
      'source': source,
      'countries': countries,
      'countries_id': countriesId,
      'zone': zone,
      'zone_id': zoneId,
      'city': city,
      'city_id': cityId,
      'province': province,
      'province_id': provinceId,
      'business_subcategories': businessSubcategories,
      'business_categories': businessCategories,
    };
  }
}

class BusinessManagerSummaryModel {
  final BusinessModelInformation? business;
  final List<BusinessScheduleModel> schedules;
  final BusinessCurrentDateModel? dateCurrentData;
  final List<dynamic> cash;

  const BusinessManagerSummaryModel({
    this.business,
    this.schedules = const [],
    this.dateCurrentData,
    this.cash = const [],
  });

  factory BusinessManagerSummaryModel.fromJson(Map<String, dynamic> json) {
    return BusinessManagerSummaryModel(
      business: json['business'] is Map
          ? BusinessModelInformation.fromJson(Map<String, dynamic>.from(json['business']))
          : null,

      schedules: json['schedules'] is List
          ? (json['schedules'] as List)
          .whereType<Map>()
          .map(
            (item) => BusinessScheduleModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : const [],

      dateCurrentData: json['dateCurrentData'] is Map
          ? BusinessCurrentDateModel.fromJson(
        Map<String, dynamic>.from(json['dateCurrentData']),
      )
          : null,

      cash: json['cash'] is List ? List<dynamic>.from(json['cash']) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business': business?.toJson(),
      'schedules': schedules.map((item) => item.toJson()).toList(),
      'dateCurrentData': dateCurrentData?.toJson(),
      'cash': cash,
    };
  }
}
