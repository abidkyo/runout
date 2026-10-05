import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';

Player makePlayer(String id) => Player(
  id: id,
  firstName: 'First$id',
  lastName: 'Last$id',
  countryCode: 'DE',
);

MatchSide makeSide(String id) => MatchSide(players: [makePlayer(id)]);

MatchConfig makeConfig({
  MatchMode matchMode = MatchMode.singles,
  GameType gameType = GameType.eightBall,
  int raceTo = 8,
  BreakFormat breakFormat = BreakFormat.alternateBreak,
  int? inningsLimit,
}) => MatchConfig(
  matchMode: matchMode,
  gameType: gameType,
  raceTo: raceTo,
  breakFormat: breakFormat,
  inningsLimit: inningsLimit,
);

Match makeMatch({
  MatchConfig? config,
  int sideCount = 2,
  int effectiveInningsLimit = 0,
}) {
  final sides = List.generate(sideCount, (i) => makeSide('$i'));
  return Match(
    id: 'match-1',
    config: config ?? makeConfig(),
    sides: sides,
    scores: List.filled(sideCount, 0),
    innings: List.filled(sideCount, 0),
    highRuns: List.filled(sideCount, 0),
    effectiveInningsLimit: effectiveInningsLimit,
    status: MatchStatus.created,
  );
}

/// A straight-pool [MatchConfig] with the given limits.
MatchConfig makeStraightPoolConfig({
  required int inningsLimit,
  required int raceTo,
}) => makeConfig(
  gameType: GameType.straightPool,
  // breakFormat: BreakFormat.alternateBreak,
  inningsLimit: inningsLimit,
  raceTo: raceTo,
);

/// A straight-pool [Match] in [MatchStatus.created], with the given limits.
Match makeStraightPoolMatch({
  required int inningsLimit,
  required int raceTo,
  int sideCount = 2,
}) => makeMatch(
  config: makeStraightPoolConfig(inningsLimit: inningsLimit, raceTo: raceTo),
  sideCount: sideCount,
  effectiveInningsLimit: inningsLimit,
);
