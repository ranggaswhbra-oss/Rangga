import 'package:flutter/material.dart';
import '../game/match_state.dart';

class ResultOverlay extends StatelessWidget {
  final MatchState matchState;
  final VoidCallback onExit;
  final VoidCallback onRematch;

  const ResultOverlay({
    super.key,
    required this.matchState,
    required this.onExit,
    required this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    final home = matchState.homeScore;
    final away = matchState.awayScore;
    final String resultText =
        home > away ? 'TIM ANDA MENANG!' : (home < away ? 'TIM ANDA KALAH' : 'SERI');

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10331F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resultText,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                '$home  -  $away',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip('Pelanggaran Tim Anda', '${matchState.foulsHome}'),
                  _statChip('Pelanggaran Lawan', '${matchState.foulsAway}'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExit,
                      child: const Text('Menu Utama'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRematch,
                      child: const Text('Main Lagi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
