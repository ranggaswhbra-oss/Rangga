import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Ukuran dunia game mengikuti permintaan: 1920 x 1080 px
class FieldSpec {
  static const double width = 1920;
  static const double height = 1080;

  // Area bermain (dengan margin untuk out-of-bounds visual)
  static const double margin = 60;
  static double get pitchLeft => margin;
  static double get pitchRight => width - margin;
  static double get pitchTop => margin;
  static double get pitchBottom => height - margin;

  static const double goalWidth = 140; // lebar mulut gawang
  static double get goalTop => (height / 2) - (goalWidth / 2);
  static double get goalBottom => (height / 2) + (goalWidth / 2);

  static const double goalDepth = 28;

  static Rect get homeGoalRect =>
      Rect.fromLTRB(pitchLeft - goalDepth, goalTop, pitchLeft, goalBottom);
  static Rect get awayGoalRect =>
      Rect.fromLTRB(pitchRight, goalTop, pitchRight + goalDepth, goalBottom);

  static Rect get pitchRect =>
      Rect.fromLTRB(pitchLeft, pitchTop, pitchRight, pitchBottom);
}

class FieldComponent extends PositionComponent {
  FieldComponent() : super(size: Vector2(FieldSpec.width, FieldSpec.height));

  final Paint _grassDark = Paint()..color = const Color(0xFF1E8C3F);
  final Paint _grassLight = Paint()..color = const Color(0xFF23A047);
  final Paint _lines = Paint()
    ..color = Colors.white.withOpacity(0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final Paint _goalPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;
  final Paint _netPaint = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    // Background stripes ala rumput dipotong mesin
    const stripeCount = 12;
    final stripeW = FieldSpec.width / stripeCount;
    for (int i = 0; i < stripeCount; i++) {
      final paint = i.isEven ? _grassDark : _grassLight;
      canvas.drawRect(
        Rect.fromLTWH(i * stripeW, 0, stripeW, FieldSpec.height),
        paint,
      );
    }

    final pitch = FieldSpec.pitchRect;

    // Garis luar lapangan
    canvas.drawRect(pitch, _lines);

    // Garis tengah
    canvas.drawLine(
      Offset(FieldSpec.width / 2, pitch.top),
      Offset(FieldSpec.width / 2, pitch.bottom),
      _lines,
    );

    // Lingkaran tengah
    canvas.drawCircle(
      Offset(FieldSpec.width / 2, FieldSpec.height / 2),
      90,
      _lines,
    );
    canvas.drawCircle(
      Offset(FieldSpec.width / 2, FieldSpec.height / 2),
      3,
      Paint()..color = Colors.white,
    );

    // Kotak penalti kiri & kanan
    final penaltyW = 160.0;
    final penaltyH = 400.0;
    canvas.drawRect(
      Rect.fromLTWH(pitch.left, FieldSpec.height / 2 - penaltyH / 2, penaltyW, penaltyH),
      _lines,
    );
    canvas.drawRect(
      Rect.fromLTWH(pitch.right - penaltyW, FieldSpec.height / 2 - penaltyH / 2, penaltyW,
          penaltyH),
      _lines,
    );

    // Kotak gawang kecil (6 yard box)
    final smallW = 60.0;
    final smallH = 200.0;
    canvas.drawRect(
      Rect.fromLTWH(pitch.left, FieldSpec.height / 2 - smallH / 2, smallW, smallH),
      _lines,
    );
    canvas.drawRect(
      Rect.fromLTWH(pitch.right - smallW, FieldSpec.height / 2 - smallH / 2, smallW, smallH),
      _lines,
    );

    // Titik penalti
    canvas.drawCircle(Offset(pitch.left + 130, FieldSpec.height / 2), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(pitch.right - 130, FieldSpec.height / 2), 3, Paint()..color = Colors.white);

    // Gawang (home = kiri, away = kanan)
    _drawGoal(canvas, FieldSpec.homeGoalRect);
    _drawGoal(canvas, FieldSpec.awayGoalRect);
  }

  void _drawGoal(Canvas canvas, Rect goalRect) {
    canvas.drawRect(goalRect, _goalPaint);
    // Jaring sederhana
    const netLines = 6;
    for (int i = 1; i < netLines; i++) {
      final dx = goalRect.left + (goalRect.width / netLines) * i;
      canvas.drawLine(Offset(dx, goalRect.top), Offset(dx, goalRect.bottom), _netPaint);
    }
    for (int i = 1; i < 4; i++) {
      final dy = goalRect.top + (goalRect.height / 4) * i;
      canvas.drawLine(Offset(goalRect.left, dy), Offset(goalRect.right, dy), _netPaint);
    }
  }
}
