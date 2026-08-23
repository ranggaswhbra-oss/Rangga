import 'package:flame/components.dart';
import 'ball_component.dart';
import 'field_component.dart';
import 'match_state.dart';
import 'player_component.dart';

/// AI sederhana: pemain yang paling dekat dengan bola dari tiap tim akan
/// mengejar bola, sedangkan pemain lain menjaga posisi formasi relatif
/// terhadap posisi bola (mengikuti sedikit demi sedikit).
class AiLogic {
  void update({
    required double dt,
    required List<PlayerComponent> allPlayers,
    required BallComponent ball,
    required PlayerComponent? userControlledPlayer,
  }) {
    final homePlayers = allPlayers.where((p) => p.team == TeamSide.home && !p.isSentOff).toList();
    final awayPlayers = allPlayers.where((p) => p.team == TeamSide.away && !p.isSentOff).toList();

    _updateTeam(dt, homePlayers, ball, userControlledPlayer);
    _updateTeam(dt, awayPlayers, ball, userControlledPlayer);
  }

  void _updateTeam(
    double dt,
    List<PlayerComponent> teamPlayers,
    BallComponent ball,
    PlayerComponent? userControlledPlayer,
  ) {
    if (teamPlayers.isEmpty) return;

    // Cari pemain terdekat dengan bola di tim ini untuk jadi "pengejar aktif"
    PlayerComponent? chaser;
    double bestDist = double.infinity;
    for (final p in teamPlayers) {
      if (p.isUserControlled) continue; // user handle sendiri
      final d = p.position.distanceTo(ball.position);
      if (d < bestDist) {
        bestDist = d;
        chaser = p;
      }
    }

    for (final p in teamPlayers) {
      if (p.isUserControlled) continue;
      if (p.role == PlayerRole.gk) {
        _updateGoalkeeper(p, ball);
        continue;
      }

      if (p == chaser && bestDist < 380) {
        // Kejar bola langsung
        final dir = (ball.position - p.position);
        if (dir.length > 4) {
          p.velocity = dir.normalized() * p.currentSpeed;
        } else {
          p.velocity = Vector2.zero();
        }
      } else {
        // Jaga posisi formasi, bergeser sedikit mengikuti bola (grafitasi ringan)
        final pull = (ball.position - p.homePosition) * 0.18;
        final target = p.homePosition + pull;
        final dir = (target - p.position);
        if (dir.length > 6) {
          p.velocity = dir.normalized() * (p.baseSpeed * 0.65);
        } else {
          p.velocity = Vector2.zero();
        }
      }

      p.clampToField(FieldSpec.pitchRect);
    }
  }

  void _updateGoalkeeper(PlayerComponent gk, BallComponent ball) {
    // Kiper bergerak vertikal mengikuti bola, tetap dekat gawang
    final targetY = ball.position.y.clamp(
      FieldSpec.goalTop + 20,
      FieldSpec.goalBottom - 20,
    );
    final target = Vector2(gk.homePosition.x, targetY);
    final dir = target - gk.position;
    if (dir.length > 4) {
      gk.velocity = dir.normalized() * gk.baseSpeed;
    } else {
      gk.velocity = Vector2.zero();
    }
    gk.clampToField(FieldSpec.pitchRect);
  }
}
