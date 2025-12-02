// pages/dictionary_page/services/mock_dictionary_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../domain/models/api_response_model.dart';
import '../../../../infrastructure/config/server_config.dart';
import '../models/word_item.dart';
import 'dictionary_service.dart';

// ============================================================================
// lib/features/dictionary/domain/enums.dart
// ============================================================================
enum Status { active, inactive }

extension StatusX on Status {
  String get value => this == Status.active ? 'ACTIVE' : 'INACTIVE';

  static Status from(String? s) =>
      (s?.toUpperCase() == 'ACTIVE') ? Status.active : Status.inactive;
}

enum DictionaryCategory { grammatical, toponym, other }

extension DictionaryCategoryX on DictionaryCategory {
  static DictionaryCategory from(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'grammatical':
        return DictionaryCategory.grammatical;
      case 'toponym':
        return DictionaryCategory.toponym;
      default:
        return DictionaryCategory.other;
    }
  }
}

enum NotationType { didactic, regional, ipa, other }

extension NotationTypeX on NotationType {
  static NotationType from(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'didactic':
        return NotationType.didactic;
      case 'regional':
        return NotationType.regional;
      case 'ipa':
        return NotationType.ipa;
      default:
        return NotationType.other;
    }
  }
}

// ============================================================================
// lib/features/dictionary/data/dto.dart
// (forma EXACTA del backend; respeta nombres como 'diccionary_language_id')
// ============================================================================
class ApiDictionaryTagDto {
  final int id;
  final String name;
  final String shortCode; // short_code
  final String category;

  ApiDictionaryTagDto({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
  });

  factory ApiDictionaryTagDto.fromJson(Map<String, dynamic> json) {
    return ApiDictionaryTagDto(
      id: json['id'] as int,
      name: json['name'] as String,
      shortCode: json['short_code'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'short_code': shortCode,
    'category': category,
  };
}

class ApiPronunciationDto {
  final int id;
  final String phoneticValue; // phonetic_value
  final String notationType; // notation_type
  final String status; // 'ACTIVE' | ...
  final int wordId; // dictionary_by_words_id

  ApiPronunciationDto({
    required this.id,
    required this.phoneticValue,
    required this.notationType,
    required this.status,
    required this.wordId,
  });

  factory ApiPronunciationDto.fromJson(Map<String, dynamic> json) {
    return ApiPronunciationDto(
      id: json['id'] as int,
      phoneticValue: json['phonetic_value'] as String,
      notationType: json['notation_type'] as String,
      status: json['status'] as String,
      wordId: json['dictionary_by_words_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phonetic_value': phoneticValue,
    'notation_type': notationType,
    'status': status,
    'dictionary_by_words_id': wordId,
  };
}

class ApiDictionaryWordDto {
  final int id;
  final String translationValue; // "luz,claridad,claro"
  final String usageContext;
  final String value; // término en kichwa
  final String description;
  final String status; // 'ACTIVE' | ...
  final int diccionaryLanguageId; // (sic) typo del backend
  final List<ApiDictionaryTagDto> dictionary;
  final List<ApiPronunciationDto> pronunciations;
  final String phoneme;

  ApiDictionaryWordDto({
    required this.id,
    required this.translationValue,
    required this.usageContext,
    required this.value,
    required this.description,
    required this.status,
    required this.diccionaryLanguageId,
    required this.dictionary,
    required this.pronunciations,
    required this.phoneme,
  });

  factory ApiDictionaryWordDto.fromJson(Map<String, dynamic> json) {
    return ApiDictionaryWordDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0, // default 0

      translationValue: json['translation_value'] as String? ?? '',
      usageContext: json['usage_context'] as String? ?? '',
      value: json['value'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      phoneme: json['phoneme'] as String? ?? '',

      diccionaryLanguageId: json['diccionary_language_id'] is int
          ? json['diccionary_language_id'] as int
          : int.tryParse(json['diccionary_language_id']?.toString() ?? '') ?? 0,

      // 👇 si no viene "dictionary" o viene null, usa lista vacía
      dictionary: (json['dictionary'] as List<dynamic>? ?? const [])
          .map((e) => ApiDictionaryTagDto.fromJson(e as Map<String, dynamic>))
          .toList(),

      // 👇 igual para pronunciations
      pronunciations: (json['pronunciations'] as List<dynamic>? ?? const [])
          .map((e) => ApiPronunciationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'translation_value': translationValue,
    'usage_context': usageContext,
    'value': value,
    'description': description,
    'status': status,
    'diccionary_language_id': diccionaryLanguageId,
    'dictionary': dictionary.map((e) => e.toJson()).toList(),
    'pronunciations': pronunciations.map((e) => e.toJson()).toList(),
  };
}

class ApiPageWordsDto {
  final int total;
  final List<ApiDictionaryWordDto> rows;
  final int current;
  final int rowCount; // puede venir string en API → lo normalizamos a int

  ApiPageWordsDto({
    required this.total,
    required this.rows,
    required this.current,
    required this.rowCount,
  });

  factory ApiPageWordsDto.fromJson(Map<String, dynamic> json) {
    final rowCountRaw = json['rowCount'];
    final normalizedRowCount = rowCountRaw is int
        ? rowCountRaw
        : int.tryParse(rowCountRaw.toString()) ?? 0;

    return ApiPageWordsDto(
      total: json['total'] as int,
      rows: (json['rows'] as List<dynamic>)
          .map((e) => ApiDictionaryWordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      current: json['current'] as int,
      rowCount: normalizedRowCount,
    );
  }
}
// ============================================================================
// lib/features/dictionary/domain/models.dart
// ============================================================================
//import 'enums.dart'; TODO REVIEW

class DictionaryTag {
  final int id;
  final String name; // "Interjección"
  final String shortCode; // "interj"
  final DictionaryCategory category;

  const DictionaryTag({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
  });
}

class Pronunciation {
  final int id;
  final String phoneticValue; // "ačačaw"
  final NotationType notationType;
  final Status status;
  final int wordId;

  const Pronunciation({
    required this.id,
    required this.phoneticValue,
    required this.notationType,
    required this.status,
    required this.wordId,
  });
}

class DictionaryWord {
  final int id;
  final String value; // "achik"
  final String translationRaw; // "luz,claridad,claro"
  final List<String> translations; // ["luz","claridad","claro"]
  final String usageContext;
  final String description;
  final Status status;
  final int languageId; // normalizado del typo
  final List<DictionaryTag> tags;
  final List<Pronunciation> pronunciations;
  final String phoneme;
  const DictionaryWord({
    required this.id,
    required this.value,
    required this.translationRaw,
    required this.translations,
    required this.usageContext,
    required this.description,
    required this.status,
    required this.languageId,
    required this.tags,
    required this.pronunciations,
    required this.phoneme,
  });

  /// Utilidad: toma la primera 'didactic' si existe; si no, la primera disponible.
  String? get primaryPhonetic {
    if (pronunciations.isEmpty) return null;
    final didactic = pronunciations
        .where((p) => p.notationType == NotationType.didactic)
        .toList();
    return (didactic.isNotEmpty ? didactic.first : pronunciations.first)
        .phoneticValue;
  }
}

class PageData<T> {
  final int total;
  final List<T> rows;
  final int current;
  final int rowCount;

  const PageData({
    required this.total,
    required this.rows,
    required this.current,
    required this.rowCount,
  });
}
// ============================================================================
// lib/features/dictionary/data/mappers.dart
// ============================================================================
//import '../domain/enums.dart';
//import '../domain/models.dart'; TODO REVIEW
//import '../data/dto.dart';

class TagMapper {
  static DictionaryTag fromDto(ApiDictionaryTagDto dto) => DictionaryTag(
    id: dto.id,
    name: dto.name,
    shortCode: dto.shortCode,
    category: DictionaryCategoryX.from(dto.category),
  );
}

class PronunciationMapper {
  static Pronunciation fromDto(ApiPronunciationDto dto) => Pronunciation(
    id: dto.id,
    phoneticValue: dto.phoneticValue,
    notationType: NotationTypeX.from(dto.notationType),
    status: StatusX.from(dto.status),
    wordId: dto.wordId,
  );
}

class WordMapper {
  static DictionaryWord fromDto(ApiDictionaryWordDto dto) => DictionaryWord(
    id: dto.id,
    value: dto.value,
    phoneme: dto.phoneme,
    translationRaw: dto.translationValue,
    translations: _splitTranslations(dto.translationValue),
    usageContext: dto.usageContext,
    description: dto.description,
    status: StatusX.from(dto.status),
    languageId: dto.diccionaryLanguageId,
    // (sic)
    tags: dto.dictionary.map(TagMapper.fromDto).toList(),
    pronunciations: dto.pronunciations
        .map(PronunciationMapper.fromDto)
        .toList(),
  );

  static List<String> _splitTranslations(String raw) =>
      raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

class PageMapper {
  static PageData<DictionaryWord> fromApiPageWords(ApiPageWordsDto dto) =>
      PageData(
        total: dto.total,
        rows: dto.rows.map(WordMapper.fromDto).toList(),
        current: dto.current,
        rowCount: dto.rowCount,
      );
}
// ============================================================================
// lib/features/dictionary/presentation/view_models.dart
// (objetos pensados para UI: chips, strings formateados, etc.)
// ============================================================================
//import '../domain/enums.dart';TODO REVIEW
//import '../domain/models.dart';

class TagChipVm {
  final String label; // "Interjección"
  final String code; // "interj"
  final DictionaryCategory type; // grammatical / toponym / other

  const TagChipVm({
    required this.label,
    required this.code,
    required this.type,
  });
}

class WordListItemVm {
  final int id;
  final String value; // "achik"
  final List<String> translations; // ["luz","claridad","claro"]
  final String translationsText; // "luz · claridad · claro"
  final String? primaryPhonetic; // "ačix" | null
  final List<TagChipVm> tags; // chips para UI
  final String status; // "ACTIVE"/"INACTIVE"
  final String usageContext;
  final String description;

  const WordListItemVm({
    required this.id,
    required this.value,
    required this.translations,
    required this.translationsText,
    required this.primaryPhonetic,
    required this.tags,
    required this.status,
    required this.usageContext,
    required this.description,
  });

  factory WordListItemVm.fromDomain(DictionaryWord w) {
    return WordListItemVm(
      id: w.id,
      value: w.value,
      translations: w.translations,
      translationsText: w.translations.join(' · '),
      primaryPhonetic: w.primaryPhonetic,
      tags: w.tags
          .map(
            (t) =>
                TagChipVm(label: t.name, code: t.shortCode, type: t.category),
          )
          .toList(),
      status: w.status == Status.active ? 'ACTIVE' : 'INACTIVE',
      usageContext: w.usageContext,
      description: w.description,
    );
  }
}

class WordPageVm {
  final int total;
  final int current;
  final int rowCount;
  final List<WordListItemVm> items;

  const WordPageVm({
    required this.total,
    required this.current,
    required this.rowCount,
    required this.items,
  });

  factory WordPageVm.fromDomain(PageData<DictionaryWord> page) => WordPageVm(
    total: page.total,
    current: page.current,
    rowCount: page.rowCount,
    items: page.rows.map(WordListItemVm.fromDomain).toList(),
  );
}

// Page vacío para errores (data nunca es null)
PageData<DictionaryWord> _emptyPage(int current, int rowCount) =>
    PageData<DictionaryWord>(
      total: 0,
      rows: const [],
      current: current,
      rowCount: rowCount,
    );

// ============================================================================
// lib/features/dictionary/data/adapters.dart
// (helpers de alto nivel: JSON → DTO → Domain → ViewModel)
// ============================================================================
/*

import 'dto.dart';
import 'mappers.dart';
import '../domain/models.dart';
import '../presentation/view_models.dart';
*/
class DictionaryAdapters {
  /// Convierte el JSON crudo (Map o String) del backend a Page<DictionaryWord>.
  static PageData<DictionaryWord> parseDomainPage(dynamic source) {
    final Map<String, dynamic> map = source is String
        ? json.decode(source) as Map<String, dynamic>
        : source;
    final dto = ApiPageWordsDto.fromJson(map);
    return PageMapper.fromApiPageWords(dto);
  }

  /// Convierte el JSON crudo directamente a un ViewModel de página para UI.
  static WordPageVm parsePageVm(dynamic source) {
    final domain = parseDomainPage(source);
    return WordPageVm.fromDomain(domain);
  }
}

class MockDictionaryService implements DictionaryService {
  @override
  Future<ApiResponseModel<PageData<DictionaryWord>>>
  getDataDictionaryByLanguage({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  }) async {
    final uri = Uri.parse(
      '${ServerConfig.baseUrl}/traductor/getDictionaryByLanguage', // TODO: reemplazar por el endpoint real del diccionario
    );

    // Si tu backend espera JSON, cambia headers + body a jsonEncode(...)
    final form = <String, String>{
      'current': current.toString(),
      'rowCount': rowCount.toString(),
      'filters[entity_manager_id]': entity_manager_id.toString(),
      if (searchPhrase != null && searchPhrase.trim().isNotEmpty)
        'searchPhrase': searchPhrase.trim(),
      if (categoryIndex != null)
        'filters[category_index]': categoryIndex.toString(),
    };

    try {
      final res = await http.post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: form,
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return ApiResponseModel<PageData<DictionaryWord>>.error(
          'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Error'}',
          _emptyPage(current, rowCount),
        );
      }

      final Map<String, dynamic> root =
          jsonDecode(res.body) as Map<String, dynamic>;

      // Caso A: el backend ya envía el sobre { type, success, message, data }
      if (root.containsKey('data')) {
        return ApiResponseModel<PageData<DictionaryWord>>.fromJson(
          root,
          (dataJson) => DictionaryAdapters.parseDomainPage(dataJson),
        );
      }

      // Caso B: el backend devuelve directamente el page (sin sobre)
      final page = DictionaryAdapters.parseDomainPage(root);
      return ApiResponseModel<PageData<DictionaryWord>>(
        type: (root['type'] as int?) ?? 1,
        success: (root['success'] as bool?) ?? true,
        message: (root['message'] as String?) ?? 'OK',
        data: page,
      );
    } catch (e) {
      return ApiResponseModel<PageData<DictionaryWord>>.error(
        'Error de red o parsing: $e',
        _emptyPage(current, rowCount),
      );
    }
  }

  @override
  Future<List<WordItem>> getDataRegisters({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  }) async {
    // Simula red
    await Future.delayed(const Duration(milliseconds: 900));

    final start = (current - 1) * rowCount;
    final generated = List<WordItem>.generate(rowCount, (i) {
      final idx = start + i + 1;
      return WordItem(
        image: 'https://picsum.photos/seed/es_$idx/200/200',
        title: 'Word $idx',
        subtitle: '/wɜːd $idx/',
        description:
            'Description for word $idx in es Category=$categoryIndex, q="$searchPhrase".',
      );
    });

    final filtered = searchPhrase!.isEmpty
        ? generated
        : generated
              .where(
                (w) =>
                    w.title.toLowerCase().contains(searchPhrase.toLowerCase()),
              )
              .toList();

    // Simula fin de páginas (a partir de la 5 no hay tantos resultados)
    return current >= 5 ? filtered.take(rowCount ~/ 2).toList() : filtered;
  }
}
