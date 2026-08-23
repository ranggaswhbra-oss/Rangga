import 'package:flutter/material.dart';
import '../game/match_state.dart';

/// Banner "GOAL!" ala broadcast TV yang muncul singkat lalu menghilang
/// setiap kali `matchState.goalEventId` berubah.
class GoalBannerOverlay extends StatefulWidget {
  final MatchState matchState;
  const GoalBannerOverlay({super.key, required this.matchState});

  @override
  State<GoalBannerOverlay> createState() => _GoalBannerOverlayState();
}

class _GoalBannerOverlayState extends State<GoalBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  int _lastSeenEventId = 0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _lastSeenEventId = widget.matchState.goalEventId;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    widget.matchState.addListener(_checkGoal);
  }

  void _checkGoal() {
    final ms = widget.matchState;
    if (ms.goalEventId != _lastSeenEventId) {
      _lastSeenEventId = ms.goalEventId;
      setState(() => _visible = true);
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _visible = false);
      });
    }
  }

  @override
  void dispose() {
    widget.matchState.removeListener(_checkGoal);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final side = widget.matchState.lastGoalSide;
    final subtitle = side == TeamSide.home ? 'TIM ANDA' : 'LAWAN';

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GOAL!',
                style: TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 4)),
                    const Shadow(color: Color(0xFFFFD54F), blurRadius: 30),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
