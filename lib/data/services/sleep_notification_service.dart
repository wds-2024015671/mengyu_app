import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 晨间确认通知的可替换边界；测试不碰平台通道。
abstract interface class SleepNotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> scheduleMorning(DateTime at);
  Future<void> cancelMorning();
  bool takePendingTap();
  void setOnTap(VoidCallback? callback);
}

class LocalSleepNotificationService implements SleepNotificationService {
  static const int _id = 730;
  static const String channelId = 'sleep_confirm';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _pendingTap = false;
  VoidCallback? _onTap;

  @override
  void setOnTap(VoidCallback? callback) => _onTap = callback;

  @override
  bool takePendingTap() {
    final bool value = _pendingTap;
    _pendingTap = false;
    return value;
  }

  @override
  Future<void> initialize() async {
    if (_ready) {
      return;
    }
    tzdata.initializeTimeZones();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // 取不到时区名时用 timezone 默认位置，不阻塞通知初始化。
    }

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _pendingTap = true;
        _onTap?.call();
      },
    );
    await _createChannel();
    final NotificationAppLaunchDetails? launch =
        await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _pendingTap = true;
    }
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final bool? notifications = await android.requestNotificationsPermission();
      try {
        await android.requestExactAlarmsPermission();
      } catch (_) {
        // 厂商系统没有精确闹钟入口时，调度会自动降级为 inexact。
      }
      return notifications ?? await hasPermission();
    }
    final IOSFlutterLocalNotificationsPlugin? ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final bool? granted = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: false,
      );
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<bool> hasPermission() async {
    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final IOSFlutterLocalNotificationsPlugin? ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final NotificationsEnabledOptions? options =
          await ios.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return _ready;
  }

  @override
  Future<void> scheduleMorning(DateTime at) async {
    await initialize();
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        '晨间睡眠确认',
        channelDescription: '每天提醒确认昨晚的睡眠时间',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: false,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      ),
    );
    final tz.TZDateTime when = tz.TZDateTime.from(at, tz.local);
    try {
      await _plugin.zonedSchedule(
        _id,
        '梦屿',
        '昨晚的睡眠记录待确认，点击查看',
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'sleep_confirm',
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        _id,
        '梦屿',
        '昨晚的睡眠记录待确认，点击查看',
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'sleep_confirm',
      );
    }
  }

  @override
  Future<void> cancelMorning() async {
    await initialize();
    await _plugin.cancel(_id);
  }

  Future<void> _createChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        '晨间睡眠确认',
        description: '每天提醒确认昨晚的睡眠时间',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    );
  }
}
