import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side.
class PlayerNameDisplay extends StatelessWidget {
  const new({required this.side, super.key});

  final MatchSide side;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final nameSize = (size.shortestSide / 25).clamp(18.0, 36.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < side.players.length; i++)
          Text(
            side.players[i].name,
            style: context.textTheme.playerName.copyWith(
              color: context.colors.playerName,
              fontSize: nameSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
