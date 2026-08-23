import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'match_state.dart';

enum PlayerRole { gk, df, mf, fw }

class PlayerComponent extends PositionComponent with CollisionCallbacks {
  final int number;
  final TeamSide team;
  final PlayerRole role;
  final Color jerseyColor;

  Vector2 velocity = Vector2.zero();
  double baseSpeed;
  bool isSprinting = false;
  bool isUserControlled = false;
  bool isSentOff = false;

  /// Posisi "rumah" / formasi dasar, dipakai AI untuk kembali ke posisi
  Vector2 homePosition;

  double staminaCooldown = 0;

  PlayerComponent({
    required this.number,
    required this.team,
    required this.role,
    required this.jerseyColor,
    required Vector2 startPosition,
    this.baseSpeed = 130,
  })  : homePosition = startPosition.clone(),
        super(
          position: startPosition,
          size: Vector2.all(34),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: size.x / 2)..collisionType = CollisionType.passive);
  }

  double get currentSpeed => baseSpeed * (isSprinting ? 1.6 : 1.0);

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // Bayangan
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, radius * 0.75), width: radius * 1.6, height: radius * 0.6),
      Paint()..color = Colors.black.withOpacity(0.25),
    );

    // Badan pemain
    final bodyPaint = Paint()..color = isSentOff ? Colors.grey : jerseyColor;
    canvas.drawCircle(center, radius, bodyPaint);

    // Ring kontrol (kalau sedang dikendalikan user)
    if (isUserControlled) {
      canvas.drawCircle(
        center,
        radius + 6,
        Paint()
          ..color = Colors.yellowAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Outline putih
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Nomor punggung
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void update(double dt) {
    if (isSentOff) return;
    position += velocity * dt;
  }

  void clampToField(Rect bounds) {
    position.x = position.x.clamp(bounds.left, bounds.right);
    position.y = position.y.clamp(bounds.top, bounds.bottom);
  }
}
