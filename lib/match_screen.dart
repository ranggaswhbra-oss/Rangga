import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/gaaftbll_game.dart';
import 'game/match_state.dart';
import 'ui/control_overlay.dart';
import 'ui/goal_banner_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/result_overlay.dart';

/// Channel untuk memanggil kode native Kotlin (contoh: getar HP)
const _nativeChannel = MethodChannel('gaaftbll/native');

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late final MatchState matchState;
  late final GaaftbllGame game;

  @override
  void initState() {
    super.initState();
    matchState = MatchState(halfDurationSeconds: 180);
    game = GaaftbllGame(
      matchState: matchState,
      onHapticEvent: _triggerNativeHaptic,
    );
    matchState.addListener(_onMatchStateChanged);
  }

  void _onMatchStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _triggerNativeHaptic(String eventType) async {
    try {
      await _nativeChannel.invokeMethod('vibrate', {'type': eventType});
    } catch (_) {
      // Native channel opsional; abaikan jika belum tersedia di platform ini.
    }
  }

  @override
  void dispose() {
    matchState.removeListener(_onMatchStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          // Vignette sinematik ala kamera broadcast TV
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [Colors.transparent, Colors.transparent, Color(0x99000000)],
                    stops: [0.0, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: GoalBannerOverlay(matchState: matchState)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: HudOverlay(matchState: matchState)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: ControlOverlay(
                onMove: (v) => game.moveInput = v,
                onSprintChanged: (v) => game.sprintHeld = v,
                onPass: game.actionPass,
                onShoot: game.actionShoot,
                onTackle: game.actionTackle,
                onSwitch: game.actionSwitchPlayer,
                onPauseToggle: () {
                  setState(() {
                    matchState.isPaused = !matchState.isPaused;
                  });
                },
                isPaused: matchState.isPaused,
              ),
            ),
          ),
          if (matchState.isMatchOver)
            Positioned.fill(
              child: ResultOverlay(
                matchState: matchState,
                onExit: () => Navigator.of(context).pop(),
                onRematch: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MatchScreen()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
