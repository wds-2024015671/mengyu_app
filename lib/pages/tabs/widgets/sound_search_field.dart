import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 声屿搜索框：44 高、14 圆角、1px stroke、透明底。
class SoundSearchField extends StatefulWidget {
  const SoundSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = '搜索名称.......',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<SoundSearchField> createState() => _SoundSearchFieldState();
}

class _SoundSearchFieldState extends State<SoundSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant SoundSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    return SizedBox(
      height: 44,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        cursorColor: context.c.secondary,
        style: context.s.body,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: context.s.body.copyWith(
            color: context.c.textTertiary,
          ),
          filled: false,
          isDense: true,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: context.c.textTertiary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: '清空搜索',
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: context.c.textTertiary,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          border: _border(context.c.stroke),
          enabledBorder: _border(context.c.stroke),
          focusedBorder: _border(context.c.stroke),
        ),
      ),
    );
  }
}
