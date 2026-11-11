/// 上传相关常量：页面、文件选择器、Local 实现共用同一份，避免三处写死。
///
/// 为什么集中：20MB 限制一旦只改页面不改仓库，就会出现“页面放行、落库失败”
/// 的割裂体验；标题/简介长度与分类选项也同理。
const int kMaxAudioUploadBytes = 20 * 1024 * 1024;
const int kUploadTitleMaxLength = 80;
const int kUploadDescriptionMaxLength = 255;

const List<String> kAudioExtensions = <String>['mp3', 'wav', 'ogg', 'm4a'];

const List<String> kAudioCategories = <String>[
  '雨声',
  '海浪',
  '森林',
  '白噪',
  '故事',
  '其他',
];
