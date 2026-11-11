import 'dart:convert';

import '../utils/formatters.dart';

/// 一篇睡眠日记。
///
/// tags 在模型层就是 List<String>，数据库里存 JSON 字符串；
/// 这样页面不用知道持久化细节，后端换接口时也不用改 UI。
class DiaryEntry {
  const DiaryEntry({
    required this.entryDate,
    required this.mood,
    required this.content,
    this.id,
    this.tags = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  /// 归属日期（按天，不含时分）。
  final DateTime entryDate;

  /// 心情 1~5，必选。
  final int mood;
  final String content;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// 保存前校验：心情在 1~5，正文去掉首尾空白后至少 5 个字。
  bool get isValid => mood >= 1 && mood <= 5 && content.trim().length >= 5;

  DiaryEntry copyWith({
    int? id,
    DateTime? entryDate,
    int? mood,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 写库映射：id 交给 sqlite 自增，所以不放进 map。
  Map<String, Object?> toMap() {
    final DateTime created = createdAt ?? DateTime.now();
    return <String, Object?>{
      'entry_date': formatDateKey(entryDate),
      'mood': mood,
      'content': content,
      'tags': jsonEncode(tags),
      'created_at': formatTimestamp(created),
      'updated_at': formatTimestamp(updatedAt ?? created),
    };
  }

  /// 从数据库行还原；tags 解析失败按空标签处理，不让一条坏数据卡住整个列表。
  factory DiaryEntry.fromMap(Map<String, Object?> map) {
    final DateTime created =
        parseTimestamp(map['created_at']?.toString()) ?? DateTime.now();
    return DiaryEntry(
      id: (map['id'] as num?)?.toInt(),
      entryDate: parseDateKey(map['entry_date']?.toString()) ??
          DateTime(created.year, created.month, created.day),
      mood: ((map['mood'] as num?)?.toInt() ?? 3).clamp(1, 5).toInt(),
      content: map['content']?.toString() ?? '',
      tags: _decodeTags(map['tags']?.toString()),
      createdAt: created,
      updatedAt: parseTimestamp(map['updated_at']?.toString()) ?? created,
    );
  }
}

List<String> _decodeTags(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const <String>[];
  }
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toList(growable: false);
    }
  } on FormatException {
    return const <String>[];
  }
  return const <String>[];
}
