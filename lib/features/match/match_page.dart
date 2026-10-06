import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/break_button.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/exit_warning_dialog.dart';
import 'package:runout/features/match/widgets/match_timer.dart';
import 'package:runout/features/match/widgets/score_button.dart';
import 'package:runout/features/match/widgets/side_columns.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';

/// The match scoring page.
class MatchPage extends StatelessWidget {
  const new({required this.match, super.key});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchNotifier(match),
      child: const _MatchView(),
    );
  }
}

class _MatchView extends StatelessWidget {
  const new();

  Future<void> _restart(BuildContext context, MatchStatus status) async {
    if (status == MatchStatus.playing) {
      final leave = await ExitWarningDialog.show(context);
      if (!leave || !context.mounted) return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _exit(BuildContext context, MatchStatus status) async {
    if (status == MatchStatus.playing) {
      final leave = await ExitWarningDialog.show(context);
      if (!leave || !context.mounted) return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _appBarTitle(MatchConfig config) {
    final base = '${config.gameType.displayName} — Race to ${config.raceTo}';
    if (config.gameType != GameType.straightPool) return base;
    return '$base / ${config.inningsLimit} innings';
  }

  @override
  Widget build(BuildContext context) {
    final match = context.watch<MatchNotifier>().match;
    final config = match.config;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(config)),
        titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [MatchTimer(match: match)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: _ScoreArea()),
            ControlsBar(
              onRestart: () => _restart(context, match.status),
              onExit: () => _exit(context, match.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreArea extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;

    final isStraightPool = match.config.gameType == GameType.straightPool;

    final isCreated = match.status == MatchStatus.created;
    final isPlaying = match.status == MatchStatus.playing;
    final isFinished = match.status == MatchStatus.finished;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < match.sides.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SideColumn(
                  side: match.sides[i],
                  isWinner: isFinished && match.winnerIndex == i,
                  isDimmed: isFinished && match.winnerIndex != i,
                  isBreaker: isPlaying && match.currentBreakerIndex == i,
                  stats: isStraightPool && !isCreated
                      ? StraightPoolStats(
                          innings: match.innings[i].clamp(
                            0,
                            match.effectiveInningsLimit,
                          ),
                          highRun: match.highRuns[i],
                          score: match.scores[i],
                        )
                      : null,
                  child: isCreated
                      ? BreakButton(
                          onTap: () => notifier.selectBreaker(i),
                        )
                      : ScoreButton(
                          score: match.scores[i],
                          onTap: match.config.gameType == GameType.straightPool
                              ? null
                              : () => notifier.incrementScore(i),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
