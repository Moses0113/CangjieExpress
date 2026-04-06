import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/entry.dart';
import 'cangjie_keyboard.dart';

class CangjieCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onToggleBookmark;
  final bool isBookmarked;

  const CangjieCard({
    Key? key,
    required this.entry,
    this.onToggleBookmark,
    this.isBookmarked = false,
  }) : super(key: key);

  // 倉頡字母到中文部件的映射
  static final Map<String, String> _cjToChinese = {
    'A': '日', 'B': '月', 'C': '金', 'D': '木', 'E': '水',
    'F': '火', 'G': '土', 'H': '竹', 'I': '戈', 'J': '十',
    'K': '大', 'L': '中', 'M': '一', 'N': '弓', 'O': '人',
    'P': '心', 'Q': '手', 'R': '口', 'S': '尸', 'T': '廿',
    'U': '山', 'V': '女', 'W': '田', 'X': '難', 'Y': '卜',
    'Z': '禾'
  };

  Future<void> _speakJyutping() async {
    if (entry.jyutping.isNotEmpty) {
      try {
        final flutterTts = FlutterTts();
        await flutterTts.setLanguage('zh-HK');
        await flutterTts.setPitch(1.0);
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.speak(entry.jyutping);
      } catch (e) {
        // 語音合成失敗時靜默處理
      }
    }
  }

  String _convertCjToChinese(String cjCode) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < cjCode.length; i++) {
      final String char = cjCode[i];
      sb.write(_cjToChinese[char] ?? char);
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題行：繁體字 + 粵語發音 + 語音按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.char,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansTC',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      entry.jyutping.isNotEmpty ? entry.jyutping : '-',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: _speakJyutping,
                      tooltip: '播放粵語發音',
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // 倉頡五代
            Text(
              '倉頡 (五代):  ${_formatCangjie(entry.cj5)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            // 速成碼
            Text(
              '速成 (首尾):  ${entry.quick.isNotEmpty ? _formatQuick(entry.quick) : '-'}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            // 倉頡鍵盤視圖
            CangjieKeyboard(
              cangjieCode: entry.cj5,
              highlightPositions: _getHighlightPositions(entry.cj5),
            ),
            const SizedBox(height: 12),
            // 操作按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.red : Colors.grey,
                  ),
              onPressed: onToggleBookmark != null ? () => onToggleBookmark!() : null,
                  tooltip: isBookmarked ? '移除書籤' : '加入書籤',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCangjie(String cjCode) {
    if (cjCode.isEmpty) return '-';
    
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < cjCode.length; i++) {
      final String cjChar = cjCode[i];
      final String chineseChar = _cjToChinese[cjChar] ?? cjChar;
      sb.write('$chineseChar ');
      
      // 在倉頡碼之上顯示對應的英文字母
      if (i < cjCode.length - 1) {
        sb.write('  '); // 間隔
      }
    }
    
    // 第二行顯示英文字母
    sb.write('\n');
    for (int i = 0; i < cjCode.length; i++) {
      sb.write('  ${cjCode[i]} ');
      if (i < cjCode.length - 1) {
        sb.write('  '); // 間隔
      }
    }
    
    return sb.toString().trimRight();
  }

  String _formatQuick(String quickCode) {
    if (quickCode.isEmpty) return '-';
    
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < quickCode.length; i++) {
      final String qc = quickCode[i];
      final String chineseChar = _cjToChinese[qc] ?? qc;
      sb.write('$chineseChar ');
      
      // 在速成碼之上顯示對應的英文字母（首尾碼）
      if (i == 0) {
        sb.write('  $qc ');
      } else if (i == quickCode.length - 1) {
        sb.write('  $qc ');
      } else {
        sb.write('    '); // 中間部分留空
      }
    }
    
    // 第二行顯示英文字母（只有首尾有值）
    sb.write('\n');
    for (int i = 0; i < quickCode.length; i++) {
      if (i == 0 || i == quickCode.length - 1) {
        sb.write('  ${quickCode[i]} ');
      } else {
        sb.write('    ');
      }
      
      if (i < quickCode.length - 1) {
        sb.write('  '); // 間隔
      }
    }
    
    return sb.toString().trimRight();
  }

  List<int> _getHighlightPositions(String cjCode) {
    // 這裡可以返回需要高亮的位置，例如用戶選中的部件位置
    // 暫時返回空列表，表示不高亮任何位置
    return [];
  }
}