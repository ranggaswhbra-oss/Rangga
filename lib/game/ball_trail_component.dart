import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ball_component.dart';

/// Menggambar jejak memudar di belakang bola saat bergerak kencang
/// (efek "motion trail" ala game olahraga modern).
class BallTrailComponent extends PositionComponent {
  final BallComponent ball;
  final List<Vector2> _points = [];
  static const int _maxPoints = 10;

  BallTrailComponent(this.ball) : super(priority: -1);

  @override
  void update(double dt) {
    // Hanya catat jejak kalau bola sedang melaju cukup kencang
    if (ball.velocity.length > 120) {
      _points.insert(0, ball.position.clone());
      if (_points.length > _maxPoints) _points.removeLast();
    } else {
      if (_points.isNotEmpty) _points.removeLast();
    }
  }

  @override
  void render(Canvas canvas) {
    for (int i = 0; i < _points.length; i++) {
      final p = _points[i];
      final t = 1 - (i / _maxPoints);
      final radius = BallComponent.radius * 0.85 * t;
      canvas.drawCircle(
        Offset(p.x, p.y),
        radius,
        Paint()..color = Colors.white.withOpacity(0.28 * t),
      );
    }
  }
}
