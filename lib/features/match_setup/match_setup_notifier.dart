import 'package:flutter/foundation.dart';
import 'package:runout/core/constants/match_limits.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';
import 'package:uuid/uuid.dart';

/// Holds the in-progress configuration for a match setup.
class MatchSetupNotifier extends ChangeNotifier {
  new({required MatchMode mode})
    : _mode = mode,
      _players = List.generate(
        mode.sideCount,
        (_) => List<Player?>.filled(mode.playersPerSide, null),
      );

  final MatchMode _mode;

  GameType _gameType = GameType.eightBall;
  BreakFormat _breakFormat = BreakFormat.winnerBreak;
  int _raceTo = 5;
  final List<List<Player?>> _players;

  MatchMode get mode => _mode;
  GameType get gameType => _gameType;
  BreakFormat get breakFormat => _breakFormat;
  int get raceTo => _raceTo;

  /// Players per side. Outer list = sides, inner list = slots.
  List<List<Player?>> get players => _players;

  set gameType(GameType value) {
    if (_gameType == value) return;
    _gameType = value;
    notifyListeners();
  }

  set breakFormat(BreakFormat value) {
    if (_breakFormat == value) return;
    _breakFormat = value;
    notifyListeners();
  }

  set raceTo(int value) {
    final clamped = value.clamp(MatchLimits.minRaceTo, MatchLimits.maxRaceTo);
    if (_raceTo == clamped) return;
    _raceTo = clamped;
    notifyListeners();
  }

  /// Assigns [player] to the given side and slot.
  void setPlayer(int sideIndex, int slotIndex, Player player) {
    if (sideIndex < 0 || sideIndex >= _players.length) return;
    if (slotIndex < 0 || slotIndex >= _players[sideIndex].length) return;

    _players[sideIndex][slotIndex] = player;
    notifyListeners();
  }

  /// Clears the player in the given side and slot.
  void clearPlayer(int sideIndex, int slotIndex) {
    if (sideIndex < 0 || sideIndex >= _players.length) return;
    if (slotIndex < 0 || slotIndex >= _players[sideIndex].length) return;

    _players[sideIndex][slotIndex] = null;
    notifyListeners();
  }

  /// Whether every slot has a player assigned.
  bool get allPlayersPicked =>
      _players.every((side) => side.every((p) => p != null));

  /// Builds a [Match] from the current setup.
  ///
  /// Only valid when [allPlayersPicked] is true.
  Match buildMatch() {
    if (!allPlayersPicked) {
      throw StateError('Cannot build a match with empty slots.');
    }

    final config = MatchConfig(
      matchMode: _mode,
      gameType: _gameType,
      raceTo: _raceTo,
      breakFormat: _breakFormat,
    );

    final sides = _players
        .map((side) => MatchSide(players: side.whereType<Player>().toList()))
        .toList();

    return Match(
      id: const Uuid().v7(),
      config: config,
      sides: sides,
      scores: List<int>.filled(sides.length, 0),
      status: MatchStatus.created,
    );
  }
}
