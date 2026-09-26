import 'package:flutter/foundation.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';

/// Holds the in-progress configuration for a match setup.
class MatchSetupNotifier extends ChangeNotifier {
  GameType _gameType = GameType.eightBall;
  BreakFormat _breakFormat = BreakFormat.winnerBreak;
  int _raceTo = 5;

  GameType get gameType => _gameType;
  BreakFormat get breakFormat => _breakFormat;
  int get raceTo => _raceTo;

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
    final clamped = value.clamp(1, 999);
    if (_raceTo == clamped) return;
    _raceTo = clamped;
    notifyListeners();
  }
}
