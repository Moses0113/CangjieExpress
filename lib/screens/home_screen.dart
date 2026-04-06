import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../widgets/cangjie_card.dart';
import '../models/entry.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedEntries = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(Entry entry) {
    setState(() {
      final char = entry.char;
      if (_bookmarkedEntries.contains(char)) {
        _bookmarkedEntries.remove(char);
      } else {
        _bookmarkedEntries.add(char);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('速頡字典'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // TODO: 實現書籤頁面導航
            },
            tooltip: '書籤',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜尋欄
          const CangjieSearchBar(),
          
          // 結果顯示區域
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    switch (state.status) {
      case SearchStatus.initial:
        return _buildInitialMessage();
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.success:
        if (state.results.isEmpty) {
          return _buildNoResults(state.query);
        }
        return _buildResultsList(state.results);
      case SearchStatus.error:
        return _buildError(state.errorMessage ?? '未知錯誤');
    }
  }

  Widget _buildInitialMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '輸入漢字或倉頡碼開始搜尋',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.outbox, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '沒有找到「$query」的相關結果',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '嘗試輸入其他關鍵字或檢查拼寫',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            '發生錯誤: $message',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref.read(searchProvider.notifier).search('');
            },
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Entry> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isBookmarked = _bookmarkedEntries.contains(entry.char);
        
        return CangjieCard(
          entry: entry,
          onToggleBookmark: () => _toggleBookmark(entry),
          isBookmarked: isBookmarked,
        );
      },
    );
  }
}