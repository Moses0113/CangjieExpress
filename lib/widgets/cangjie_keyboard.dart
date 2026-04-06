import 'package:flutter/material.dart';

class CangjieKeyboard extends StatelessWidget {
  final String cangjieCode;
  final List<int> highlightPositions; // 要高亮的位置索引列表

  const CangjieKeyboard({
    Key? key,
    required this.cangjieCode,
    this.highlightPositions = const [],
  }) : super(key: key);

  // 倉頡鍵盤佈局 - 24個基本字形
  static const List<String> _cangjieKeys = [
    '日', '月', '金', '木', '水', '火', '土', '竹', '戈', '十',
    '大', '中', '一', '弓', '人', '心', '手', '口', '尸', '廿',
    '山', '女', '田', '難'
  ];

  // 倉頡字母映射（用於顯示）
  static const Map<String, String> _cjToLetter = {
    '日': 'A', '月': 'B', '金': 'C', '木': 'D', '水': 'E', '火': 'F',
    '土': 'G', '竹': 'H', '戈': 'I', '十': 'J', '大': 'K', '中': 'L',
    '一': 'M', '弓': 'N', '人': 'O', '心': 'P', '手': 'Q', '口': 'R',
    '尸': 'S', '廿': 'T', '山': 'U', '女': 'V', '田': 'W', '難': 'X',
    '卜': 'Y', '禾': 'Z'
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 倉頡字母標籤行
        _buildLetterRow(),
        const SizedBox(height: 4),
        // 倉頡字形圖示行
        _buildKeyRow(),
      ],
    );
  }

  Widget _buildLetterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _cangjieKeys.map((key) {
        final String letter = _cjToLetter[key] ?? '?';
        final bool isHighlight = _isKeyHighlighted(key);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 24,
          height: 20,
          decoration: BoxDecoration(
            color: isHighlight ? Colors.blue.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHighlight ? Colors.blue.shade300 : Colors.grey.shade300,
              width: isHighlight ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.blue.shade800 : Colors.grey.shade600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _cangjieKeys.map((key) {
        final bool isHighlight = _isKeyHighlighted(key);
        final int index = _cangjieKeys.indexOf(key);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isHighlight ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHighlight ? Colors.blue.shade300 : Colors.grey.shade300,
              width: isHighlight ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.blue.shade800 : Colors.grey.shade600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isKeyHighlighted(String key) {
    // 檢查cangjieCode中是否包含該鍵對應的字符
    final int? indexInCode = cangjieCode.indexOf(key);
    if (indexInCode == -1) return false;
    
    // 檢該位置是否在highlightPositions中
    return highlightPositions.contains(indexInCode);
  }
}