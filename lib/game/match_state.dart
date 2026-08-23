import 'package:flutter/foundation.dart';

enum TeamSide { home, away }

enum CardType { yellow, red }

enum RestartType { kickoff, throwIn, corner, goalKick, freeKick, none }

class CardEvent {
  final int playerNumber;
  final TeamSide team;
  final CardType type;
  CardEvent(this.playerNumber, this.team, this.type);
}

/// Menyimpan seluruh status pertandingan: skor, waktu, kartu & pelanggaran.
/// Menggunakan ChangeNotifier supaya HUD otomatis update.
class MatchState extends ChangeNotifier {
  int homeScore = 0;
  int awayScore = 0;

  /// Durasi 1 babak (detik) - arcade, dibuat singkat agar cepat dimainkan
  final int halfDurationSeconds;
  double _elapsedSeconds = 0;
  int half = 1; // 1 atau 2
  bool isPaused = false;
  bool isMatchOver = false;

  TeamSide? lastTeamTouchedBall;
  RestartType pendingRestart = RestartType.kickoff;
  TeamSide restartTeam = TeamSide.home;

  final Map<int, int> _yellowCards = {}; // playerNumber -> jumlah kartu kuning
  final List<CardEvent> cardLog = [];
  final List<String> commentaryLog = [];

  int foulsHome = 0;
  int foulsAway = 0;

  /// Dinaikkan setiap kali gol tercipta - dipakai UI untuk memicu
  /// animasi banner "GOAL!" sinematik (tanpa perlu simpan riwayat gol).
  int goalEventId = 0;
  TeamSide? lastGoalSide;

  MatchState({this.halfDurationSeconds = 180});

  int get timeLeft =>
      (halfDurationSeconds - _elapsedSeconds).clamp(0, halfDurationSeconds).toInt();

  String get timeLabel {
    final m = (timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (timeLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void tick(double dt) {
    if (isPaused || isMatchOver) return;
    _elapsedSeconds += dt;
    if (_elapsedSeconds >= halfDurationSeconds) {
      if (half == 1) {
        half = 2;
        _elapsedSeconds = 0;
        pendingRestart = RestartType.kickoff;
        restartTeam = TeamSide.away;
        addCommentary('Babak pertama selesai. $homeScore - $awayScore');
      } else {
        isMatchOver = true;
        addCommentary('Pertandingan selesai! $homeScore - $awayScore');
      }
      notifyListeners();
    }
  }

  void goal(TeamSide side) {
    if (side == TeamSide.home) {
      homeScore++;
    } else {
      awayScore++;
    }
    pendingRestart = RestartType.kickoff;
    restartTeam = side == TeamSide.home ? TeamSide.away : TeamSide.home;
    addCommentary('GOOL! ${side == TeamSide.home ? "Tim Anda" : "Lawan"} mencetak gol!');
    goalEventId++;
    lastGoalSide = side;
    notifyListeners();
  }

  void giveCard(int playerNumber, TeamSide team, CardType type) {
    if (type == CardType.yellow) {
      final current = (_yellowCards[playerNumber] ?? 0) + 1;
      _yellowCards[playerNumber] = current;
      cardLog.add(CardEvent(playerNumber, team, CardType.yellow));
      addCommentary('Kartu kuning untuk pemain #$playerNumber');
      if (current >= 2) {
        cardLog.add(CardEvent(playerNumber, team, CardType.red));
        addCommentary('Kartu kuning kedua! Pemain #$playerNumber diusir keluar lapangan (kartu merah)');
      }
    } else {
      cardLog.add(CardEvent(playerNumber, team, CardType.red));
      addCommentary('KARTU MERAH langsung untuk pemain #$playerNumber');
    }
    if (team == TeamSide.home) {
      foulsHome++;
    } else {
      foulsAway++;
    }
    notifyListeners();
  }

  bool isSentOff(int playerNumber) {
    for (final e in cardLog) {
      if (e.playerNumber == playerNumber && e.type == CardType.red) return true;
    }
    return false;
  }

  void addCommentary(String text) {
    commentaryLog.insert(0, text);
    if (commentaryLog.length > 6) commentaryLog.removeLast();
    notifyListeners();
  }

  void setRestart(RestartType type, TeamSide team) {
    pendingRestart = type;
    restartTeam = team;
    notifyListeners();
  }
}
