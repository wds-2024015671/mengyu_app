import 'package:flutter/foundation.dart';
import 'package:mengyu_app/data/repositories/sleep_tracking_repository.dart';
import 'package:mengyu_app/data/services/sleep_notification_service.dart';
import 'package:mengyu_app/models/sleep_tracking_record.dart';

class FakeSleepTrackingRepository implements SleepTrackingRepository {
  FakeSleepTrackingRepository([SleepTrackingRecord? initial]) {
    if (initial != null) {
      records[initial.nightKey] = initial;
    }
  }

  final Map<String, SleepTrackingRecord> records =
      <String, SleepTrackingRecord>{};
  int _nextId = 1;
  bool scheduled = false;

  @override
  Future<SleepTrackingRecord?> open() async {
    for (final SleepTrackingRecord record in records.values) {
      if (record.isOpen) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<SleepTrackingRecord?> pending() async {
    for (final SleepTrackingRecord record in records.values) {
      if (record.status == SleepTrackingStatus.pending) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<SleepTrackingRecord?> byNight(String nightKey) async =>
      records[nightKey];

  @override
  Future<SleepTrackingRecord> save(SleepTrackingRecord record) async {
    final SleepTrackingRecord saved =
        record.id == null ? record.copyWith(id: _nextId++) : record;
    records[saved.nightKey] = saved;
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    records.removeWhere((_, SleepTrackingRecord record) => record.id == id);
  }
}

class FakeSleepNotificationService implements SleepNotificationService {
  bool permission = false;
  bool scheduled = false;
  bool initialized = false;
  int requests = 0;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    requests++;
    permission = true;
    return permission;
  }

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<void> scheduleMorning(DateTime at) async {
    scheduled = true;
  }

  @override
  Future<void> cancelMorning() async {
    scheduled = false;
  }

  @override
  bool takePendingTap() => false;

  @override
  void setOnTap(VoidCallback? callback) {}
}
