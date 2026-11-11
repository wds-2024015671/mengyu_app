import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/local_media_service.dart';
import '../../../models/private_media.dart';
import '../../../providers/private_media_provider.dart';
import '../../../widgets/primary_button.dart';
import 'import_media_controls.dart';

class PrivateImportSheet extends StatefulWidget {
  const PrivateImportSheet({super.key, required this.service});

  final LocalMediaService service;

  @override
  State<PrivateImportSheet> createState() => _PrivateImportSheetState();
}

class _PrivateImportSheetState extends State<PrivateImportSheet> {
  PrivateMediaType _type = PrivateMediaType.audio;
  File? _file;
  String? _error;
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _error = null);
    try {
      final File? picked = await widget.service.pick(_type);
      if (mounted && picked != null) {
        setState(() => _file = picked);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppException.describe(error, fallback: '无法打开文件选择器'));
      }
    }
  }

  Future<void> _start() async {
    final File? source = _file;
    if (source == null) {
      setState(() => _error = '请先选择本地音频或视频');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final PrivateMediaProvider provider = context.read<PrivateMediaProvider>();
    try {
      final PickedLocalMedia picked = await widget.service.import(source, _type);
      final bool saved = await provider.importMedia(
        PrivateMedia(
          id: 0,
          type: _type,
          title: picked.title,
          sourceUrl: picked.source.path,
          localPath: picked.file.path,
          durationMs: picked.durationMs,
          platform: '本地',
          fileSize: picked.fileSize,
          status: PrivateMediaStatus.ready,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) {
        return;
      }
      if (!saved) {
        throw AppException(provider.error ?? '写入私人库失败');
      }
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = AppException.describe(error, fallback: '导入失败，请重试');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: context.c.sheet,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('添加到私人库', style: context.s.title),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: _busy ? null : () => Navigator.pop(context, false),
                      icon: Icon(Icons.close, color: context.c.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '选择手机里的音频或视频，保存到私人库',
                  style: context.s.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                ImportFileCard(
                  file: _file,
                  type: _type,
                  onPick: _pick,
                  enabled: !_busy,
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  ImportErrorBox(
                    message: _error!,
                    onRetry: _file == null ? _pick : _start,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ImportFormatSelector(
                  type: _type,
                  onChanged: (PrivateMediaType value) {
                    if (!_busy) {
                      setState(() {
                        _type = value;
                        _file = null;
                        _error = null;
                      });
                    }
                  },
                  enabled: !_busy,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: _busy ? '导入中…' : '导入私人库',
                  loading: _busy,
                  onPressed: _busy ? null : _start,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '文件只复制到 App 私有目录，不上传服务器\n'
                  '请确认你拥有相应的使用权',
                  style: context.s.micro.copyWith(
                    color: context.c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
