/// 睡眠自动记录与提醒的 prefs 键。
const String kAutoSleepTrackingKey = 'settings.auto_sleep_tracking';
const String kMorningReminderKey = 'settings.morning_reminder';
const String kReminderMinutesKey = 'settings.reminder_minutes';
const String kSleepIntroSeenKey = 'sleep.intro_seen';

/// 07:30 是产品默认晨间提醒，允许 07:00 / 07:30 / 08:00。
const int kDefaultReminderMinutes = 450;
const List<int> kReminderOptions = <int>[420, 450, 480];
