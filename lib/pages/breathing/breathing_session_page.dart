import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../models/breathing_mode.dart';
import '../../widgets/app_background.dart';
import 'widgets/breathing_circle.dart';
import 'widgets/breathing_dialogs.dart';
import 'widgets/breathing_phase_hint.dart';

enum _PhaseKind { inhale, hold, exhale, holdAfterExhale }

class _BreathPhase {
  const _BreathPhase(this.label, this.seconds, this.kind);

  final String label;
  final int seconds;
  final _PhaseKind kind;
}

/// 呼吸进行页：圆环缩放/发光、阶段倒计时、轮次、震动反馈与完成弹窗。
///
/// 动画与倒计时共用同一个 AnimationController，所以文案不会和圆环脱节；
/// 未完成返回先暂停动画并确认，避免用户误触直接丢掉本次练习。
class BreathingSessionPage extends StatefulWidget {
  const BreathingSessionPage({super.key, required this.mode});

  final BreathingMode mode;

  @override
  State<BreathingSessionPage> createState() => _BreathingSessionPageState();
}

class _BreathingSessionPageState extends State<BreathingSessionPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BreathPhase> _phases;

  int _phaseIndex = 0;
  int _cycle = 1;
  bool _completed = false;
  bool _confirmingExit = false;

  @override
  void initState() {
    super.initState();
    _phases = _buildPhases(widget.mode);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phases.first.seconds),
    )..addStatusListener(_onAnimationStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startPhase(0);
      }
    });
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  List<_BreathPhase> _buildPhases(BreathingMode mode) {
    return <_BreathPhase>[
      _BreathPhase('吸气', mode.inhale, _PhaseKind.inhale),
      if (mode.hold > 0) _BreathPhase('屏息', mode.hold, _PhaseKind.hold),
      _BreathPhase('呼气', mode.exhale, _PhaseKind.exhale),
      if (mode.hasHoldAfterExhale)
        _BreathPhase('屏息', mode.holdAfterExhale, _PhaseKind.holdAfterExhale),
    ];
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _advance();
    }
  }

  void _startPhase(int index) {
    if (!mounted || _completed) {
      return;
    }
    setState(() => _phaseIndex = index);
    _controller.duration = Duration(seconds: _phases[index].seconds);
    _controller.forward(from: 0);
    _lightHaptic();
  }

  void _advance() {
    if (_completed || !mounted) {
      return;
    }
    final int next = _phaseIndex + 1;
    if (next < _phases.length) {
      _startPhase(next);
      return;
    }
    if (_cycle < widget.mode.cycles) {
      setState(() => _cycle++);
      _startPhase(0);
      return;
    }
    _complete();
  }

  void _complete() {
    if (_completed) {
      return;
    }
    setState(() => _completed = true);
    _controller.stop();
    unawaited(HapticFeedback.heavyImpact().catchError((Object _) {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _finishFlow();
      }
    });
  }

  Future<void> _finishFlow() async {
    await showBreathingCompletionDialog(context, widget.mode.cycles);
    if (!mounted) {
      return;
    }
    Navigator.pop(context, widget.mode.cycles);
  }

  Future<void> _confirmExit() async {
    if (_confirmingExit || _completed) {
      return;
    }
    _confirmingExit = true;
    _controller.stop();
    final bool? leave = await showBreathingExitDialog(context);
    _confirmingExit = false;
    if (!mounted) {
      return;
    }
    if (leave == true) {
      Navigator.pop(context);
      return;
    }
    if (!_completed) {
      _controller.forward();
    }
  }

  void _lightHaptic() {
    unawaited(HapticFeedback.lightImpact().catchError((Object _) {}));
  }

  double _scaleFor(_PhaseKind kind, double value) {
    return switch (kind) {
      _PhaseKind.inhale => 0.84 + 0.22 * value,
      _PhaseKind.hold => 1.06,
      _PhaseKind.exhale => 1.06 - 0.22 * value,
      _PhaseKind.holdAfterExhale => 0.84,
    };
  }

  String _hintFor(_PhaseKind kind) {
    return switch (kind) {
      _PhaseKind.inhale => '用鼻子缓慢吸气',
      _PhaseKind.hold => '轻轻屏住',
      _PhaseKind.exhale => '用嘴缓慢呼气',
      _PhaseKind.holdAfterExhale => '保持放松',
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop || _completed) {
          return;
        }
        _confirmExit();
      },
      child: Scaffold(
        backgroundColor: context.c.bgDeep,
        appBar: AppBar(title: Text(widget.mode.name)),
        body: AppBackground(
          tint: context.c.tintSound,
          child: SafeArea(
            top: false,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final _BreathPhase phase = _phases[_phaseIndex];
                final double value = _controller.value;
                final int remaining = math.max(
                  1,
                  (phase.seconds * (1 - value)).ceil(),
                );
                final double scale = _scaleFor(phase.kind, value);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.mode.description,
                        textAlign: TextAlign.center,
                        style: context.s.captionMuted,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BreathingCircle(
                        scale: scale,
                        phaseLabel: phase.label,
                        seconds: remaining,
                        cycle: _cycle,
                        cycles: widget.mode.cycles,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BreathingPhaseHint(text: _hintFor(phase.kind)),
                      const SizedBox(height: AppSpacing.xxl),
                      TextButton(
                        onPressed: _confirmExit,
                        style: TextButton.styleFrom(
                          foregroundColor: context.c.textSecondary,
                          textStyle: context.s.caption,
                        ),
                        child: const Text('结束练习'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
