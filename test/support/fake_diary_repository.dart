import 'package:mengyu_app/data/repositories/diary_repository.dart';
import 'package:mengyu_app/models/diary_entry.dart';

/// 内存版日记仓库：按 entryDate 倒序返回，保存时补 id。
class FakeDiaryRepository implements DiaryRepository {
  FakeDiaryRepository({List<DiaryEntry>? seed}) {
    if (seed != null) {
      entries.addAll(seed);
    }
    _nextId = entries.fold<int>(0, (int max, DiaryEntry e) {
          final int id = e.id ?? 0;
          return id > max ? id : max;
        }) +
        1;
  }

  final List<DiaryEntry> entries = <DiaryEntry>[];
  int _nextId = 1;
  bool fail = false;

  @override
  Future<List<DiaryEntry>> all() async {
    if (fail) {
      throw Exception('读日记失败');
    }
    final List<DiaryEntry> sorted = List<DiaryEntry>.of(entries)
      ..sort((DiaryEntry a, DiaryEntry b) {
        final int byDate = b.entryDate.compareTo(a.entryDate);
        if (byDate != 0) {
          return byDate;
        }
        return (b.createdAt ?? b.entryDate)
            .compareTo(a.createdAt ?? a.entryDate);
      });
    return sorted;
  }

  @override
  Future<List<DiaryEntry>> byDate(DateTime date) async {
    return entries
        .where((DiaryEntry entry) =>
            entry.entryDate.year == date.year &&
            entry.entryDate.month == date.month &&
            entry.entryDate.day == date.day)
        .toList(growable: false);
  }

  @override
  Future<List<DiaryEntry>> between(DateTime start, DateTime end) async {
    return entries
        .where((DiaryEntry entry) =>
            !entry.entryDate.isBefore(start) && !entry.entryDate.isAfter(end))
        .toList(growable: false);
  }

  @override
  Future<DiaryEntry> save(DiaryEntry entry) async {
    if (fail) {
      throw Exception('写日记失败');
    }
    final DiaryEntry saved = entry.id == null
        ? entry.copyWith(id: _nextId++)
        : entry.copyWith(updatedAt: DateTime.now());
    final int index =
        entries.indexWhere((DiaryEntry item) => item.id == saved.id);
    if (index >= 0) {
      entries[index] = saved;
    } else {
      entries.add(saved);
    }
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    entries.removeWhere((DiaryEntry entry) => entry.id == id);
  }
}
