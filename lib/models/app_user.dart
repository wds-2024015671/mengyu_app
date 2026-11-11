/// 登录用户。
///
/// 本阶段 LocalAuthRepository 只会填 username / nickname，
/// id 与 joinedAt 留给后端返回；页面不能假设这些字段一定有值。
class AppUser {
  const AppUser({
    required this.username,
    required this.nickname,
    this.id,
    this.avatarPath,
    this.joinedAt,
  });

  /// 未登录占位：避免页面到处判空。
  static const AppUser anonymous = AppUser(username: '', nickname: '旅客');

  final int? id;
  final String username;
  final String nickname;

  /// 本地头像路径；空则用默认图形。
  final String? avatarPath;
  final DateTime? joinedAt;

  bool get isAnonymous => username.isEmpty;

  AppUser copyWith({String? nickname, String? avatarPath, int? id, DateTime? joinedAt}) {
    return AppUser(
      id: id ?? this.id,
      username: username,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
