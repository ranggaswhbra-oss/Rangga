import 'package:flutter/material.dart';
import '../game/match_state.dart';

class HudOverlay extends StatelessWidget {
  final MatchState matchState;
  const HudOverlay({super.key, required this.matchState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreBoard(matchState: matchState),
          const Spacer(),
          if (matchState.commentaryLog.isNotEmpty)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  matchState.commentaryLog.first,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  final MatchState matchState;
  const _ScoreBoard({required this.matchState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _teamDot(const Color(0xFF2255CC)),
          const SizedBox(width: 6),
          Text('${matchState.homeScore}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('  -  ', style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text('${matchState.awayScore}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          _teamDot(const Color(0xFFCC2222)),
          const SizedBox(width: 14),
          Container(width: 1, height: 20, color: Colors.white24),
          const SizedBox(width: 14),
          Text('Babak ${matchState.half}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 8),
          Text(matchState.timeLabel,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFeatures: [])),
        ],
      ),
    );
  }

  Widget _teamDot(Color c) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
