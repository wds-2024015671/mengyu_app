import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/yt_dlp_service.dart';
import '../../../models/private_media.dart';
import '../../../providers/private_media_provider.dart';
import '../../../widgets/primary_button.dart';
import 'import_cancel_dialog.dart';
import 'import_media_controls.dart';
import 'private_import_runner.dart';
class PrivateImportSheet extends StatefulWidget {
  const PrivateImportSheet({super.key, required this.service});
  final YtDlpService service;
  @override
  State<PrivateImportSheet> createState() => _PrivateImportSheetState();
}
class _PrivateImportSheetState extends State<PrivateImportSheet> {
  final TextEditingController _link = TextEditingController();
  PrivateMediaType _type = PrivateMediaType.audio;
  PrivateMediaStatus _phase = PrivateMediaStatus.ready;
  ParsedMediaInfo? _parsed;
  late final PrivateImportRunner _runner;
  double _progress = 0;
  String? _error;
  bool _duplicate = false;
  bool _busy = false;
  bool get _downloading => _phase == PrivateMediaStatus.downloading && _busy;
  bool get _parsing => _busy && _parsed == null;
  @override
  void initState() {
    super.initState();
    _runner = PrivateImportRunner(widget.service);
  }
  @override
  void dispose() {
    _runner.cancel();
    _link.dispose();
    super.dispose();
  }
  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text != null && text.isNotEmpty && mounted) {
      _link.text = text.trim();
      setState(() => _error = null);
    }
  }
  Future<void> _start() async {
    final String url = _link.text.trim();
    if (DirectYtDlpService.validateMediaUrl(url) == null) {
      setState(() => _error = '请输入有效的 http(s) 链接');
      return;
    }
    final PrivateMediaProvider provider = context.read<PrivateMediaProvider>();
    final bool duplicate = await provider.existsByUrl(url);
    if (!mounted) return;
    setState(() {
      _duplicate = duplicate;
      _busy = true;
      _phase = PrivateMediaStatus.downloading;
      _error = null;
      _parsed = null;
      _progress = 0;
    });
    try {
      final PrivateImportRun run = await _runner.run(
        url: url,
        type: _type,
        onParsed: (ParsedMediaInfo media) {
          if (mounted) {
            setState(() => _parsed = media);
          }
        },
        onProgress: (double value) {
          if (mounted) {
            setState(() => _progress = value);
          }
        },
      );
      if (!mounted) {
        return;
      }
      final bool saved = await provider.importMedia(
        PrivateMedia(
          id: 0,
          type: _type,
          title: run.media.title,
          sourceUrl: run.media.url,
          localPath: run.file.path,
          durationMs: run.media.durationMs,
          platform: run.media.platform,
          fileSize: run.fileSize,
          status: PrivateMediaStatus.ready,
          createdAt: DateTime.now(),
          thumbUrl: run.media.thumbnailUrl,
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
        _phase = PrivateMediaStatus.failed;
        _error = AppException.describe(error, fallback: '解析或下载失败，请重试');
      });
    }
  }
  Future<void> _cancelDownload() async {
    _runner.cancel();
    setState(() {
      _busy = false;
      _phase = PrivateMediaStatus.failed;
      _progress = 0;
      _error = '已取消下载';
    });
  }
  Future<void> _close() async {
    if (_busy || _downloading) {
      final bool close = await confirmCancelDownload(context);
      if (!close) {
        return;
      }
      _runner.cancel();
    }
    if (mounted) {
      Navigator.pop(context, false);
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
                      onPressed: _close,
                      icon: Icon(Icons.close, color: context.c.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '粘贴视频链接，解析后下载音频或视频',
                  style: context.s.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                ImportLinkField(
                  controller: _link,
                  onPaste: _paste,
                  enabled: !_busy,
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  ImportErrorBox(message: _error!, onRetry: _start),
                ],
                const SizedBox(height: AppSpacing.md),
                ImportFormatSelector(
                  type: _type,
                  onChanged: (PrivateMediaType value) {
                    if (!_busy) {
                      setState(() => _type = value);
                    }
                  },
                  enabled: !_busy,
                ),
                if (_parsed != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  ImportParsedCard(media: _parsed!),
                ],
                if (_duplicate) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '这个链接已在私人库，可以重新下载一份。',
                    style: context.s.micro.copyWith(color: context.c.textTertiary),
                  ),
                ],
                if (_downloading) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  ImportProgress(
                    progress: _progress,
                    onCancel: _cancelDownload,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: _parsing
                      ? '解析中…'
                      : _downloading
                          ? '下载中…'
                          : '解析并下载',
                  loading: _busy,
                  onPressed: _busy ? null : _start,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '支持 Bilibili / YouTube / 抖音等公开链接 · 文件保存在本地\n'
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
