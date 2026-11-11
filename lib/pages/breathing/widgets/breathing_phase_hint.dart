import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


class BreathingPhaseHint extends StatelessWidget {
  const BreathingPhaseHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.s.bodySecondary,
    );
  }
}
