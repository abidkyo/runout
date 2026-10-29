import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
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
        style: context.textTheme.timer.copyWith(
          color: context.colors.timer,
        ),
      ),
    );
  }
}
