import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/features/match/match_timer_notifier.dart';

/// Displays the elapsed time of the current match.
class MatchTimer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    final formatted = context.select<MatchTimerNotifier, String>(
      (notifier) => notifier.formatted,
    );

    return Row(
      spacing: 6,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: isCompact ? 20 : 22,
        ),
        Text(
          formatted,
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
