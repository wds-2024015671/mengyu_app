# 梦屿 · mengyu_app

睡眠与声音疗愈 App 的前端工程（F01–F13 已完成并审查）。当前包含：全部功能页 + 欢迎/登录、
14 条命名路由、浅/深双主题与公共组件、本地数据层（sqlite v3 / 自动睡眠记录状态机 /
DAO / Repository Local 实现 / 10 个 Provider）、欢迎/登录/游客、MainShell 登录守卫、
正式版首页、声屿三分区与本地收藏、上传页、播放器与定时、呼吸两页、日记列表/编辑、
睡眠补记与晨间确认、月迹周统计/月相/最近记录、头像上传、我的页与设置弹窗。
网络请求仍留到后端阶段。

## 运行

```bash
flutter pub get
flutter analyze      # 期望：No issues found
flutter test         # 期望：All tests passed（含 360×800 全路由无溢出）
flutter run
```

## 目录

```text
lib/
├── main.dart                     入口：锁定竖屏 + 深色状态栏
├── app.dart                      MultiProvider + MaterialApp（themeMode 跟随设置）
├── core/
│   ├── audio/                    AudioEngine 接口 / audioplayers 实现 / PlayerPlayback /
│   │                             SleepTimer / PlaySessionTracker
│   ├── constants/app_limits.dart 上传大小/标题长度/分类/扩展名共用常量
│   ├── constants/app_settings.dart 主题三档、默认定时选项与默认值
│   ├── constants/diary_tags.dart 日记标签候选
│   ├── errors/app_exception.dart 可展示的中文业务异常 + describe 兜底
│   ├── network/api_config.dart   API_BASE_URL 常量（本阶段不发请求）
│   ├── routes/app_routes.dart    14 条命名路由常量
│   ├── routes/app_router.dart    统一分发 + 参数类型校验 + 280ms 转场 + 兜底
│   └── theme/                    app_colors / app_text_styles / app_theme（含圆角/间距/动效）
├── models/                       AudioItem / SleepSession / DiaryEntry（含 toMap/fromMap）/
│                                 AppUser / BreathingMode（含方块第四段字段）
├── data/
│   ├── db/app_database.dart      SQLite 单例 v2：四表 + 索引 + onUpgrade v1→v2
│   ├── dao/                      diary_dao.dart / session_dao.dart（SQL 只在这里）
│   ├── services/audio_file_picker.dart  file_picker 封装 + 可注入的取文件函数
│   ├── services/app_data_cleaner.dart   清库 + 清 prefs 的本地数据清理
│   └── repositories/             Auth/Sound/Upload/Diary/Session/Favorite/Settings 抽象
│       └── local/                7 个 Local 实现（prefs / asset / sqflite + 文件复制）
├── providers/                    auth / diary / sleep / sound / upload / favorite / player /
│                                 settings + app_providers
├── pages/                        welcome login main tabs upload player timer breathing diary sleep
│   ├── login/widgets/            LoginBrand / LoginModeSwitch / LoginRememberRow
│   ├── upload/widgets/           UploadFileCard / UploadTermsField
│   ├── player/widgets/           PlayerProgress / PlayerControls
│   ├── breathing/widgets/        BreathingCircle / BreathingDialogs / BreathingPhaseHint
│   ├── diary/widgets/            DiaryCard / DiaryGroupHeader / DiaryEmptyCard / DiaryTagChips
│   ├── sleep/widgets/            SleepTimeCard / SleepQualityPicker / SleepSummaryCard
│   └── tabs/widgets/             Home* / SoundCard / SoundSegmentSwitch / LocalSoundsView /
│                                 PublicSoundsView / MyUploadsView / SoundSearchField / SoundFilterBar /
│                                 ReportWeekChart / ReportMoonGrid / ReportRecentList /
│                                 ProfileHeader / ProfileEntries / ProfileDialogs / SettingsSheet
├── widgets/
│   ├── audio_cover.dart          Hero tag + 声屿/播放器共用封面
│   ├── app_background.dart       夜空渐变 + 固定 seed 星点（CustomPaint）
│   ├── glass_card.dart           半透明渐变 + 1px 描边 + 28 圆角
│   ├── section_header.dart       区块标题 + 可选动作
│   ├── primary_button.dart       月华金渐变 + 18 圆角 + 禁用/loading
│   ├── empty_state.dart          图标 + 标题 + 说明 + 可选按钮
│   ├── async_view.dart           loading / error+重试 / empty / data 四态
│   ├── mood_picker.dart          1–5 心情，选中放大发光
│   └── stat_tile.dart            统计小卡（数值自动缩放）
└── utils/
    ├── formatters.dart           时长/时间/日期/日期键格式化（纯函数）
    ├── sleep_stats.dart          连续天数 / 本周 7 天 / 平均时长（纯函数）
    └── sleep_validation.dart     补记起床晚于入睡、1–16 小时校验（纯函数）
```

## F01–F13 验收状态

- `flutter analyze`：0 issue
- `flutter test`：115 个测试全部通过
- 360×800：`test/routes_smoke_test.dart` 逐条打开 14 条路由，无 RenderFlex 溢出
- 360×800：`test/components_test.dart` 组合渲染 8 个公共组件，无 RenderFlex 溢出
- 360×800：`test/home_test.dart` 首页推荐卡 → 播放器、月迹切 tab、下拉刷新、未登录重定向
- 360×800：`test/sound_test.dart` 声屿两列网格、搜索、收藏落盘、公共库空态、上传入口
- 360×800：`test/upload_page_test.dart` 选文件、20MB 拦截、表单校验、成功 pop(true)、失败 SnackBar、未登录跳转
- 360×800：`test/player_page_test.dart` 自动播放、暂停、收藏、定时、错误重试
- `/` → `/login` → `/home` 可跳；4 tab 可切；`/upload` 可从「我的 → 我的上传」打开
- 返回不白屏：`/upload` 返回后仍停留在主框架
- 未知路由、参数类型不符 → `NotFoundPage`
- F03：连续天数 8 例、时长/日期格式化 3 例、三模型序列化 6 例、5 个 Provider 状态 5 例
- F04：欢迎页 900ms 淡入 + 2.5s 自动分流；空表单/长度校验；注册切换；密码显隐；
  游客进入；失败 SnackBar；记住我关闭后重启回登录页；已登录冷启动直接进首页
- F05：MainShell 首帧登录守卫；首页按时段问候、月亮插画 + Stack 星点、连续 0 天显示“从今晚开始”、
  预推送 `SoundProvider` 第一条进播放器、呼吸/日记命名路由 + 月迹切 tab、仪式三步、下拉刷新
- F06：三分区 IndexedStack；本地 6 条两列 + 搜索/分类/仅看收藏；收藏写 prefs；
  公共库空态“公共库将在后端接入后开放”且保留搜索/分页/错误结构；
  我的上传待审/上架/驳回+原因；右上角上传；播放器返回刷新收藏
- F07：file_picker 选音频、20MB 拦截、标题/分类/简介/版权校验、提交 loading、
  成功 pop(true) 刷新我的上传、失败 SnackBar、未登录（含游客）跳 /login
- F08：唯一 AudioPlayer（惰性创建）、asset/file 源选择、循环播放、音量/进度/seek、
  Hero 封面、暂停/继续、收藏、定时 15–90、到点暂停 + 写 sleep_sessions + SnackBar、
  满 1 分钟 upsert 记录、加载失败 SnackBar + 重试、6 段音频资源对齐测试
- F09：3 种呼吸预设（方块含第四段屏息）、选择页三卡、单 AnimationController 同步
  圆环缩放/发光、阶段文案、剩余秒与轮次；轻/重 Haptic；完成弹窗后 pop(cycles)；
  未完成返回二次确认；360×800 圆环不溢出
- F10：日记按 entry_date 倒序分组 + 下拉刷新 + 空态 + FAB + 删除二次确认；
  心情必选/正文 ≥5 字/标签 chips/编辑预填/保存 pop DiaryEntry；
  补记日期/时间选择（中文）、自动时长、1–16 小时校验、评分备注写 sleep_sessions
- F11：本周范围；平均时长/连续天数/仪式次数 3 个 StatTile；fl_chart 0.68 的 7 根柱；
  无记录 EmptyState；近 30 天 30 格月相；最近 3 条；右上角补记 → /sleep_log_form，
  返回 true 刷新；下拉刷新；AsyncView loading/error；ReportTab 仅激活时加载
- F12：我的头像/昵称、加入天数/累计仪式/上传数量；我的上传/设置/关于/退出；
  设置 bottom sheet 主题三档 + 默认定时 + 清除数据 + 关于；主题写 prefs 并立即切换；
  退出/清数据都 `pushNamedAndRemoveUntil` 到 /login；清数据重置
  Auth/Diary/Sleep/Upload/Favorite/Settings；不注册 /settings 路由
- F13：复核 14 条命名路由、7 个 Repository 接口、页面数据层隔离、360×800 全路由、
  三态、dispose、颜色/字号 token、文件 ≤250 行；删除无引用的 SkeletonPage/SkeletonCard，
  修正过期注释；无新增依赖、无页面结构重写

> `/report` 在 VM 单测里同样会走真实 Local 仓库的失败态，路由测试只校验头部文案；
> F11 的柱状图/月相/最近记录由 `test/report_tab_test.dart` 注入 FakeSessionRepository 覆盖。
> F12 的清理动作由 `test/profile_test.dart` 注入 FakeAppDataCleaner 覆盖，真机才删库清 prefs。

> `/diary` 在 VM 单测里会走真实 Local 仓库的 sqflite 失败态，`routes_smoke_test`
> 因此断言“日记加载失败”；列表/编辑/删除的回显由 `test/diary_test.dart` 注入
> FakeDiaryRepository 覆盖。补记写库同理由 `test/sleep_log_form_test.dart` 覆盖。

> `/breathing_session` 有持续动画，`routes_smoke_test` 不能对它 `pumpAndSettle`；
> 该路由由 `test/breathing_session_test.dart` 用固定 pump 覆盖。

> 数据库 SQL 未在 VM 单测：`sqflite` 只支持移动端，桌面单测需要 `sqflite_common_ffi`（白名单外）。
> 建表与 `onUpgrade v1→v2` 在真机/模拟器首次启动时执行；表结构见 `lib/data/db/app_database.dart`。

> 月迹快捷入口切当前 MainShell 的 tab，而不是 `pushNamed('/report')`：
> 后者会再叠一个 MainShell，屏幕上出现两条底部导航。`/report` 路由本身仍保留给深链。

## 声屿说明（F06）

- 三分区用 `IndexedStack`，切换不会丢掉搜索词、分类筛选与滚动位置；
  `SoundTab(active:)` 由 MainShell 传入，只有真正切到声屿时才加载上传表/公共库。
- 收藏独立成 `FavoriteProvider` + `LocalFavoriteRepository`，prefs key 为 `favorites.sound_ids`；
  点爱心立刻更新内存再落盘，播放器返回后 `reload()` 以磁盘为准。
- 公共库 Local 实现严格返回空列表，页面显示“公共库将在后端接入后开放”；
  搜索防抖、分页 footer、loading/error 结构都已就位，后端替换 `SoundRepository` 即可。
- 「我的上传」在 VM 单测里用 FakeUploadRepository 验证状态与驳回原因（真机才走 sqlite 表）。

## 上传说明（F07）

- `file_picker` 只允许 `mp3 / wav / ogg / m4a`，页面在选文件阶段就拦截 20MB；
  大小上限、标题 80、简介 255、分类列表都集中在 `core/constants/app_limits.dart`。
- 版权承诺是 `FormField<bool>`，和标题/分类一起走 `Form.validate()`，不会出现“提交了才发现没勾”。
- `UploadPage` 接收可注入的 `AudioFilePicker`，默认是真实 `file_picker` 封装；
  VM 测试注入假选择器，真机才弹系统文件面板。
- `LocalUploadRepository` 会把文件复制到 `Documents/uploads` 再写 `my_uploads(status=0)`；
  文件不存在、超过 20MB、复制失败、写库失败都有中文错误，写库失败会删除刚复制的孤儿文件。
- 成功 `pop(true)`，`UploadProvider` 已回读列表，声屿收到 true 后刷新并切到“我的上传”。

## 播放说明（F08）

- `PlayerProvider` = `PlayerPlayback`（唯一 AudioEngine / AudioPlayer + 进度 + 音量）+ `SleepTimer`
  + `PlaySessionTracker`；音频引擎用工厂惰性创建，VM 测试可注入假引擎，生产默认 audioplayers。
- 播放源：`sourceType=asset` → `AssetSource`，`file` → `DeviceFileSource`，`remote` 直接报
  “公共音频需要后端接入后才能播放”，不发网络请求；release mode 固定 `loop`。
- 播放页：全屏夜空渐变 + Hero 封面（tag 与声屿 `SoundCard` 共用 `audio_cover_tag`）、
  进度/seek、暂停/继续、音量、收藏、定时；退出页面暂停并取消定时。
- 定时：5/10/15/20 分钟快捷项 + 自定义 1–180 分钟，到 0 秒时暂停 + 写 `sleep_sessions` + SnackBar；
  Provider dispose / 退出播放页都会取消 Timer。
- 声音仪式：首次播放记 startedAt；暂停/离开满 1 分钟 upsert 同一条记录（bed=开始、wake=当前、
  quality=3、note=“声音仪式：曲名”），同一首多次暂停不会写出碎片记录。
- 错误：加载失败进入 error 态，页面 SnackBar + 错误面板都可重试，不会崩溃。

## 呼吸说明（F09）

- 预设：4-7-8（4/7/8，4 轮）、方块 4-4-4-4（4/4/4/4，4 轮）、4-4-6（4/4/6，5 轮）。
  方块需要“呼气后再屏息”，所以 `BreathingMode` 在 F09 约定字段外补了
  `holdAfterExhale`（其余模式为 0），`roundSec/totalSec` 已把第四段算进去。
- 选择页：三张卡，点击 `pushNamed('/breathing_session', arguments: mode)`；
  完成返回的 cycles 用 SnackBar 提示。
- 进行页：一个 `AnimationController` 逐阶段驱动；圆环 scale/glow、阶段文案、
  剩余秒与轮次都从 `controller.value` 计算，不会出现“圆环到顶但秒数没走完”。
- 每阶段开始 `HapticFeedback.lightImpact()`，全部完成 `heavyImpact()`；
  完成弹窗确认后 `pop(cycles)`。
- 未完成返回：AppBar/系统返回都走 `PopScope` → 确认弹窗；确认前暂停 controller，
  选“继续”则从当前进度恢复，不会重头开始。`dispose` 会移除状态监听并释放 controller。
- 360×800：圆环固定 260，页面可滚动；`breathing_session_test` 覆盖阶段切换、
  两轮完成、完成弹窗、返回确认与无溢出。

## 日记与补记说明（F10）

- 日记列表：`DiaryProvider.load()` 后按 `entry_date DESC` 分组；组头显示今天/昨天/月日；
  有数据与空态都套 `RefreshIndicator`；空态保留“写第一篇”，FAB 始终可写。
- 删除：卡片右上角“更多 → 删除”先弹二次确认，确认后 `DiaryProvider.delete` 回读列表；
  删除失败用 SnackBar 显示 Provider 的错误文案。
- 编辑：`MoodPicker` 1–5 必选、正文 trim 后 ≥5 字、标签多选（固定候选 + 历史标签）；
  新建/编辑都走 `DiaryProvider.saveEntry()`，成功后 `pop(DiaryEntry)`，列表直接回显。
- 补记：日期与时间分开点选，`showDatePicker(locale: zh_CN)` + `showTimePicker`；
  时长由 wake − bed 实时计算，保存前用纯函数 `validateSleepRange` 校验“起床晚于入睡、1–16 小时”。
- 评分 1–5 颗星、备注可选；保存走 `SleepProvider.save` → `LocalSessionRepository` →
  `sleep_sessions` 表，成功后 `pop(true)`。Provider 会重新拉全部记录并 notify，
  首页连续天数与月迹统计都会跟着变化。
- 所有 `TextEditingController` 在 dispose 释放；日期/时间选择与保存 `await` 后都先判断 `mounted`。

## 月迹说明（F11）

- `ReportTab` 增加 `active` 参数：只有 MainShell 真正切到月迹时才 `ensureLoaded`，
  隐藏 tab 不启动加载/转圈；`didUpdateWidget` 处理从别的 tab 切回来的情况。
- 页面骨架：`AsyncView<List<SleepSession>>` 管 loading/error；加载成功后即使 0 条也走
  builder，展示零统计 + `EmptyState`，空态与有数据都套 `RefreshIndicator`。
- 三个 `StatTile` 来自 `SleepWeekStats`：本周平均时长（只对有记录的天求平均）、
  连续天数（不受本周限制）、本周仪式次数。
- 柱状图用本地 `fl_chart 0.68` 的 `BarChart`：7 个 `BarChartGroupData`、每根柱的
  `toY` 是当天总睡眠分钟数；今天用月华金，其余用紫色；关闭坐标轴标题，日期标签手绘在下方，
  避免 0.68 与 0.70+ 的 API 差异。
- 月相固定 30 格（近 30 天，10×3）：有记录的日期用金紫渐变点亮，没有记录保持玻璃色；
  `SleepProvider.today` 可注入，测试不依赖系统日期。
- 最近 3 条按 `bedTime` 倒序取；右上角“补记”`pushNamed<bool>('/sleep_log_form')`，
  返回 true 后重新 `load()` 并提示“已补记，月迹已更新”。
- `test/report_tab_test.dart` 覆盖 3 个统计值、7 根柱的 `toY`、30 格月相、最近记录、
  空态与新增记录后刷新，全部在 360×800 下无溢出。

## 我的与设置说明（F12）

- `ProfileTab` 增加 `active`：切到“我的”时才 `ensureLoaded` 睡眠、上传与登录态；
  头像用昵称首字生成，统计分别取 Auth 的 joinedAt、SleepProvider.sessions.length、
  UploadProvider.uploads.length。
- 入口：我的上传 → `/upload`；设置 → `showModalBottomSheet`；关于 → 对话框；退出登录 → 二次确认。
  没有 `/settings` 路由，`AppRoutes.all` 仍是 14 条。
- 设置弹窗：`SettingsSheet` 提供深色/浅色/跟随系统、5/10/15/20 + 自定义默认定时、清除数据、关于。
  主题写 `settings.theme_mode`，定时写 `settings.default_timer_minutes`；
  `_AppView` watch `SettingsProvider`，切换后 `MaterialApp.themeMode` 立即重建。
- 默认定时：播放页打开定时页时，如果没有正在运行的倒计时的分钟数，就从
  `SettingsProvider.defaultTimerMinutes` 取初始值（测试覆盖 45 分钟）。
- 清除数据：`LocalAppDataCleaner` 删除 SQLite 文件并 `prefs.clear()`；成功后重置
  Auth/Diary/Sleep/Upload/Favorite/Settings，再 `pushNamedAndRemoveUntil('/login')`。
- 退出登录：`AuthProvider.logout()` 后同样清空路由栈到 `/login`，系统返回不会回到首页。
- 浅色主题作用于 MaterialApp 与 Material 组件（弹窗/表单/对话框/系统选择器）；
  夜空渐变与玻璃卡是 F02 固定的品牌深色视觉，未在 F12 逐页重绘浅色插画。
- `test/profile_test.dart` 覆盖资料/统计、设置弹窗、主题/定时切换、关于、退出与清数据重置；
  `test/settings_test.dart` 覆盖 prefs 持久化、重建读回和 App 的 themeMode。

## F13 审查记录

- 14 条路由与 `AppRoutes.all` 一致；页面导航全部走 `pushNamed` / `pushReplacementNamed` /
  `pushNamedAndRemoveUntil`，lib 中除 `AppRouter` 外没有裸 `MaterialPageRoute`。
- 7 个 Repository 接口（Auth/Sound/Upload/Diary/Session/Favorite/Settings）都保留；
  页面没有直接 import `sqflite` / `dio` / `shared_preferences` / `path_provider`。
  `UploadPage` 只 import `audio_file_picker` 这个可注入的服务，属于 F07 的刻意设计。
- 全量 `flutter analyze` 0 issue；115 个测试通过；360×800 路由/组件/播放器/呼吸/日记/月迹/我的均有覆盖。
- 数据页均有 loading / error / empty：声屿三分区、日记、月迹；播放器有 loading/error/retry。
- Controller/Timer/AudioPlayer/StreamSubscription 均有 dispose 路径；await 后检查 mounted。
- lib 下无超过 250 行的文件；除 `core/theme` 外没有 `Color(0x...)` 或 `fontSize:` 新字面量。
- 删除无引用的 `widgets/skeleton_page.dart`（SkeletonPage/SkeletonCard）；
  把登录品牌行、呼吸阶段提示拆到 widgets 文件，并压缩格式，使 login/upload/breathing/sleep
  四个临界文件降到 ≤250 行；修正 `app_theme` / `app_text_styles` / `app_colors` /
  `local_sound_repository` / `home_tab` 里已经过期的 F06–F12 注释。
  没有新增依赖，没有改页面结构。

### 验收时保留的已知限制

| 级别 | 位置 | 说明 |
| --- | --- | --- |
| Info | `core/theme/app_theme.dart` | 浅色主题作用于 MaterialApp/Material 组件；F02 的夜空渐变与玻璃卡仍是品牌深色底，未逐页重绘浅色插画 |
| Info | `data/services/app_data_cleaner.dart` | 清数据按 F12 约定删 SQLite + prefs；`Documents/uploads` 下的音频文件未删 |
| Info | VM 测试 | sqflite 插件在桌面 VM 不可用，日记/月迹/我的清数据用 Fake 仓库覆盖；真机才走真实建表 |
| Info | `local_sound_repository.dart` | 公共库严格返回空列表；6 段内置音当前是合成占位音，可替换为 CC0 同名文件 |
| Info | `core/network/api_config.dart` | 当前无请求代码引用，保留为后端阶段 API_BASE_URL 入口，不属于假数据 |

## 本地插画

`assets/images/moon.png` 是本地绘制的 512×512 月亮（渐变月面 + 环形山 + 月晕），
不引用任何网络图片；`HomeMoon` 在图片缺失时还有渐变圆兜底，不会出现裂图。

## 认证说明（F04）

- `LocalAuthRepository` 用 prefs 保存 `is_logged_in / username / nickname / joined_at / remember_me`；
  「记住我」关闭时登录态不落盘，重启回到登录页（默认开启，验收「杀进程重开仍登录」走默认分支）。
- 游客只存在内存：`hasSession = true`、`isGuest = true`、`isLoggedIn = false`；
  重启回登录页，F07 上传等需要账号的动作按 `isGuest` 拦截。
- `AuthRepository` 在四个必需方法外补了 `rememberMe()` / `setRememberMe()` 两个**带默认实现**的方法；
  后端 `ApiAuthRepository` 直接 `extends AuthRepository` 即可继承默认值，也可覆盖成 token 策略。

## 音频素材（当前为占位）

`assets/audio/` 已放入 6 个 20 秒循环占位音（22.05kHz / 16bit / 单声道，约 862KB/个），
由本地脚本合成、无第三方版权，文件名与 `LocalSoundRepository.assetPath` 一致：

```text
assets/audio/rain_loop.wav
assets/audio/ocean_loop.wav
assets/audio/stream_loop.wav
assets/audio/wind_loop.wav
assets/audio/fire_loop.wav
assets/audio/noise_loop.wav
```

如果报告要求“真实 CC0 实录”，按《音频素材-CC0筛选与登记模板.md》替换同名文件即可，
代码与 pubspec 都不用改；`test/audio_assets_test.dart` 会校验 6 个路径与文件一一对齐。
真机上的实际出声需用 `flutter run` 手动听一次，VM 测试只验证状态机与资源打包。

## 已知环境依赖

- 依赖下载走 `PUB_HOSTED_URL`（本机为 `https://pub.flutter-io.cn`）。若终端里残留不可用的
  `HTTP_PROXY/HTTPS_PROXY`，`pub get` 会报 socket error，先清掉代理变量再重试。
- Windows 首次解析插件时若提示 “Building with plugins requires symlink support”，
  按提示开启开发者模式（`start ms-settings:developers`）后重新 `flutter pub get`。
  本机复跑已正常（exit 0）。
