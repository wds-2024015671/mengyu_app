import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_limits.dart';
import '../../core/errors/app_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/audio_file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/upload_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/primary_button.dart';
import 'widgets/upload_file_card.dart';
import 'widgets/upload_terms_field.dart';

/// 上传声音：选文件 → 填表单 → 本地复制 + 写入 my_uploads(status=0)。
class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.pickFile = pickAudioFile});

  /// 便于测试注入假选择器；默认走 file_picker。
  final AudioFilePicker pickFile;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  String? _category;
  PickedAudioFile? _pickedFile;
  String? _fileError;
  bool _authReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAuth());
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _ensureAuth() async {
    final AuthProvider auth = context.read<AuthProvider>();
    await auth.ensureLoaded();
    if (!mounted) {
      return;
    }
    if (!auth.isLoggedIn) {
      // 游客与未登录都要求先登录，上传必须绑定真实账号。
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    setState(() => _authReady = true);
  }

  Future<void> _pickFile() async {
    try {
      final PickedAudioFile? picked = await widget.pickFile();
      if (!mounted || picked == null) {
        return;
      }
      const int maxMb = kMaxAudioUploadBytes ~/ (1024 * 1024);
      if (picked.size > kMaxAudioUploadBytes) {
        setState(() {
          // 明确清掉旧选择：避免用户以为选了大文件，实际提交的却是上一首。
          _pickedFile = null;
          _fileError = '音频文件不能超过 ${maxMb}MB';
        });
        return;
      }
      setState(() { _pickedFile = picked; _fileError = null; });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fileError = AppException.describe(error, fallback: '选择文件失败，请再试一次');
      });
    }
  }

  void _clearFile() {
    setState(() {
      _pickedFile = null;
      _fileError = null;
    });
  }

  String? _validateTitle(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return '请填写标题';
    }
    if (text.length > kUploadTitleMaxLength) {
      return '标题不能超过 $kUploadTitleMaxLength 个字符';
    }
    return null;
  }

  Future<void> _submit() async {
    final UploadProvider uploads = context.read<UploadProvider>();
    if (uploads.isSubmitting) {
      return;
    }
    FocusScope.of(context).unfocus();

    final bool formOk = _formKey.currentState?.validate() ?? false;
    final PickedAudioFile? picked = _pickedFile;
    if (picked == null) {
      setState(() => _fileError = '请选择音频文件');
    }
    if (!formOk || picked == null) {
      return;
    }

    final bool ok = await uploads.upload(
      filePath: picked.path,
      title: _title.text.trim(),
      category: _category!,
      description: _description.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uploads.error ?? '上传失败，请稍后再试')),
      );
      return;
    }
    // UploadProvider 已经回读过 my_uploads；SoundTab 收到 true 再刷新并切分区。
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final UploadProvider uploads = context.watch<UploadProvider>();
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: const Text('上传声音')),
      body: AppBackground(
        tint: context.c.tintMine,
        child: SafeArea(
          top: false,
          child: !_authReady
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.c.secondary,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.page,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('把喜欢的声音留在岛上', style: context.s.subtitle),
                        const SizedBox(height: AppSpacing.sm),
                        Text('审核通过后会出现在公共声库。', style: context.s.captionMuted),
                        const SizedBox(height: AppSpacing.xl),
                        UploadFileCard(
                          file: _pickedFile,
                          error: _fileError,
                          enabled: !uploads.isSubmitting,
                          onPick: _pickFile,
                          onClear: _clearFile,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextFormField(
                          controller: _title,
                          enabled: !uploads.isSubmitting,
                          maxLength: kUploadTitleMaxLength,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(hintText: '标题（必填）', counterText: ''),
                          validator: _validateTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          value: _category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            hintText: '分类（必选）',
                          ),
                          items: <DropdownMenuItem<String>>[
                            for (final String category in kAudioCategories)
                              DropdownMenuItem<String>(value: category, child: Text(category)),
                          ],
                          onChanged: uploads.isSubmitting
                              ? null
                              : (String? value) =>
                                  setState(() => _category = value),
                          validator: (String? value) =>
                              (value == null || value.isEmpty) ? '请选择分类' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _description,
                          enabled: !uploads.isSubmitting,
                          maxLength: kUploadDescriptionMaxLength,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: '简介（选填，最多 255 字）',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        UploadTermsField(enabled: !uploads.isSubmitting),
                        const SizedBox(height: AppSpacing.xl),
                        if (uploads.isSubmitting) ...<Widget>[
                          LinearProgressIndicator(
                            minHeight: 3,
                            color: context.c.secondary,
                            backgroundColor: context.c.stroke,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('正在保存音频并提交审核…', style: context.s.captionMuted),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        PrimaryButton(
                          label: '提交审核',
                          loading: uploads.isSubmitting,
                          onPressed: _submit,
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
