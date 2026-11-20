import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/match_timer_notifier.dart';
import 'package:runout/features/match/straight_pool_scoring.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/match_header.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/side_card.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

/// The match scoring page.
class MatchPage extends StatelessWidget {
  const new({required this.match, super.key});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MatchNotifier>(
          create: (_) => MatchNotifier(match),
        ),
        ChangeNotifierProvider<MatchTimerNotifier>(
          create: (ctx) => MatchTimerNotifier(ctx.read<MatchNotifier>()),
        ),
      ],
      child: const _MatchView(),
    );
  }
}

class _MatchView extends StatelessWidget {
  const new();

  Future<bool> _confirmLeave(BuildContext context, {required String title}) {
    final status = context.read<MatchNotifier>().match.status;
    if (status != MatchStatus.playing) return Future.value(true);

    return showConfirmDialog(
      context,
      title: title,
      message:
          'The match is still in progress. '
          'Leaving will discard the current match.',
      confirmLabel: 'Leave',
      destructive: true,
    );
  }

  Future<void> _backToSetup(BuildContext context) async {
    final leave = await _confirmLeave(context, title: 'Back to setup?');
    if (!leave || !context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _exitToHome(BuildContext context) async {
    final leave = await _confirmLeave(context, title: 'Exit to home?');
    if (!leave || !context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;
    final padding = isCompact ? 16.0 : 24.0;

    final config = context.read<MatchNotifier>().match.config;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: isCompact ? 8 : 12,
            children: [
              MatchHeader(config: config),
              const Expanded(child: _MatchBody()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ControlsBar(
        onRestart: () => _backToSetup(context),
        onExit: () => _exitToHome(context),
      ),
    );
  }
}

class _MatchBody extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;
    final scoring = SPScoring(notifier);

    final isStraightPool = match.config.gameType == GameType.straightPool;
    final isCreated = match.status == MatchStatus.created;
    final isPlaying = match.status == MatchStatus.playing;
    final isFinished = match.status == MatchStatus.finished;

    VoidCallback? onTapFor(int index) {
      if (isCreated) return () => notifier.selectStartingSide(index);
      if (isStraightPool) {
        if (!isPlaying) return null;
        return () => scoring.openScoringDialog(context);
      }
      if (isFinished) return null;
      return () => notifier.scoreRack(index);
    }

    final cards = <Widget>[
      for (final (int i, MatchSide side) in match.sides.indexed)
        Expanded(
          child: SideCard(
            onTap: onTapFor(i),
            isWinner: isFinished && match.winnerIndex == i,
            isLoser: isFinished && match.winnerIndex != i,
            isBreaker: isPlaying && match.currentSideIndex == i,
            children: [
              PlayerNameDisplay(
                side: side,
                isWinner: isFinished && match.winnerIndex == i,
              ),
              Expanded(
                child: isCreated
                    ? Center(
                        child: Text(
                          'Who breaks?',
                          key: const ValueKey('break-text'),
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          side.score.toString(),
                          style: context.textTheme.score,
                          key: const ValueKey('score-text'),
                        ),
                      ),
              ),
              if (isStraightPool && !isCreated)
                StraightPoolStats(
                  innings: side.innings.clamp(0, match.effectiveInningsLimit),
                  highRun: side.highRun,
                  score: side.score,
                ),
            ],
          ),
        ),
    ];

    return isCompact
        ? Column(spacing: 8, children: cards)
        : Row(spacing: 12, children: cards);
  }
}
