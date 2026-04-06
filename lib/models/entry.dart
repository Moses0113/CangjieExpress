class Entry {
  final int id;
  final String char;
  final String cj5;
  final String cj3;
  final String quick;
  final String jyutping;
  final int frequency;
  final String? definition;

  Entry({
    required this.id,
    required this.char,
    required this.cj5,
    required this.cj3,
    required this.quick,
    required this.jyutping,
    required this.frequency,
    this.definition,
  });

  // 從資料庫映射工廠
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int,
      char: map['char'] as String,
      cj5: map['cj5'] as String,
      cj3: map['cj3'] as String,
      quick: map['quick'] as String,
      jyutping: map['jyutping'] as String,
      frequency: map['frequency'] as int,
      definition: map['definition'] as String?,
    );
  }

  // 轉換為 Map 用於資料庫插入/更新
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'char': char,
      'cj5': cj5,
      'cj3': cj3,
      'quick': quick,
      'jyutping': jyutping,
      'frequency': frequency,
      'definition': definition,
    };
  }
}