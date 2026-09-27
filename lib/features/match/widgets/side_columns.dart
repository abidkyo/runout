import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/score_button.dart';

/// One side's column on the match page: names on top, score filling below.
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.score,
    required this.showCountry,
    required this.onScoreTap,
    super.key,
  });

  final MatchSide side;
  final int score;
  final bool showCountry;
  final VoidCallback onScoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerNameDisplay(side: side, showCountry: showCountry),
        const SizedBox(height: 8),
        Expanded(
          child: ScoreButton(score: score, onTap: onScoreTap),
        ),
      ],
    );
  }
}
