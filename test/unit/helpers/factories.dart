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

Match makeMatch({MatchConfig? config, int sideCount = 2}) {
  final sides = List.generate(sideCount, (i) => makeSide('$i'));
  return Match(
    id: 'match-1',
    config: config ?? makeConfig(),
    sides: sides,
    scores: List.filled(sideCount, 0),
    innings: List.filled(sideCount, 0),
    status: MatchStatus.created,
  );
}
