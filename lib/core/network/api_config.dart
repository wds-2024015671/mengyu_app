/// 后端地址常量（本阶段只建文件，不发任何请求）。
///
/// 为什么用 String.fromEnvironment：模拟器、真机、后端联调地址不同，
/// 构建时用 --dart-define=API_BASE_URL=https://xxx 覆盖即可，
/// 不需要改代码，也不会把 10.0.2.2 写进某个页面里。
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/api',
);
