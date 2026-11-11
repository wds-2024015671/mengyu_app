/// 14 条命名路由的唯一出处。
///
/// 为什么集中常量：字符串写错只能运行时报错；集中后可以被路由器 switch
/// 和测试同时引用，拼错会立刻在 analyze 阶段暴露。
abstract final class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';

  // MainShell 的 4 个 tab
  static const String home = '/home';
  static const String sound = '/sound';
  static const String report = '/report';
  static const String profile = '/profile';

  // 独立页面
  static const String upload = '/upload';
  static const String player = '/player';
  static const String timer = '/timer';
  static const String breathing = '/breathing';
  static const String breathingSession = '/breathing_session';
  static const String diary = '/diary';
  static const String diaryEdit = '/diary/edit';
  static const String sleepLogForm = '/sleep_log_form';

  /// 自检用：数量必须等于 14。
  static const List<String> all = <String>[
    welcome,
    login,
    home,
    sound,
    report,
    profile,
    upload,
    player,
    timer,
    breathing,
    breathingSession,
    diary,
    diaryEdit,
    sleepLogForm,
  ];
}
