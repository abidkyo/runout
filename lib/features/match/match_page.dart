import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/break_button.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/match_timer.dart';
import 'package:runout/features/match/widgets/score_button.dart';
import 'package:runout/features/match/widgets/side_columns.dart';

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

  void _restart(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _exit(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<MatchNotifier>().match.config;
    final showCountry = config.matchMode != MatchMode.doubles;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${config.gameType.displayName} — Race to ${config.raceTo}',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: const [MatchTimer()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _ScoreArea(showCountry: showCountry)),
            ControlsBar(
              onRestart: () => _restart(context),
              onExit: () => _exit(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreArea extends StatelessWidget {
  const new({required this.showCountry});

  final bool showCountry;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;
    final isCreated = match.status == MatchStatus.created;
    final isPlaying = match.status == MatchStatus.playing;
    final isFinished = match.status == MatchStatus.finished;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (var i = 0; i < match.sides.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SideColumn(
                  side: match.sides[i],
                  showCountry: showCountry,
                  isWinner: isFinished && match.winnerIndex == i,
                  isDimmed: isFinished && match.winnerIndex != i,
                  isBreaker: isPlaying && match.currentBreakerIndex == i,
                  child: isCreated
                      ? BreakButton(
                          onTap: () => notifier.selectBreaker(i),
                        )
                      : ScoreButton(
                          score: match.scores[i],
                          onTap: () => notifier.incrementScore(i),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
