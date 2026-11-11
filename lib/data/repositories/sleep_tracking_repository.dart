import '../../models/sleep_tracking_record.dart';

/// 自动记录状态机数据源；与已确认的 sleep_sessions 分开。
abstract class SleepTrackingRepository {
  Future<SleepTrackingRecord?> open();
  Future<SleepTrackingRecord?> pending();
  Future<SleepTrackingRecord?> byNight(String nightKey);
  Future<SleepTrackingRecord> save(SleepTrackingRecord record);
  Future<void> delete(int id);
}
