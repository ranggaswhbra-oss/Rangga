import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ai_logic.dart';
import 'ball_component.dart';
import 'ball_trail_component.dart';
import 'field_component.dart';
import 'match_state.dart';
import 'player_component.dart';
import 'referee.dart';

/// Callback native (Kotlin) untuk getar HP saat gol / tekel / kartu.
typedef HapticCallback = void Function(String eventType);

/// Mode kamera dinamis ala broadcast bola: mengikuti bola, zoom otomatis
/// makin dekat gawang, shake saat gol, dan slow-motion replay singkat.
class GaaftbllGame extends FlameGame {
  final MatchState matchState;
  final HapticCallback? onHapticEvent;

  GaaftbllGame({required this.matchState, this.onHapticEvent});

  late final BallComponent ball;
  late final Referee referee;
  final AiLogic _aiLogic = AiLogic();
  final List<PlayerComponent> players = [];
  PlayerComponent? controlledPlayer;

  Vector2 moveInput = Vector2.zero();
  bool sprintHeld = false;

  final Random _rng = Random();

  // ---------------- Kamera dinamis ----------------
  final Vector2 _zoomedIn = Vector2(950, 640); // dekat kotak penalti
  final Vector2 _zoomedOut = Vector2(1300, 820); // umum / tengah lapangan
  late Vector2 _currentZoomSize;
  final Random _shakeRng = Random();
  double _cameraShakeTimer = 0;
  double _cameraShakeMagnitude = 0;

  // ---------------- Slow-motion replay gol ----------------
  double _slowMoTimer = 0;
  static const double _slowMoFactor = 0.28;
  bool get isSlowMo => _slowMoTimer > 0;

  @override
  Color backgroundColor() => const Color(0xFF0B5D26);

  @override
  Future<void> onLoad() async {
    _currentZoomSize = _zoomedOut.clone();
    camera.viewfinder.visibleGameSize = _currentZoomSize.clone();
    camera.viewfinder.position = Vector2(FieldSpec.width / 2, FieldSpec.height / 2);
    camera.viewfinder.anchor = Anchor.center;

    world.add(FieldComponent());

    ball = BallComponent(startPosition: Vector2(FieldSpec.width / 2, FieldSpec.height / 2));
    referee = Referee(matchState, onGoal: _handleGoalScored);

    _spawnTeam(TeamSide.home);
    _spawnTeam(TeamSide.away);

    for (final p in players) {
      world.add(p);
    }
    world.add(ball);
    world.add(BallTrailComponent(ball));

    _pickInitialControlledPlayer();
  }

  /// Susunan 11 pemain: 1 GK, 4 DF, 4 MF, 2 FW (formasi 4-4-2 sederhana)
  void _spawnTeam(TeamSide side) {
    final bool isHome = side == TeamSide.home;
    final color = isHome ? const Color(0xFF2255CC) : const Color(0xFFCC2222);
    final pitch = FieldSpec.pitchRect;

    // x dihitung relatif: home di sisi kiri menyerang ke kanan, away sebaliknya
    double xFor(double fractionFromOwnGoal) {
      final w = pitch.width;
      return isHome ? pitch.left + w * fractionFromOwnGoal : pitch.right - w * fractionFromOwnGoal;
    }

    final positions = <List<double>>[
      // [fractionFromOwnGoal(0..1), yFraction(0..1)]
      [0.04, 0.5], // GK
      [0.18, 0.18], [0.18, 0.40], [0.18, 0.60], [0.18, 0.82], // DF x4
      [0.50, 0.15], [0.50, 0.40], [0.50, 0.60], [0.50, 0.85], // MF x4
      [0.78, 0.35], [0.78, 0.65], // FW x2
    ];
    final roles = [
      PlayerRole.gk,
      PlayerRole.df, PlayerRole.df, PlayerRole.df, PlayerRole.df,
      PlayerRole.mf, PlayerRole.mf, PlayerRole.mf, PlayerRole.mf,
      PlayerRole.fw, PlayerRole.fw,
    ];

    for (int i = 0; i < 11; i++) {
      final frac = positions[i];
      final x = xFor(frac[0]);
      final y = pitch.top + pitch.height * frac[1];
      final player = PlayerComponent(
        number: i + 1,
        team: side,
        role: roles[i],
        jerseyColor: color,
        startPosition: Vector2(x, y),
      );
      players.add(player);
    }
  }

  void _pickInitialControlledPlayer() {
    // Kontrol pemain penyerang tim Home yang paling dekat bola di kickoff
    final homeAttackers =
        players.where((p) => p.team == TeamSide.home && p.role != PlayerRole.gk).toList();
    homeAttackers.sort((a, b) =>
        a.position.distanceTo(ball.position).compareTo(b.position.distanceTo(ball.position)));
    _setControlledPlayer(homeAttackers.first);
  }

  void _setControlledPlayer(PlayerComponent p) {
    if (controlledPlayer != null) controlledPlayer!.isUserControlled = false;
    controlledPlayer = p;
    p.isUserControlled = true;
  }

  /// Otomatis pindah kontrol ke pemain Home terdekat dengan bola
  /// (mirip mekanisme "switch player" pada eFootball).
  void autoSwitchToNearestBall() {
    final homePlayers = players.where((p) => p.team == TeamSide.home && !p.isSentOff).toList();
    homePlayers.sort((a, b) =>
        a.position.distanceTo(ball.position).compareTo(b.position.distanceTo(ball.position)));
    if (homePlayers.isNotEmpty) {
      _setControlledPlayer(homePlayers.first);
    }
  }

  @override
  void update(double dt) {
    // Timer sinematik (shake & slow-mo) selalu jalan di waktu nyata,
    // supaya tetap terasa walau gameplay sedang di-pause sesaat.
    if (_slowMoTimer > 0) {
      _slowMoTimer = (_slowMoTimer - dt).clamp(0.0, double.infinity);
    }
    if (_cameraShakeTimer > 0) {
      _cameraShakeTimer = (_cameraShakeTimer - dt).clamp(0.0, double.infinity);
    }

    // dt efektif untuk gameplay (diperlambat saat replay gol - efek slow-motion)
    final effectiveDt = isSlowMo ? dt * _slowMoFactor : dt;

    _updateCamera(dt);

    if (matchState.isPaused || matchState.isMatchOver) {
      super.update(0);
      return;
    }

    matchState.tick(dt); // waktu pertandingan tetap berjalan normal (tidak ikut slow-mo)

    // Gerakkan pemain yang dikendalikan user (tombol LARI = sprint)
    final cp = controlledPlayer;
    if (cp != null && !cp.isSentOff) {
      cp.isSprinting = sprintHeld;
      if (moveInput.length > 0.05) {
        cp.velocity = moveInput.normalized() * cp.currentSpeed;
      } else {
        cp.velocity = Vector2.zero();
      }
      cp.clampToField(FieldSpec.pitchRect);
    }

    _aiLogic.update(
      dt: effectiveDt,
      allPlayers: players,
      ball: ball,
      userControlledPlayer: controlledPlayer,
    );

    _handleBallPossession();
    referee.checkBall(ball);

    // Auto switch kontrol kalau bola sudah jauh dari pemain yang dikendalikan
    if (cp != null && cp.position.distanceTo(ball.position) > 260) {
      autoSwitchToNearestBall();
    }

    // Propagasi dt (yang sudah diperlambat saat replay) ke semua komponen anak
    // (pemain & bola) supaya posisinya ikut ter-update secara sinematik.
    super.update(effectiveDt);
  }

  /// Kamera dinamis: mengikuti bola dengan pergerakan halus (smooth follow),
  /// zoom otomatis lebih dekat saat mendekati kotak penalti, dan efek
  /// getar (shake) singkat saat terjadi gol.
  void _updateCamera(double dt) {
    final pitch = FieldSpec.pitchRect;
    final nearPenaltyBox =
        ball.position.x < pitch.left + 300 || ball.position.x > pitch.right - 300;
    final targetZoom = nearPenaltyBox ? _zoomedIn : _zoomedOut;

    // Lerp ukuran zoom secara halus
    final zoomLerpFactor = (3.5 * dt).clamp(0.0, 1.0);
    _currentZoomSize
      ..x += (targetZoom.x - _currentZoomSize.x) * zoomLerpFactor
      ..y += (targetZoom.y - _currentZoomSize.y) * zoomLerpFactor;
    camera.viewfinder.visibleGameSize = _currentZoomSize.clone();

    // Posisi kamera mengejar bola, tetap dalam batas lapangan
    final halfW = _currentZoomSize.x / 2;
    final halfH = _currentZoomSize.y / 2;
    final desired = Vector2(
      ball.position.x.clamp(halfW, FieldSpec.width - halfW),
      ball.position.y.clamp(halfH, FieldSpec.height - halfH),
    );

    final followLerpFactor = (4.5 * dt).clamp(0.0, 1.0);
    final current = camera.viewfinder.position;
    final newPos = Vector2(
      current.x + (desired.x - current.x) * followLerpFactor,
      current.y + (desired.y - current.y) * followLerpFactor,
    );

    // Tambahkan efek shake (getar layar) saat gol
    if (_cameraShakeTimer > 0) {
      final decay = _cameraShakeTimer; // makin kecil makin mendekati akhir
      final shakeX = (_shakeRng.nextDouble() - 0.5) * _cameraShakeMagnitude * decay;
      final shakeY = (_shakeRng.nextDouble() - 0.5) * _cameraShakeMagnitude * decay;
      camera.viewfinder.position = Vector2(newPos.x + shakeX, newPos.y + shakeY);
    } else {
      camera.viewfinder.position = newPos;
    }
  }

  void _handleGoalScored(TeamSide scoringSide, Vector2 goalPosition) {
    _slowMoTimer = 1.4;
    _cameraShakeTimer = 0.45;
    _cameraShakeMagnitude = 16;
    onHapticEvent?.call('goal');
  }

  void _handleBallPossession() {
    // Kalau pemain (siapapun) cukup dekat dengan bola & bola pelan,
    // anggap bola "menempel" mengikuti dribble ringan untuk pemain yang dikontrol AI.
    for (final p in players) {
      if (p.isSentOff) continue;
      final d = p.position.distanceTo(ball.position);
      if (d < 22) {
        ball.lastTouchedBy = p.team;
        ball.lastTouchedByNumber = p.number;
        matchState.lastTeamTouchedBall = p.team;
      }
    }
  }

  // ================== AKSI KONTROL (dipanggil dari UI tombol) ==================

  /// Tombol OPER: mengoper ke rekan setim terdekat yang lebih maju/terbuka
  void actionPass() {
    final cp = controlledPlayer;
    if (cp == null || cp.isSentOff) return;

    final teammates = players
        .where((p) => p.team == cp.team && p != cp && !p.isSentOff)
        .toList();
    if (teammates.isEmpty) return;

    teammates.sort((a, b) =>
        a.position.distanceTo(cp.position).compareTo(b.position.distanceTo(cp.position)));
    final target = teammates.first;

    final dir = target.position - ball.position;
    ball.kick(dir, 420);
    matchState.addCommentary('Umpan dari #${cp.number} ke #${target.number}');
    onHapticEvent?.call('pass');
  }

  /// Tombol TENDANG: menembak ke arah gawang lawan
  void actionShoot() {
    final cp = controlledPlayer;
    if (cp == null || cp.isSentOff) return;

    final isHome = cp.team == TeamSide.home;
    final targetGoal = isHome
        ? Vector2(FieldSpec.pitchRight, FieldSpec.height / 2)
        : Vector2(FieldSpec.pitchLeft, FieldSpec.height / 2);

    // Sedikit variasi acak supaya tidak selalu tepat sasaran (arcade feel)
    final variance = (_rng.nextDouble() - 0.5) * 90;
    final target = targetGoal + Vector2(0, variance);

    final dir = target - ball.position;
    ball.kick(dir, 780);
    matchState.addCommentary('#${cp.number} melepaskan tendangan!');
    onHapticEvent?.call('shoot');
  }

  /// Tombol LAWAN: mencoba merebut bola dari lawan terdekat (tekel)
  void actionTackle() {
    final cp = controlledPlayer;
    if (cp == null || cp.isSentOff) return;

    final opponents = players.where((p) => p.team != cp.team && !p.isSentOff).toList();
    if (opponents.isEmpty) return;

    opponents.sort((a, b) =>
        a.position.distanceTo(cp.position).compareTo(b.position.distanceTo(cp.position)));
    final nearest = opponents.first;

    final distToOpponent = nearest.position.distanceTo(cp.position);
    final distOpponentToBall = nearest.position.distanceTo(ball.position);

    if (distToOpponent > 55 || distOpponentToBall > 40) {
      matchState.addCommentary('#${cp.number} mencoba menekel tapi terlalu jauh');
      return;
    }

    final success = referee.attemptTackle(tackler: cp, opponent: nearest, ball: ball);
    // Getar kamera ringan setiap benturan tekel biar terasa "berat" (impact feel)
    _cameraShakeTimer = 0.18;
    _cameraShakeMagnitude = 6;
    if (success) {
      final dir = (cp.team == TeamSide.home)
          ? Vector2(1, (_rng.nextDouble() - 0.5))
          : Vector2(-1, (_rng.nextDouble() - 0.5));
      ball.kick(dir, 160);
      onHapticEvent?.call('tackle_success');
    } else {
      onHapticEvent?.call('tackle_fail');
    }
  }

  /// Tombol GANTI PEMAIN: pindah kontrol manual ke pemain lain
  void actionSwitchPlayer() {
    autoSwitchToNearestBall();
  }
}
