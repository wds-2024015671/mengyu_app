import '../../../models/sleep_tracking_record.dart';
import '../../dao/sleep_tracking_dao.dart';
import '../sleep_tracking_repository.dart';

class LocalSleepTrackingRepository implements SleepTrackingRepository {
  const LocalSleepTrackingRepository(this._dao);

  final SleepTrackingDao _dao;

  @override
  Future<SleepTrackingRecord?> open() => _dao.queryOpen();

  @override
  Future<SleepTrackingRecord?> pending() => _dao.queryPending();

  @override
  Future<SleepTrackingRecord?> byNight(String nightKey) =>
      _dao.queryByNight(nightKey);

  @override
  Future<SleepTrackingRecord> save(SleepTrackingRecord record) =>
      _dao.save(record);

  @override
  Future<void> delete(int id) => _dao.delete(id);
}
