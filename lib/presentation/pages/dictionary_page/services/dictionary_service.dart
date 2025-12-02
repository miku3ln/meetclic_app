// pages/dictionary_page/services/dictionary_service.dart
import '../../../../domain/models/api_response_model.dart';
import '../models/word_item.dart';
import '../services/mock_dictionary_service.dart';

abstract class DictionaryService {
  Future<List<WordItem>> getDataRegisters({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  });
  Future<ApiResponseModel<PageData<DictionaryWord>>>
  getDataDictionaryByLanguage({
    required int current,
    required int rowCount,
    required int entity_manager_id,
    String? searchPhrase,
    int? categoryIndex,
  });
}
