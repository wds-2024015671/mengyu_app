import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 内置演示内容的“已删除”标记。
///
/// 演示声音/视频没有 DB 记录和本地文件，删除后必须跨冷启动保持隐藏；
/// 这里只存 key 列表，可删除真实媒体仍走 private_media。
class DemoVisibilityProvider extends ChangeNotifier {
  DemoVisibilityProvider({
    Future<SharedPreferences> Function()? prefs,
  }) : _prefs = prefs ?? SharedPreferences.getInstance;

  static const String prefsKey = 'sound.hidden_demo_keys';

  final Future<SharedPreferences> Function() _prefs;
  Set<String> _hidden = <String>{};
  bool _loaded = false;

  Set<String> get hidden => Set<String>.unmodifiable(_hidden);
  bool get loaded => _loaded;

  bool isHidden(String key) => _hidden.contains(key);

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    final SharedPreferences prefs = await _prefs();
    _hidden = (prefs.getStringList(prefsKey) ?? <String>[]).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> hide(Iterable<String> keys) async {
    final Set<String> next = <String>{..._hidden, ...keys};
    if (next.length == _hidden.length) {
      return;
    }
    _hidden = next;
    notifyListeners();
    final SharedPreferences prefs = await _prefs();
    await prefs.setStringList(prefsKey, _hidden.toList(growable: false));
  }

  Future<void> reset() async {
    _hidden = <String>{};
    _loaded = true;
    notifyListeners();
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(prefsKey);
  }
}
