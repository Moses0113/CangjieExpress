# 項目文件：速頡字典 (CangjieExpress)

## 1. 項目定義
**速頡字典** 是一款針對香港用戶開發的 Flutter 應用程式，結合了**政府官方字庫 (HKSCS)** 的權威性與 **Rime 開源社群** 的實用性。它能幫助用戶快速查詢漢字的倉頡五代、三代及速成碼，並輔以粵語發音與字義解釋。

---

## 2. 數據庫架構 (The "Hybrid" Strategy)

項目核心採用 SQLite，透過 Python 預處理腳本將兩個數據源互補：

### 數據來源
1.  **DATA.GOV.HK (HKSCS)**：提供標準香港增補字符集、Unicode 編碼及官方粵語拼音。
2.  **Rime (rime-cangjie)**：提供更符合輸入習慣的拆碼修正及**字頻數據 (Weight)**。

### 數據庫表結構 (`entries`)
| 欄位 | 類型 | 說明 |
| :--- | :--- | :--- |
| `id` | INTEGER | 主鍵 |
| `char` | TEXT | 漢字 (如「攞」) |
| `cj5` | TEXT | 倉頡五代碼 (如「手田中」) |
| `cj3` | TEXT | 倉頡三代碼 (兼容舊式拆法) |
| `quick` | TEXT | 速成碼 (取 `cj5` 之首尾) |
| `jyutping` | TEXT | 粵語拼音 (如「lo2」) |
| `frequency` | INTEGER | 字頻 (由 Rime 提供，用於搜尋排序) |
| `definition` | TEXT | 簡短字義 (選填) |

---

## 3. UI 交互設計方案

### A. 搜尋組件 (Search Bar)
* **智能識別**：
    * 輸入 **英文字母** (A-Z)：自動切換為碼表查詢（支持模糊匹配，如輸入 `A` 顯示所有「日」部字）。
    * 輸入 **漢字**：直接顯示該字的拆碼。
* **動態過濾**：使用 `ListView.builder` 配合 `Stream` 實現即時輸入即時顯示。

### B. 拆碼卡片 (Result Card)
```markdown
+---------------------------------------+
|  [ 繁 ]  faan4          [ 🔊 粵音 ]  |
+---------------------------------------+
| 倉頡 (五代):  敏 竹 木 火 (O K D F)   |
| ------------------------------------- |
| 速成 (首尾):  敏 .... 火 (O ...... F) |
+---------------------------------------+
| [ 鍵盤對照圖示 ]                      |
| [ 日 ][ 月 ][ 金 ][ 木 ][ 水 ][ 火 ]  |
|          ^選中此鍵的按鍵位置           |
+---------------------------------------+
```

---

## 4. Flutter 技術要點

### 核心套件 (Dependencies)
* `sqflite` & `path`: 處理離線數據庫。
* `flutter_tts`: 提供廣東話語音朗讀功能。
* `flutter_riverpod`: 管理搜尋狀態與歷史記錄。
* `google_fonts`: 確保字體美觀（建議選用支援 Noto Sans TC 的字體）。

### 搜尋演算法邏輯
```dart
// 範例：如何利用字頻處理速成重碼
String sql = """
  SELECT * FROM entries 
  WHERE quick = ? 
  ORDER BY frequency DESC 
  LIMIT 50
""";
```

---

## 5. 開發進度表 (Roadmap 2.0)

### Phase 1: 數據清洗 (Python)
* [ ] 提取 HKSCS 的 JSON 數據。
* [ ] 解析 Rime 的 `.yaml` 碼表。
* [ ] 撰寫腳本合併兩者，導出 `assets/dict.db`。

### Phase 2: Flutter 核心
* [ ] 實現 SQLite 異步加載。
* [ ] 建立 `SearchProvider` 處理關鍵字邏輯。
* [ ] 製作自定義 `CangjieKey` 組件（顯示字母對應的倉頡部件）。

### Phase 3: 體驗優化
* [ ] **書籤功能**：使用 `shared_preferences` 儲存收藏字。
* [ ] **多語言支持**：界面支援繁體中文、英文。
* [ ] **手寫輸入**：整合系統手寫板以供無法拆碼時使用。

---

## 6. 項目環境要求
* **Flutter SDK**: 3.x.x 或以上
* **Dart**: 3.x.x
* **Target Platforms**: iOS, Android (優先支援移動端)
