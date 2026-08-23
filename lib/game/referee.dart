import 'dart:math';
import 'package:flame/components.dart';
import 'ball_component.dart';
import 'field_component.dart';
import 'match_state.dart';
import 'player_component.dart';

/// Wasit pertandingan: mendeteksi bola keluar (out), offside sederhana,
/// gol, pelanggaran (foul) saat tekel, dan menerbitkan kartu.
class Referee {
  final MatchState matchState;
  final Random _random = Random();

  /// Dipanggil saat gol tercipta - dipakai game engine untuk memicu efek
  /// kamera sinematik (shake, slow-motion replay).
  final void Function(TeamSide scoringSide, Vector2 goalPosition)? onGoal;

  Referee(this.matchState, {this.onGoal});

  /// Dipanggil tiap frame untuk memeriksa status bola terhadap garis lapangan.
  void checkBall(BallComponent ball) {
    final pitch = FieldSpec.pitchRect;
    final inGoalMouthY = ball.position.y >= FieldSpec.goalTop && ball.position.y <= FieldSpec.goalBottom;

    // GOL di gawang kiri (home kebobolan -> away yang cetak gol)
    if (ball.position.x <= pitch.left && inGoalMouthY) {
      matchState.goal(TeamSide.away);
      onGoal?.call(TeamSide.away, ball.position.clone());
      _resetBall(ball, toCenter: true);
      return;
    }
    // GOL di gawang kanan (away kebobolan -> home yang cetak gol)
    if (ball.position.x >= pitch.right && inGoalMouthY) {
      matchState.goal(TeamSide.home);
      onGoal?.call(TeamSide.home, ball.position.clone());
      _resetBall(ball, toCenter: true);
      return;
    }

    // Out garis samping (throw-in)
    if (ball.position.y <= pitch.top || ball.position.y >= pitch.bottom) {
      final restartTeam =
          matchState.lastTeamTouchedBall == TeamSide.home ? TeamSide.away : TeamSide.home;
      matchState.setRestart(RestartType.throwIn, restartTeam);
      matchState.addCommentary('Bola keluar (throw-in) untuk ${_teamLabel(restartTeam)}');
      _resetBall(ball, toCenter: false, clampInside: true);
      return;
    }

    // Out garis gawang tapi tidak masuk gawang -> corner / goal kick
    if (ball.position.x <= pitch.left && !inGoalMouthY) {
      final concededBy = TeamSide.home;
      final touchedLast = matchState.lastTeamTouchedBall;
      final isCorner = touchedLast == concededBy; // tim yg bertahan menyentuh terakhir -> corner utk away
      final restartTeam = isCorner ? TeamSide.away : TeamSide.home;
      matchState.setRestart(isCorner ? RestartType.corner : RestartType.goalKick, restartTeam);
      matchState.addCommentary(isCorner ? 'Sepak pojok untuk ${_teamLabel(restartTeam)}' : 'Sepak gawang');
      _resetBall(ball, toCenter: false, clampInside: true);
      return;
    }
    if (ball.position.x >= pitch.right && !inGoalMouthY) {
      final concededBy = TeamSide.away;
      final touchedLast = matchState.lastTeamTouchedBall;
      final isCorner = touchedLast == concededBy;
      final restartTeam = isCorner ? TeamSide.home : TeamSide.away;
      matchState.setRestart(isCorner ? RestartType.corner : RestartType.goalKick, restartTeam);
      matchState.addCommentary(isCorner ? 'Sepak pojok untuk ${_teamLabel(restartTeam)}' : 'Sepak gawang');
      _resetBall(ball, toCenter: false, clampInside: true);
      return;
    }
  }

  void _resetBall(BallComponent ball, {required bool toCenter, bool clampInside = false}) {
    ball.velocity = Vector2.zero();
    if (toCenter) {
      ball.position = Vector2(FieldSpec.width / 2, FieldSpec.height / 2);
    } else if (clampInside) {
      final pitch = FieldSpec.pitchRect;
      ball.position.x = ball.position.x.clamp(pitch.left + 4, pitch.right - 4);
      ball.position.y = ball.position.y.clamp(pitch.top + 4, pitch.bottom - 4);
    }
  }

  /// Dipanggil saat pemain menekan tombol LAWAN (tackle) dan cukup dekat
  /// dengan lawan yang membawa bola. Mengembalikan true jika tekel berhasil
  /// merebut bola (tanpa pelanggaran).
  bool attemptTackle({
    required PlayerComponent tackler,
    required PlayerComponent opponent,
    required BallComponent ball,
  }) {
    // Peluang dasar berhasil merebut bola bersih
    final cleanTackleChance = 0.55;
    final foulChance = 0.22; // sisanya = gagal tanpa pelanggaran

    final roll = _random.nextDouble();

    if (roll < cleanTackleChance) {
      // Tekel bersih, bola berpindah ke tackler
      matchState.addCommentary('Tekel bersih oleh #${tackler.number}!');
      return true;
    } else if (roll < cleanTackleChance + foulChance) {
      // Pelanggaran terjadi
      _commitFoul(tackler, opponent);
      return false;
    } else {
      // Gagal tekel, tidak terjadi apa-apa
      return false;
    }
  }

  void _commitFoul(PlayerComponent offender, PlayerComponent victim) {
    matchState.setRestart(RestartType.freeKick, victim.team);
    matchState.addCommentary('PELANGGARAN! #${offender.number} melanggar #${victim.number}');

    // Peluang dapat kartu kuning ketika melanggar
    final cardRoll = _random.nextDouble();
    if (cardRoll < 0.12) {
      matchState.giveCard(offender.number, offender.team, CardType.red);
      offender.isSentOff = true;
    } else if (cardRoll < 0.45) {
      matchState.giveCard(offender.number, offender.team, CardType.yellow);
      if (matchState.isSentOff(offender.number)) {
        offender.isSentOff = true;
      }
    }
  }

  String _teamLabel(TeamSide side) => side == TeamSide.home ? 'Tim Anda' : 'Lawan';
}
