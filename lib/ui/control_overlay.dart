import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

class ControlOverlay extends StatefulWidget {
  final ValueChanged<Vector2> onMove;
  final ValueChanged<bool> onSprintChanged;
  final VoidCallback onPass;
  final VoidCallback onShoot;
  final VoidCallback onTackle;
  final VoidCallback onSwitch;
  final VoidCallback onPauseToggle;
  final bool isPaused;

  const ControlOverlay({
    super.key,
    required this.onMove,
    required this.onSprintChanged,
    required this.onPass,
    required this.onShoot,
    required this.onTackle,
    required this.onSwitch,
    required this.onPauseToggle,
    required this.isPaused,
  });

  @override
  State<ControlOverlay> createState() => _ControlOverlayState();
}

class _ControlOverlayState extends State<ControlOverlay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Joystick(onMove: widget.onMove),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onPauseToggle,
                icon: Icon(
                  widget.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onSwitch,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Icon(Icons.swap_horiz, size: 20),
              ),
            ],
          ),
          const SizedBox(width: 12),
          _ActionButtons(
            onSprintChanged: widget.onSprintChanged,
            onPass: widget.onPass,
            onShoot: widget.onShoot,
            onTackle: widget.onTackle,
          ),
        ],
      ),
    );
  }
}

/// Joystick analog sederhana (drag di area lingkaran)
class _Joystick extends StatefulWidget {
  final ValueChanged<Vector2> onMove;
  const _Joystick({required this.onMove});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset _stickOffset = Offset.zero;
  static const double _baseRadius = 60;
  static const double _stickRadius = 26;

  void _updateFromLocal(Offset local) {
    final center = const Offset(_baseRadius, _baseRadius);
    var delta = local - center;
    final maxDist = _baseRadius - _stickRadius / 2;
    if (delta.distance > maxDist) {
      delta = Offset.fromDirection(delta.direction, maxDist);
    }
    setState(() => _stickOffset = delta);
    final normalized = Vector2(delta.dx / maxDist, delta.dy / maxDist);
    widget.onMove(normalized);
  }

  void _reset() {
    setState(() => _stickOffset = Offset.zero);
    widget.onMove(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => _updateFromLocal(d.localPosition),
      onPanUpdate: (d) => _updateFromLocal(d.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: Container(
        width: _baseRadius * 2,
        height: _baseRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.35),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _stickOffset,
            child: Container(
              width: _stickRadius * 2,
              height: _stickRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol aksi ala eFootball: LARI (hold), OPER, TENDANG, LAWAN
class _ActionButtons extends StatelessWidget {
  final ValueChanged<bool> onSprintChanged;
  final VoidCallback onPass;
  final VoidCallback onShoot;
  final VoidCallback onTackle;

  const _ActionButtons({
    required this.onSprintChanged,
    required this.onPass,
    required this.onShoot,
    required this.onTackle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TENDANG - atas
          Positioned(
            top: 0,
            child: _ActionButton(
              label: 'TENDANG',
              color: const Color(0xFFE53935),
              onTap: onShoot,
            ),
          ),
          // LARI - kiri
          Positioned(
            left: 0,
            top: 65,
            child: _ActionButton(
              label: 'LARI',
              color: const Color(0xFFFFB300),
              onTapDown: () => onSprintChanged(true),
              onTapUp: () => onSprintChanged(false),
            ),
          ),
          // LAWAN - kanan
          Positioned(
            right: 0,
            top: 65,
            child: _ActionButton(
              label: 'LAWAN',
              color: const Color(0xFF8E24AA),
              onTap: onTackle,
            ),
          ),
          // OPER - bawah
          Positioned(
            bottom: 0,
            child: _ActionButton(
              label: 'OPER',
              color: const Color(0xFF1E88E5),
              onTap: onPass,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown != null ? (_) => onTapDown!() : null,
      onTapUp: onTapUp != null ? (_) => onTapUp!() : null,
      onTapCancel: onTapUp,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.9),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
