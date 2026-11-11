import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/diary_tags.dart';
import '../../core/theme/app_theme.dart';
import '../../models/diary_entry.dart';
import '../../providers/diary_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mood_picker.dart';
import '../../widgets/primary_button.dart';
import 'widgets/diary_tag_chips.dart';

/// 日记编辑：参数 DiaryEntry?（null = 新建），保存后 pop 返回 DiaryEntry。
class DiaryEditPage extends StatefulWidget {
  const DiaryEditPage({super.key, this.entry});

  final DiaryEntry? entry;

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final Set<String> _tags;

  int? _mood;
  bool _moodError = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final DiaryEntry? entry = widget.entry;
    _mood = entry?.mood;
    _tags = <String>{...?entry?.tags};
    _contentController = TextEditingController(text: entry?.content ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState?.validate() ?? false;
    final bool moodValid = _mood != null;
    if (!moodValid) {
      setState(() => _moodError = true);
    }
    if (!formValid || !moodValid) {
      return;
    }

    final DiaryEntry entry = DiaryEntry(
      id: widget.entry?.id,
      entryDate: widget.entry?.entryDate ?? DateTime.now(),
      mood: _mood!,
      content: _contentController.text.trim(),
      tags: _tags.toList(growable: false),
      createdAt: widget.entry?.createdAt,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _saving = true;
      _error = null;
    });
    final DiaryProvider provider = context.read<DiaryProvider>();
    final DiaryEntry? saved = await provider.saveEntry(entry);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (saved == null) {
      setState(() => _error = provider.error ?? '保存失败，请稍后再试');
      return;
    }
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final DiaryEntry? entry = widget.entry;
    final DateTime date = entry?.entryDate ?? DateTime.now();
    final List<String> availableTags = <String>{...kDiaryTags, ..._tags}.toList();
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: Text(entry == null ? '写日记' : '编辑日记')),
      body: AppBackground(
        tint: context.c.tintTonight,
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    entry == null
                        ? '不需要写很多，一句就够。'
                        : '正在编辑 ${formatMonthDay(date)} 的记录',
                    textAlign: TextAlign.center,
                    style: context.s.captionMuted,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GlassCard(
                    outlined: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _DiarySectionTitle('今天的心情'),
                        const SizedBox(height: AppSpacing.md),
                        MoodPicker(
                          value: _mood,
                          onChanged: (int value) {
                            setState(() {
                              _mood = value;
                              _moodError = false;
                            });
                          },
                        ),
                        if (_moodError) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '请选择今天的心情',
                            style: context.s.caption.copyWith(
                              color: context.c.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    outlined: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _DiarySectionTitle('正文'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _contentController,
                          minLines: 5,
                          maxLines: 9,
                          style: context.s.body,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: '今晚发生了什么？至少 5 个字',
                            filled: false,
                            border: InputBorder.none,
                          ),
                          validator: (String? value) {
                            if ((value ?? '').trim().length < 5) {
                              return '至少写 5 个字';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    outlined: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _DiarySectionTitle('标签（可多选）'),
                        const SizedBox(height: AppSpacing.md),
                        DiaryTagChips(
                          available: availableTags,
                          selected: _tags,
                          onToggle: (String tag) {
                            setState(() {
                              if (!_tags.add(tag)) {
                                _tags.remove(tag);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: context.s.caption.copyWith(
                        color: context.c.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: entry == null ? '保存' : '保存修改',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiarySectionTitle extends StatelessWidget {
  const _DiarySectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.s.subtitle);
  }
}
