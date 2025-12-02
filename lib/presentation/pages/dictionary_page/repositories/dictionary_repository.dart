// pages/dictionary_page/repositories/dictionary_repository.dart
import '../../../../domain/models/api_response_model.dart';
import '../models/word_item.dart';
import '../services/dictionary_service.dart';
import '../services/mock_dictionary_service.dart';

class DictionaryRepository {
  final DictionaryService service;
  const DictionaryRepository(this.service);

  Future<List<WordItem>> getPage({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  }) {
    return service.getDataRegisters(
      current: current,
      rowCount: rowCount,
      searchPhrase: searchPhrase,
      entity_manager_id: entity_manager_id,
      categoryIndex: categoryIndex,
    );
  }

  Future<ApiResponseModel<PageData<DictionaryWord>>>
  getDataDictionaryByLanguage({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  }) {
    return service.getDataDictionaryByLanguage(
      current: current,
      rowCount: rowCount,
      searchPhrase: searchPhrase,
      entity_manager_id: entity_manager_id,
      categoryIndex: categoryIndex,
    );
  }
}
