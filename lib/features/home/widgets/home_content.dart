import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/home/widgets/home_hero.dart';
import 'package:runout/shared/widgets/empty_state.dart';
import 'package:runout/shared/widgets/match_grid.dart';

/// The Home tab content.
class HomeContent extends StatelessWidget {
  const new({
    required this.onNewMatch,
    required this.onOpenMatch,
    required this.onSeeAllMatches,
    super.key,
  });

  /// Maximum number of finished matches shown on the home page.
  static const int _maxRecentMatches = 10;

  final VoidCallback onNewMatch;
  final ValueChanged<Match> onOpenMatch;
  final VoidCallback onSeeAllMatches;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    final repository = context.read<MatchRepository>();
    final playing = repository.getPlaying();
    final recent = repository.getFinished(limit: _maxRecentMatches);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutBreakpoints.contentMax,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              HomeHero(onNewMatch: onNewMatch),
              if (playing.isNotEmpty)
                _Section(
                  title: 'Continue Matches',
                  trailing: '${playing.length} playing',
                  child: MatchGrid(matches: playing, onTap: onOpenMatch),
                ),
              _Section(
                title: 'Recent Matches',
                trailing: 'See all',
                onTrailingTap: onSeeAllMatches,
                child: recent.isEmpty
                    ? const EmptyState(
                        title: 'No finished matches yet',
                        message: 'Finish a match and it will show up here.',
                      )
                    : MatchGrid(matches: recent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final Widget child;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final onTrailingTap = this.onTrailingTap;

    return Column(
      spacing: 16,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              TextButton(
                onPressed: onTrailingTap,
                style: TextButton.styleFrom(
                  disabledForegroundColor: context.colors.onSurfaceVariant,
                ),
                child: Text(trailing),
              ),
          ],
        ),
        child,
      ],
    );
  }
}
