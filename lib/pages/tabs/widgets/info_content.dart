/// “我们的初衷 / 使用须知”固定文案。
///
/// 关键词来自 `梦屿规划/关键词—修改1.md`；仓库里没有可照录的
/// `mengyu提示词.txt` 原文，因此这里保留为可替换的纯文案常量。
abstract final class AppInfoCopy {
  static const String purposeTitle = '我们的初衷';
  static const String purposeSummary = '给失眠的人，一个安静的睡前入口';
  static const List<String> purposeParagraphs = <String>[
    '梦屿是为失眠、入睡困难的人做的一个睡前工具，不是内容平台。',
    '我们不和平台比曲库，也不做推荐流、自动播放、广告、直播或社交；'
        '那些不断争夺注意力的设计，只会让人更清醒。',
    '这里只有一条尽量纯净、克制的闭环：选一段声音，做一次呼吸，'
        '留下一晚睡眠记录，然后关灯。',
    '声音可以来自本地，也可以由你从合法来源导入个人媒体库；'
        '所有记录只留在这台设备。',
  ];

  static const String termsTitle = '使用须知';
  static const String termsSummary = '本地工具 · 不提供 / 不存储 / 不传播';
  static const List<String> termsParagraphs = <String>[
    '梦屿是本地工具，不提供、不存储、不传播任何音频内容。',
    '你自行选择并导入的声音，应确保拥有合法使用权，并遵守来源平台条款与当地法律法规。',
    '因内容来源产生的争议由使用者自行承担；请勿导入无授权音频。',
  ];
}
