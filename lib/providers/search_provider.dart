import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/entry.dart';

// 搜尋狀態枚舉
enum SearchStatus { initial, loading, success, error }

// 搜尋提供者
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(databaseServiceProvider));
});

// 資料庫服務提供者
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// 搜尋狀態類別
class SearchState {
  final List<Entry> results;
  final String query;
  final SearchStatus status;
  final String? errorMessage;

  SearchState({
    required this.results,
    required this.query,
    required this.status,
    this.errorMessage,
  });

  SearchState.initial()
      : results = [],
        query = '',
        status = SearchStatus.initial,
        errorMessage = null;

  SearchState copyWith({
    List<Entry>? results,
    String? query,
    SearchStatus? status,
    String? errorMessage,
  }) {
    return SearchState(
      results: results ?? this.results,
      query: query ?? this.query,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 搜尋狀態管理器
class SearchNotifier extends StateNotifier<SearchState> {
  final DatabaseService _databaseService;

  SearchNotifier(this._databaseService) : super(SearchState.initial()) {
    // 初始化資料庫
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _databaseService.initializeDatabase();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = SearchState.initial();
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      query: query,
    );

    try {
      final results = await _databaseService.searchEntries(query);
      state = state.copyWith(
        results: results,
        status: SearchStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<Entry>> getResultsByQuick(String quickCode) async {
    return await _databaseService.getEntriesByQuick(quickCode);
  }

  Future<List<Entry>> getResultsByChar(String char) async {
    return await _databaseService.getEntriesByChar(char);
  }
}