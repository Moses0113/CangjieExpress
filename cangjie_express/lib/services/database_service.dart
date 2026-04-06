import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'cangjie_express.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        char TEXT NOT NULL,
        cj5 TEXT,
        cj3 TEXT,
        quick TEXT,
        jyutping TEXT,
        frequency INTEGER DEFAULT 0,
        definition TEXT
      )
    ''');

    // 建立索引
    await db.execute('CREATE INDEX idx_char ON entries(char)');
    await db.execute('CREATE INDEX idx_quick ON entries(quick)');
    await db.execute('CREATE INDEX idx_frequency ON entries(frequency DESC)');
  }

  // 初始化資料庫 - 從 assets 複製預填充的數據
  Future<void> initializeDatabase() async {
    final db = await database;
    
    // 檢查資料庫是否已有數據
    var count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM entries')
    );
    
    if (count == 0) {
      // 資料庫為空，從 assets 複製數據
      await _populateInitialData(db);
    }
  }

  Future<void> _populateInitialData(Database db) async {
    // 在實際應用中，這裡會從 assets/data/dict.db 複製數據
    // TODO: 實現從 assets 複製預填充數據的邏輯
    // 目前為了開發，我們插入一些樣本數據
    
    final sampleEntries = [
      {
        'char': '攞',
        'cj5': '手田中',
        'cj3': '手田中',
        'quick': 'QL',
        'jyutping': 'lo2',
        'frequency': 85,
        'definition': 'to take, to hold'
      },
      {
        'char': '人',
        'cj5': '亼',
        'cj3': '亼',
        'quick': '',
        'jyutping': 'jan4',
        'frequency': 1500,
        'definition': 'person, people'
      },
      {
        'char': '大',
        'cj5': '大',
        'cj3': '大',
        'quick': '',
        'jyutping': 'daai6',
        'frequency': 1200,
        'definition': 'big, large'
      },
      {
        'char': '天',
        'cj5': '一大',
        'cj3': '一大',
        'quick': 'MK',
        'jyutping': 'tin1',
        'frequency': 1000,
        'definition': 'sky, heaven, day'
      },
      {
        'char': '地',
        'cj5': '土一',
        'cj3': '土一',
        'quick': 'GM',
        'jyutping': 'dei6',
        'frequency': 950,
        'definition': 'earth, ground, land'
      }
    ];

    final batch = db.batch();
    for (var entry in sampleEntries) {
      batch.insert('entries', entry);
    }
    await batch.commit(noResult: true);
  }

  // CRUD 操作
  Future<List<Entry>> getEntriesByQuick(String quickCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'quick = ?',
      whereArgs: [quickCode],
      orderBy: 'frequency DESC',
      limit: 50,
    );

    return List.generate(maps.length, (i) {
      return Entry.fromMap(maps[i]);
    });
  }

  Future<List<Entry>> getEntriesByChar(String char) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'char = ?',
      whereArgs: [char],
    );

    return List.generate(maps.length, (i) {
      return Entry.fromMap(maps[i]);
    });
  }

  Future<List<Entry>> searchEntries(String query) async {
    final db = await database;
    
    // 判斷查詢是字母（碼表查詢）還是漢字
    if (RegExp(r'^[A-Za-z]+$').hasMatch(query)) {
      // 英文字母查詢 - 速成碼或倉頡碼前綴匹配
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'quick LIKE ? OR cj5 LIKE ?',
        whereArgs: ['${query.toUpperCase()}%', '${query.toUpperCase()}%'],
        orderBy: 'frequency DESC',
        limit: 50,
      );
      
      return List.generate(maps.length, (i) {
        return Entry.fromMap(maps[i]);
      });
    } else {
      // 漢字查詢
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'char LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'frequency DESC',
        limit: 50,
      );
      
      return List.generate(maps.length, (i) {
        return Entry.fromMap(maps[i]);
      });
    }
  }

  Future<int> insertEntry(Entry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<int> updateEntry(Entry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}