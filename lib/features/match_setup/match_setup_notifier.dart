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
  int _innings = 25;
  final List<List<Player?>> _players;

  MatchMode get mode => _mode;
  GameType get gameType => _gameType;
  BreakFormat get breakFormat => _breakFormat;
  int get raceTo => _raceTo;
  int get innings => _innings;

  /// Players per side. Outer list = sides, inner list = slots.
  List<List<Player?>> get players => _players;

  set gameType(GameType value) {
    if (_gameType == value) return;
    if (value == GameType.straightPool) {
      _raceTo = 75;
      _breakFormat = BreakFormat.alternateBreak;
    } else if (_gameType == GameType.straightPool) {
      _raceTo = 5;
    }
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

  set innings(int value) {
    final clamped = value.clamp(MatchLimits.minInnings, MatchLimits.maxInnings);
    if (_innings == clamped) return;
    _innings = clamped;
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

  /// Returns null if the player selection is valid, or an error message.
  String? validatePlayers() {
    final all = _players.expand((s) => s).toList();
    final picked = all.whereType<Player>().toList();

    if (picked.length < all.length) {
      return 'Players incomplete, please fill all player slots.';
    }

    final ids = picked.map((p) => p.id).toSet();
    if (ids.length != picked.length) {
      return 'Duplicate players detected, please pick different players.';
    }

    return null;
  }

  /// Builds a [Match] from the current setup.
  ///
  /// Throws a [StateError] if [validatePlayers] returns a non-null error,
  /// which happens when some slots are empty or duplicate players are used.
  Match buildMatch() {
    final error = validatePlayers();
    if (error != null) {
      throw StateError(error);
    }

    final config = MatchConfig(
      matchMode: _mode,
      gameType: _gameType,
      raceTo: _raceTo,
      breakFormat: _breakFormat,
      inningsLimit: _gameType == GameType.straightPool ? _innings : null,
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
