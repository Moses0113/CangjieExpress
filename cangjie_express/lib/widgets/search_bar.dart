import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class CangjieSearchBar extends ConsumerWidget {
  const CangjieSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '輸入漢字或倉頡碼 (A-Z)...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchState.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(searchProvider.notifier).search('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        onChanged: (query) {
          // 實時搜尋 - 可以加上防抖
          searchNotifier.search(query);
        },
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          // 按下搜尋鍵時執行搜尋
          searchNotifier.search(query);
        },
      ),
    );
  }
}