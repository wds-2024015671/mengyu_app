import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/models/app_user.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/diary_entry.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/data/repositories/auth_repository.dart';
import 'package:mengyu_app/data/repositories/diary_repository.dart';
import 'package:mengyu_app/data/repositories/session_repository.dart';
import 'package:mengyu_app/data/repositories/sound_repository.dart';
import 'package:mengyu_app/data/repositories/upload_repository.dart';
import 'package:mengyu_app/providers/auth_provider.dart';
import 'package:mengyu_app/providers/diary_provider.dart';
import 'package:mengyu_app/providers/sleep_provider.dart';
import 'package:mengyu_app/providers/sound_provider.dart';
import 'package:mengyu_app/providers/upload_provider.dart';

class _FakeDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = <DiaryEntry>[];
  bool fail = false;
  int _nextId = 1;

  @override
  Future<List<DiaryEntry>> all() async {
    if (fail) {
      throw const AppException('读日记失败');
    }
    return List<DiaryEntry>.of(_entries);
  }

  @override
  Future<List<DiaryEntry>> byDate(DateTime date) => all();

  @override
  Future<List<DiaryEntry>> between(DateTime start, DateTime end) => all();

  @override
  Future<DiaryEntry> save(DiaryEntry entry) async {
    if (fail) {
      throw const AppException('写日记失败');
    }
    final DiaryEntry saved = entry.copyWith(id: entry.id ?? _nextId++);
    _entries
      ..removeWhere((DiaryEntry item) => item.id == saved.id)
      ..add(saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    _entries.removeWhere((DiaryEntry item) => item.id == id);
  }
}

class _FakeSessionRepository implements SessionRepository {
  _FakeSessionRepository(this._sessions);

  final List<SleepSession> _sessions;

  @override
  Future<List<SleepSession>> all() async => List<SleepSession>.of(_sessions);

  @override
  Future<List<SleepSession>> byDate(DateTime date) => all();

  @override
  Future<List<SleepSession>> between(DateTime start, DateTime end) => all();

  @override
  Future<List<SleepSession>> recent(int limit) async =>
      _sessions.take(limit).toList(growable: false);

  @override
  Future<SleepSession> save(SleepSession session) async {
    _sessions.add(session);
    return session;
  }

  @override
  Future<void> delete(int id) async {
    _sessions.removeWhere((SleepSession item) => item.id == id);
  }
}

class _FakeSoundRepository implements SoundRepository {
  int publicCalls = 0;

  @override
  Future<List<AudioItem>> localAudios() async {
    return List<AudioItem>.generate(
      6,
      (int index) => AudioItem.builtIn(
        id: 'local_$index',
        title: '音景 $index',
        category: '雨声',
        assetPath: 'audio/$index.wav',
      ),
    );
  }

  @override
  Future<List<AudioItem>> publicAudios(
    int page,
    int size, [
    String keyword = '',
    String category = '',
  ]) async {
    publicCalls++;
    return const <AudioItem>[];
  }
}

class _FakeUploadRepository implements UploadRepository {
  final List<AudioItem> _items = <AudioItem>[];

  @override
  Future<AudioItem> upload(
    String filePath,
    String title,
    String category,
    String description,
  ) async {
    final AudioItem item = AudioItem(
      id: 'upload_${_items.length + 1}',
      title: title,
      category: category,
      description: description,
      sourceType: AudioSourceType.file,
      filePath: filePath,
      status: AudioItem.statusPending,
    );
    _items.insert(0, item);
    return item;
  }

  @override
  Future<List<AudioItem>> myUploads(int page, int size) async =>
      List<AudioItem>.of(_items);
}

class _FakeAuthRepository extends AuthRepository {
  AppUser? _current;

  @override
  Future<AppUser> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw const AppException('请输入用户名和密码');
    }
    _current = AppUser(username: username, nickname: '小鱼');
    return _current!;
  }

  @override
  Future<AppUser> register(
    String username,
    String password,
    String nickname,
  ) async {
    _current = AppUser(username: username, nickname: nickname);
    return _current!;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }

  @override
  Future<AppUser?> currentUser() async => _current;
}

void main() {
  test('DiaryProvider：loading → list → CRUD 回读 → error', () async {
    final _FakeDiaryRepository repository = _FakeDiaryRepository();
    final DiaryProvider provider = DiaryProvider(repository);
    addTearDown(provider.dispose);

    int notices = 0;
    provider.addListener(() => notices++);

    final Future<void> loading = provider.load();
    expect(provider.isLoading, isTrue);
    await loading;
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    expect(provider.entries, isEmpty);

    final bool saved = await provider.save(
      DiaryEntry(
        entryDate: DateTime(2026, 11, 9),
        mood: 3,
        content: '今晚准备早睡。',
      ),
    );
    expect(saved, isTrue);
    expect(provider.entries.length, 1);
    expect(provider.entries.first.id, 1);

    final bool deleted = await provider.delete(provider.entries.first.id!);
    expect(deleted, isTrue);
    expect(provider.entries, isEmpty);
    expect(notices, greaterThanOrEqualTo(4));

    repository.fail = true;
    await provider.load();
    expect(provider.error, '读日记失败');
  });

  test('SleepProvider：注入时钟后本周统计与最近记录正确', () async {
    final List<SleepSession> sessions = <SleepSession>[
      SleepSession(
        bedTime: DateTime(2026, 11, 8, 23),
        wakeTime: DateTime(2026, 11, 9, 7),
        quality: 4,
      ),
      SleepSession(
        bedTime: DateTime(2026, 11, 9, 23, 30),
        wakeTime: DateTime(2026, 11, 10, 7),
        quality: 3,
      ),
    ];
    final SleepProvider provider = SleepProvider(
      _FakeSessionRepository(sessions),
      clock: () => DateTime(2026, 11, 9),
    );
    addTearDown(provider.dispose);

    await provider.load();
    expect(provider.hasData, isTrue);
    expect(provider.recent.length, 2);
    expect(provider.weekStats.days.length, 7);
    expect(provider.weekStats.sessionCount, 1);
    expect(provider.weekStats.streakDays, 2);
  });

  test('SoundProvider：本地 6 条、公共库空、筛选未变不重复请求', () async {
    final _FakeSoundRepository repository = _FakeSoundRepository();
    final SoundProvider provider = SoundProvider(repository);
    addTearDown(provider.dispose);

    await provider.loadLocal();
    expect(provider.localAudios.length, 6);
    expect(provider.errorLocal, isNull);

    await provider.loadPublic();
    expect(provider.publicAudios, isEmpty);
    expect(provider.hasMorePublic, isFalse);
    expect(repository.publicCalls, 1);

    await provider.search(keyword: '雨');
    expect(repository.publicCalls, 2);
    await provider.search(keyword: '雨');
    expect(repository.publicCalls, 2);
  });

  test('UploadProvider：提交后列表出现审核中记录', () async {
    final UploadProvider provider = UploadProvider(_FakeUploadRepository());
    addTearDown(provider.dispose);

    await provider.loadMyUploads();
    expect(provider.uploads, isEmpty);

    final bool ok = await provider.upload(
      filePath: '/tmp/rain.wav',
      title: '雨声',
      category: '雨声',
      description: '测试',
    );
    expect(ok, isTrue);
    expect(provider.isSubmitting, isFalse);
    expect(provider.uploads.length, 1);
    expect(provider.uploads.first.status, AudioItem.statusPending);
    expect(provider.error, isNull);
  });

  test('AuthProvider：游客会话与记住我', () async {
    final AuthProvider provider = AuthProvider(_FakeAuthRepository());
    addTearDown(provider.dispose);

    provider.continueAsGuest();
    expect(provider.hasSession, isTrue);
    expect(provider.isGuest, isTrue);
    expect(provider.isLoggedIn, isFalse);

    await provider.setRememberMe(false);
    expect(provider.rememberMe, isFalse);

    await provider.logout();
    expect(provider.hasSession, isFalse);
  });

  test('AuthProvider：登录/退出/错误文案', () async {
    final AuthProvider provider = AuthProvider(_FakeAuthRepository());
    addTearDown(provider.dispose);

    expect(await provider.login('xiaoyu', '123456'), isTrue);
    expect(provider.isLoggedIn, isTrue);
    expect(provider.nickname, '小鱼');

    await provider.logout();
    expect(provider.isLoggedIn, isFalse);

    expect(await provider.login('', ''), isFalse);
    expect(provider.error, '请输入用户名和密码');
  });
}
