import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

/// One side's column on the match page: names on top, [child] filling below.
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.showCountry,
    required this.child,
    super.key,
  });

  final MatchSide side;
  final bool showCountry;

  /// The widget shown below the names. Usually a score or break button.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerNameDisplay(side: side, showCountry: showCountry),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );
  }
}
