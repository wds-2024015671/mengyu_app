class SleepTipMethod {
  const SleepTipMethod({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}

class SleepTipSection {
  const SleepTipSection({
    required this.number,
    required this.title,
    required this.paragraphs,
    this.methods = const <SleepTipMethod>[],
  });

  final String number;
  final String title;
  final List<String> paragraphs;
  final List<SleepTipMethod> methods;
}

const List<String> kSleepTipRowTitles = <String>[
  '行为核心',
  '环境、饮食与运动',
  '心理与放松',
  '呼吸法介绍',
];

const List<SleepTipSection> kSleepTipSections = <SleepTipSection>[
  SleepTipSection(
    number: '01',
    title: '行为核心',
    paragraphs: <String>[
      '建立床与睡眠的唯一联结，床只用来睡觉。只在有睡意时才上床，如果躺下二十分钟左右依然无法入睡，请果断起床离开卧室，去做一些安静不费脑的事情，直到再次感到困倦才回床。',
      '无论前一晚睡了多久或者睡得有多差，每天早晨都要在固定时间起床，周末也不例外，这能帮助生物钟重新建立稳定的节律。不要试图通过周末早早上床或赖床来补偿欠下的睡眠，这会稀释睡眠驱动力导致睡眠变浅且容易醒。适度压缩卧床时间反而能有效积累睡眠压力，当你连续几天睡眠效率提升后，再逐步提前上床时间。',
      '白天尽量多接触自然光照，特别是在清晨，这有助于调节体内褪黑素的分泌周期。',
    ],
  ),
  SleepTipSection(
    number: '02',
    title: '环境、饮食与运动',
    paragraphs: <String>[
      '环境方面卧室温度保持在十八到二十二度最为适宜，微凉的体感有助于核心体温下降从而诱发睡意。尽量使用遮光窗帘保持全黑环境，黑暗是褪黑素顺利分泌的前提条件，必要时可以使用持续的低分贝白噪音来掩盖窗外的突发噪音。寝具的舒适度同样不容忽视，选择支撑力合适的床垫和枕头，减少夜间因为身体不适造成的微觉醒。',
      '饮食方面下午两点之后应尽量避免摄入咖啡因，睡前尽量不要饮酒，酒精虽然能让人快速昏睡，但会严重破坏后半夜的睡眠结构，导致早醒和睡眠变浅。晚餐与入睡间隔至少三小时，睡前两小时避免大量饮水以减少起夜，带着轻微的饥饿感入睡往往比吃得太饱睡得更沉。',
      '运动方面下午或傍晚进行快走、游泳等中等强度的有氧运动最有助于提升睡眠质量，睡前两小时内应避免剧烈运动导致交感神经兴奋，可以改为低强度的拉伸或散步。',
    ],
  ),
  SleepTipSection(
    number: '03',
    title: '心理与放松',
    paragraphs: <String>[
      '睡前一到两小时尽量远离电子屏幕，避免手机蓝光过度抑制褪黑素分泌。如果躺下后思绪繁杂难以平静，建议在白天或傍晚拿出一张纸写下一份担忧清单，把未解决的问题和待办事项具象化地留在纸面上，告诉自己留到白天再处理，不要在床上思考明日计划。',
      '尝试通过正念冥想或简单的身体扫描，将注意力温和地集中在呼吸或身体感觉上，不评判杂念，让大脑从警觉的思考模式逐渐平复。建立专属的睡前仪式感也很重要，比如温水泡脚、听一段轻柔的音乐或阅读几页纸质书，通过重复的固定动作给大脑发送准备入睡的信号。',
    ],
  ),
  SleepTipSection(
    number: '04',
    title: '呼吸法介绍',
    paragraphs: <String>[
      '呼吸助眠法的核心原理是通过调整呼吸节奏，特别是延长呼气的时间，来激活负责放松的副交感神经，从而降低心率，让身体从紧张状态平稳过渡到休息状态。',
    ],
    methods: <SleepTipMethod>[
      SleepTipMethod(
        title: '4-7-8 呼吸法',
        paragraphs: <String>[
          '吸气四秒，屏住呼吸七秒，嘴巴缓慢呼气八秒。呼气时长为吸气的两倍，能强效激活副交感神经，非常适合快速降低心率进入放松状态。练习时可以将舌尖轻轻抵在上颚，呼气时可以微微发出呼呼的声音。建议进行四轮，总时长约七十六秒，初学者如果觉得屏息七秒有难度，可以适当缩短为四秒。',
        ],
      ),
      SleepTipMethod(
        title: '方块呼吸法',
        paragraphs: <String>[
          '吸气四秒，屏息四秒，呼气四秒，再屏息四秒。节奏完全对称，就像沿着正方形的四条边匀速移动，适合思绪纷飞时用来锚定注意力。这种对称的节奏能够帮助平稳心率，在紧张或焦虑时迅速平复情绪。建议进行四轮，总时长约六十四秒，练习时可以在脑海中想象一个正方形，跟着节点在边上移动。',
        ],
      ),
      SleepTipMethod(
        title: '4-4-6 呼吸法',
        paragraphs: <String>[
          '吸气四秒，屏息四秒，呼气六秒。核心在于呼气时间略长于吸气和屏息时间，温和地延长呼气过程，帮助心率平稳回落。相比于 4-7-8 呼吸法，它不需要过长时间的屏息，适合觉得屏息七秒有压力的用户。建议进行五轮，总时长约七十秒，重点体会呼气时身体逐渐卸下沉重的力气、慢慢放松的感觉。',
        ],
      ),
    ],
  ),
];

const String kSleepTipCbti =
    '如果失眠问题长期持续（如每周 3 次以上、持续 3 个月以上），并伴有明显的日间功能损害，单纯的自我调节可能不够，寻求专业评估和 CBT-I 治疗是更稳妥的选择。';
