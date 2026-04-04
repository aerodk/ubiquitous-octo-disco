import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/models/tournament_settings.dart';
import 'package:star_cano/services/mexicano_algorithm_service.dart';
import 'package:star_cano/services/standings_service.dart';
import 'package:star_cano/services/tournament_service.dart';

String _teamKey(Team team) {
  final names = [team.player1.name, team.player2.name]..sort();
  return names.join('+');
}

String _matchKey(Match match) {
  final teams = [_teamKey(match.team1), _teamKey(match.team2)]..sort();
  return teams.join(' vs ');
}

void main() {
  group('Mexicano regression - pause points vs pairing points', () {
    late TournamentService tournamentService;
    late StandingsService standingsService;
    late MexicanoAlgorithmService mexicanoService;
    late List<Player> players;
    late List<Court> courts;
    late Tournament tournament;

    setUp(() {
      tournamentService = TournamentService();
      standingsService = StandingsService();
      mexicanoService = MexicanoAlgorithmService();

      final a = Player(id: 'a', name: 'a');
      final b = Player(id: 'b', name: 'b');
      final c = Player(id: 'c', name: 'c');
      final d = Player(id: 'd', name: 'd');
      final e = Player(id: 'e', name: 'e');

      players = [a, b, c, d, e];
      courts = [Court(id: '1', name: 'Bane 1')];

      // Recreates a 2-round history that gives the exported standings:
      // e=26, b=26, d=25, c=22, a=21 with pauseCount d=1 and a=1.
      //
      // Round 1: a+c score 9, b+e score 18, d pauses.
      // Round 2: d+c score 13, b+e score 8, a pauses.
      //
      // Displayed standings include 12 pause points:
      // a: 9 + 12 = 21
      // d: 12 + 13 = 25
      // while Mexicano pairing uses only raw match points:
      // a: 9, d: 13.
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: a, player2: c),
            team2: Team(player1: b, player2: e),
            team1Score: 9,
            team2Score: 18,
          ),
        ],
        playersOnBreak: [d],
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: d, player2: c),
            team2: Team(player1: b, player2: e),
            team1Score: 13,
            team2Score: 8,
          ),
        ],
        playersOnBreak: [a],
      );

      tournament = Tournament(
        name: 'Regression case',
        players: players,
        courts: courts,
        rounds: [round1, round2],
        settings: const TournamentSettings(
          format: TournamentFormat.mexicano,
          pausePointsAwarded: 12,
        ),
      );
    });

    test(
        'shows standings points differ from Mexicano pairing points when pause points are enabled',
        () {
      final standings = standingsService.calculateStandings(tournament);
      final standingsByName = {
        for (final standing in standings) standing.player.name: standing,
      };
      final rawStats =
          mexicanoService.calculatePlayerStats(players, tournament.rounds);

      expect(standingsByName['e']!.totalPoints, 26);
      expect(standingsByName['b']!.totalPoints, 26);
      expect(standingsByName['d']!.totalPoints, 25);
      expect(standingsByName['c']!.totalPoints, 22);
      expect(standingsByName['a']!.totalPoints, 21);

      expect(standingsByName['d']!.pauseCount, 1);
      expect(standingsByName['a']!.pauseCount, 1);

      expect(rawStats['e']!.totalPoints, 26);
      expect(rawStats['b']!.totalPoints, 26);
      expect(rawStats['c']!.totalPoints, 22);
      expect(rawStats['d']!.totalPoints, 13);
      expect(rawStats['a']!.totalPoints, 9);
    });

    test(
        'generates the expected Mexicano matchup for this recreated five-player case',
        () {
      final standings = standingsService.calculateStandings(tournament);

      final nextRound = tournamentService.generateNextRound(
        players,
        courts,
        standings,
        3,
        format: TournamentFormat.mexicano,
        previousRounds: tournament.rounds,
      );

      expect(nextRound.playersOnBreak, hasLength(1));
      expect(nextRound.matches, hasLength(1));

      final breakPlayer = nextRound.playersOnBreak.single.name;
      expect(breakPlayer, anyOf('b', 'c', 'e'));

      // Because pause fairness chooses among b/c/e, the exact break player can vary.
      // Once the break player is known, plain Mexicano should produce one of these
      // valid raw-point pairings:
      // - break b -> e+c vs d+a
      // - break c -> e+b vs d+a
      // - break e -> b+c vs d+a
      final expectedMatchByBreakPlayer = <String, String>{
        'b': 'a+d vs c+e',
        'c': 'a+d vs b+e',
        'e': 'a+d vs b+c',
      };

      expect(
        _matchKey(nextRound.matches.single),
        expectedMatchByBreakPlayer[breakPlayer],
      );
    });
  });
}
