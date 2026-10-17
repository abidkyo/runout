import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/features/match/match_timer_notifier.dart';

/// Displays the elapsed time of the current match.
class MatchTimer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final formatted = context.select<MatchTimerNotifier, String>(
      (notifier) => notifier.formatted,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        formatted,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
