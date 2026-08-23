import 'package:flutter/material.dart';
import '../match_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B5D26), Color(0xFF06341A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_soccer, size: 96, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'GAAFTBLL',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Arcade Football 11 vs 11',
                  style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.offline_bolt, size: 16, color: Colors.greenAccent),
                      SizedBox(width: 6),
                      Text(
                        'MODE OFFLINE - Tanpa Internet',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                _MenuButton(
                  label: 'MULAI PERTANDINGAN',
                  icon: Icons.play_arrow_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MatchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: 'CARA BERMAIN',
                  icon: Icons.info_outline,
                  onTap: () => _showHowToPlay(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF10331F),
        title: const Text('Cara Bermain', style: TextStyle(color: Colors.white)),
        content: const Text(
          '• Joystick kiri: gerakkan pemain\n'
          '• LARI: tahan untuk berlari lebih cepat\n'
          '• OPER: umpan ke rekan setim terdekat\n'
          '• TENDANG: tembak ke gawang lawan\n'
          '• LAWAN: coba rebut bola dari lawan (tekel)\n'
          '• Wasit otomatis menilai out, gol, dan pelanggaran (kartu kuning/merah)',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0B5D26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
