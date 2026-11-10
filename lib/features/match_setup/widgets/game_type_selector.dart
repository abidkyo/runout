import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';

/// Game type choices backed by [MatchSetupNotifier].
class GameTypeSelector extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    final buttons = [
      for (final game in GameType.values)
        ChoiceButton(
          label: game.displayName,
          icon: game.icon,
          selected: notifier.gameType == game,
          onPressed: () => notifier.gameType = game,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < LayoutBreakpoints.compact;

        return isCompact
            ? Column(
                spacing: 16,
                children: buttons,
              )
            : Row(
                spacing: 16,
                children: [
                  for (final button in buttons) Expanded(child: button),
                ],
              );
      },
    );
  }
}

extension on GameType {
  IconData get icon => switch (this) {
    .eightBall => Icons.sports_baseball_rounded,
    .nineBall => Icons.sports_baseball_rounded,
    .tenBall => Icons.sports_baseball_rounded,
    .straightPool => Icons.change_history_rounded,
  };
}
