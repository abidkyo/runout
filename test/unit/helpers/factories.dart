import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';

Player makePlayer(String id) => Player(
  id: id,
  name: 'Player-$id',
  countryCode: 'DE',
);

MatchSide makeSide(
  String id, {
  int score = 0,
  int innings = 0,
  int highRun = 0,
  int consecutiveFouls = 0,
}) => MatchSide(
  players: [makePlayer(id)],
  score: score,
  innings: innings,
  highRun: highRun,
  consecutiveFouls: consecutiveFouls,
);

MatchConfig makeConfig({
  MatchMode matchMode = MatchMode.singles,
  GameType gameType = GameType.eightBall,
  int raceTo = 10,
  BreakFormat breakFormat = BreakFormat.alternateBreak,
  int inningsLimit = 0,
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
  List<MatchSide>? sides,
}) {
  return Match.create(
    id: 'match-1',
    config: config ?? makeConfig(),
    sides: sides ?? List.generate(sideCount, (i) => makeSide(i.toString())),
  );
}

MatchConfig makeStraightPoolConfig({
  int inningsLimit = 1,
  int raceTo = 10,
}) => makeConfig(
  gameType: GameType.straightPool,
  inningsLimit: inningsLimit,
  raceTo: raceTo,
);

Match makeStraightPoolMatch({
  int inningsLimit = 1,
  int raceTo = 10,
  int sideCount = 2,
}) => makeMatch(
  config: makeStraightPoolConfig(inningsLimit: inningsLimit, raceTo: raceTo),
  sideCount: sideCount,
);
