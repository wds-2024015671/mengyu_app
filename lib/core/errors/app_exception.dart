/// 数据层统一异常：Local 实现主动抛出的业务错误都带中文 message，
/// Provider 直接用 message 展示，不用把 `Exception: xxx` 拼给用户看。
class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  /// 可直接展示给用户的中文文案。
  final String message;

  /// 原始异常，便于调试日志追溯。
  final Object? cause;

  /// 把任意异常转成可展示文案；未识别异常返回兜底文案，避免泄露堆栈。
  static String describe(
    Object error, {
    String fallback = '操作失败，请稍后再试',
  }) {
    if (error is AppException) {
      return error.message;
    }
    return fallback;
  }

  @override
  String toString() => message;
}
