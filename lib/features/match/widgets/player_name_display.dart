import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side, with club shown above the name.
/// Club is only shown for the first player in the side.
class PlayerNameDisplay extends StatelessWidget {
  const new({required this.side, super.key});

  final MatchSide side;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < side.players.length; i++)
          _PlayerLine(
            showClub: i == 0,
            name: side.players[i].fullName,
            club: side.players[i].clubName,
          ),
      ],
    );
  }
}

/// A single player line: optional club above the name.
class _PlayerLine extends StatelessWidget {
  const new({required this.showClub, required this.name, this.club});

  final bool showClub;
  final String name;
  final String? club;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    final nameSize = (size.shortestSide / 25).clamp(18.0, 36.0);
    final clubSize = nameSize * 0.8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showClub)
          Text(
            club ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: clubSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
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
