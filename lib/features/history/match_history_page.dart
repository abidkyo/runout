import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/shared/widgets/empty_state.dart';
import 'package:runout/shared/widgets/match_grid.dart';

/// Lists finished matches for the Matches tab.
class MatchHistoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    final matches = context.read<MatchRepository>().getFinished();

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutBreakpoints.contentMax,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                'Match History',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (matches.isEmpty)
                const EmptyState(
                  icon: Icons.history,
                  title: 'No finished matches',
                  message: 'Finish a match and it will show up here.',
                )
              else
                MatchGrid(matches: matches),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
