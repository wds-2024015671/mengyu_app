import '../../models/sleep_session.dart';

/// 睡眠记录数据源抽象：补记、播放器会话、月迹统计都走它。
abstract class SessionRepository {
  /// 全部记录，按入睡时间倒序。
  Future<List<SleepSession>> all();

  Future<List<SleepSession>> byDate(DateTime date);

  /// 闭区间：start / end 当天都包含。
  Future<List<SleepSession>> between(DateTime start, DateTime end);

  Future<List<SleepSession>> recent(int limit);

  /// id 为空新增、否则更新；返回带 id 的完整记录。
  Future<SleepSession> save(SleepSession session);

  Future<void> delete(int id);
}
