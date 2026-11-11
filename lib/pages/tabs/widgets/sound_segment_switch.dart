import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 声屿分类分段：ASMR / Nature / Other。
class SoundSegmentSwitch extends StatelessWidget {
  const SoundSegmentSwitch({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>['ASMR', 'Nature', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.c.stroke),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _labels.length; i++)
            Expanded(
              child: _SegmentTab(
                label: _labels[i],
                selected: i == index,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.pill);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? context.c.secondary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: radius,
          ),
          child: Text(
            label,
            style: context.s.body.copyWith(
              color: selected ? context.c.secondary : context.c.textSecondary,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
