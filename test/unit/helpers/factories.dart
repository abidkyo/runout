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
  int raceTo = 10,
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
}) {
  final sides = List.generate(sideCount, (i) => makeSide('$i'));
  return Match.create(
    id: 'match-1',
    config: config ?? makeConfig(),
    sides: sides,
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
