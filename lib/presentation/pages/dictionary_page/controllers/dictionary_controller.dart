import 'dart:async';

import 'package:flutter/material.dart';

import '../models/word_item.dart';
import '../repositories/dictionary_repository.dart';
import '../services/mock_dictionary_service.dart';

class DictionaryController extends ChangeNotifier {
  DictionaryController(this._repo);

  final DictionaryRepository _repo;

  // ---------- estado público ----------
  final List<WordItem> items = [];
  bool isInitialLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isRefreshing = false;
  bool scrollLocked = false;

  // ---------- criterios ----------
  String language = 'ES';
  int selectedCategory = 0;
  String query = '';

  // ---------- paginación ----------
  int _page = 1;
  final int _pageSize = 10;
  int total = -1;

  // ---------- scroll ----------
  static const double infiniteThreshold = 250.0;
  static const double pullToRefreshDistance = 80.0;
  late final ScrollController scrollController;
  double _lastPixels = 0.0;
  bool _wasScrolling = false;
  bool _armedForTopRefresh = false; // latch

  Timer? _debounce;

  // ===== lifecycle =====
  void attachScrollHandlers(ScrollController controller) {
    scrollController = controller;
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.position.isScrollingNotifier.addListener(
        _onScrollStateChange,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.position.isScrollingNotifier.removeListener(
      _onScrollStateChange,
    );
    super.dispose();
  }

  // ===== acciones UI =====
  void onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      query = q.trim();
      loadInitial();
    });
  }

  void setLanguage(String lang) {
    language = lang;
    loadInitial();
  }

  void setCategory(int index) {
    selectedCategory = index;
    loadInitial();
  }

  void lockScroll(bool v) {
    if (scrollLocked == v) return;
    scrollLocked = v;
    notifyListeners();
  }

  getDataManagerRows(PageData<DictionaryWord> dataResult) {
    //TODO ROW DICTIONARY
    final List<WordItem> data = [];
    final List<DictionaryWord> rows = dataResult.rows;
    late bool viewImage = false;
    rows.forEach((row) {
      print(row); // o row.campoX
      final List<DictionaryTag> tagsDictionary = row.tags;
      final List<String> classData = [];
      tagsDictionary.forEach((rowTag) {
        classData.add(rowTag.shortCode);
      });
      late WordItem setPush = WordItem(
        classes: classData,
        phoneme: row.phoneme,
        title: row.value,
        subtitle: row.translationRaw,
        description: row.description,
        image: "",
        /* image: viewImage
            ? "https://www.shutterstock.com/image-vector/brown-wooden-chair-backrest-soft-600nw-1329785732.jpg"
            : "",*/
      );
      viewImage = !viewImage;

      data.add(setPush);
    });

    return data;
  }

  // ===== data =====
  Future<void> loadInitial() async {
    isInitialLoading = true;
    _resetPagination();
    notifyListeners();
    int entityManagerId = getManagerId();
    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: _page,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );
    List<WordItem> data = [];
    final dataResult = dataManager.data;
    if (dataManager.success) {
      total = dataResult.total;
      data = getDataManagerRows(dataResult);
    }
    items.addAll(data);
    hasMore = isAllowGetData();
    isInitialLoading = false;
    notifyListeners();
  }

  int getManagerId() {
    return language == "KI" ? 1 : 2;
  }

  bool isAllowGetData() {
    return !(items.length == total);
  }

  Future<void> reload() async {
    isRefreshing = true;
    _resetPagination();
    notifyListeners();
    int entityManagerId = getManagerId();

    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: 1,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );
    List<WordItem> data = [];

    final dataResult = dataManager.data;
    if (dataManager.success) {
      total = dataResult.total;
      data = getDataManagerRows(dataResult);
    }
    items.addAll(data);
    hasMore = isAllowGetData();
    _page = 1;
    isRefreshing = false;
    lockScroll(false);
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || scrollLocked) return;

    isLoadingMore = true;
    notifyListeners();
    int entityManagerId = getManagerId();

    final nextPage = _page + 1;
    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: nextPage,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );

    List<WordItem> data = [];
    final dataResult = dataManager.data;
    if (dataManager.success) {
      total = dataResult.total;
      data = getDataManagerRows(dataResult);
    }
    _page = nextPage;
    items.addAll(data);
    hasMore = isAllowGetData();
    isLoadingMore = false;
    notifyListeners();
  }

  void _resetPagination() {
    isLoadingMore = false;
    hasMore = true;
    _page = 1;
    items.clear();
  }

  // ===== scroll handlers =====
  void _onScroll() {
    if (scrollLocked) return;
    final pos = scrollController.position;

    // Near-bottom → more
    final nearBottom = pos.pixels >= (pos.maxScrollExtent - infiniteThreshold);
    if (nearBottom && !isLoadingMore && hasMore && !isInitialLoading) {
      loadMore();
    }

    // Latch de pull-to-refresh
    if (pos.pixels < pos.minScrollExtent - pullToRefreshDistance) {
      _armedForTopRefresh = true;
    }

    // Desarmar SOLO si el usuario se aleja del top (no por rebote)
    final goingDown = pos.pixels > _lastPixels;
    if (goingDown && pos.pixels >= pos.minScrollExtent + 1) {
      _armedForTopRefresh = false;
    }

    _lastPixels = pos.pixels;
  }

  void _onScrollStateChange() {
    final pos = scrollController.position;
    final isScrolling = pos.isScrollingNotifier.value;

    if (!isScrolling && _wasScrolling) {
      final atTop = pos.pixels <= pos.minScrollExtent + 0.5;
      if (atTop && _armedForTopRefresh && !isRefreshing) {
        _armedForTopRefresh = false;
        lockScroll(true);
        if (pos.pixels < pos.minScrollExtent + 0.5) {
          scrollController.jumpTo(pos.minScrollExtent);
        }
        // dispara reload sin bloquear el hilo
        unawaited(reload());
      }
    }
    _wasScrolling = isScrolling;
  }
}
