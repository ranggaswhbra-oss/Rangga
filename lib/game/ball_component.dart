import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'match_state.dart';

class BallComponent extends PositionComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  static const double friction = 55; // perlambatan per detik
  static const double radius = 12;

  TeamSide? lastTouchedBy;
  int? lastTouchedByNumber;

  BallComponent({required Vector2 startPosition})
      : super(position: startPosition, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: radius)..collisionType = CollisionType.passive);
  }

  void kick(Vector2 direction, double power) {
    if (direction.length == 0) return;
    velocity = direction.normalized() * power;
  }

  @override
  void update(double dt) {
    position += velocity * dt;

    // Gesekan memperlambat bola
    final speed = velocity.length;
    if (speed > 0) {
      final decel = friction * dt;
      final newSpeed = (speed - decel).clamp(0.0, double.infinity);
      velocity = newSpeed == 0 ? Vector2.zero() : velocity.normalized() * newSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, radius * 0.9), width: radius * 1.8, height: radius * 0.7),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Motif pentagon sederhana biar mirip bola
    final dotPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(center, radius * 0.35, dotPaint);
  }
}
