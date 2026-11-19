import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side.
class PlayerNameDisplay extends StatelessWidget {
  const new({required this.side, this.isWinner = false, super.key});

  final MatchSide side;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.shortestSide / 20).clamp(24.0, 54.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (isWinner)
          Icon(
            Icons.emoji_events_rounded,
            color: context.colors.tertiary,
            size: fontSize * 0.8,
          ),
        Flexible(
          child: Column(
            children: [
              for (final player in side.players)
                Text(
                  player.name,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: context.colors.playerName,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
