import '../../models/diary_entry.dart';

/// 日记数据源抽象：本阶段由 LocalDiaryRepository 走 sqlite，
/// 后端阶段换成 ApiDiaryRepository，Provider 与页面不用改。
abstract class DiaryRepository {
  /// 全部日记，按日期倒序。
  Future<List<DiaryEntry>> all();

  Future<List<DiaryEntry>> byDate(DateTime date);

  /// 闭区间：start / end 当天都包含。
  Future<List<DiaryEntry>> between(DateTime start, DateTime end);

  /// id 为空新增、否则更新；返回带 id 的完整记录。
  Future<DiaryEntry> save(DiaryEntry entry);

  Future<void> delete(int id);
}
