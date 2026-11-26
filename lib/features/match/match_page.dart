import 'dart:async';

import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/match_list_notifier.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/match_persistence.dart';
import 'package:runout/features/match/match_timer_notifier.dart';
import 'package:runout/features/match/sp_scoring.dart';
import 'package:runout/features/match/widgets/match_header.dart';
import 'package:runout/features/match/widgets/navigation_buttons.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/side_card.dart';
import 'package:runout/features/match/widgets/sp_buttons.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';
import 'package:runout/features/match/widgets/undo_redo_buttons.dart';
import 'package:runout/features/match/widgets/winner_celebration.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

/// The match scoring page.
class MatchPage extends StatelessWidget {
  const new({
    required this.match,
    super.key,
  });

  final Match match;

  @override
  Widget build(BuildContext context) {
    final isResuming =
        match.status == MatchStatus.playing && match.pausedAt != null;
    final currentMatch = isResuming ? match.resumeAt(clock.now()) : match;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MatchNotifier>(
          create: (_) => MatchNotifier(currentMatch),
        ),
        Provider<MatchPersistence>(
          lazy: false,
          create: (ctx) => MatchPersistence(
            notifier: ctx.read<MatchNotifier>(),
            repository: ctx.read<MatchRepository>(),
            onChanged: ctx.read<MatchListNotifier>().refresh,
            onError: showAppSnackBar,
            saveInitial: isResuming,
          ),
          dispose: (_, persistence) => unawaited(persistence.dispose()),
        ),
        ChangeNotifierProvider<MatchTimerNotifier>(
          create: (ctx) => MatchTimerNotifier(ctx.read<MatchNotifier>()),
        ),
      ],
      child: _MatchView(showSetupButton: !isResuming),
    );
  }
}

class _MatchView extends StatelessWidget {
  const new({required this.showSetupButton});

  final bool showSetupButton;

  Future<void> _discardMatch(BuildContext context) async {
    final status = context.read<MatchNotifier>().match.status;

    if (status != MatchStatus.created) {
      final leave = await showConfirmDialog(
        context,
        title: 'Discard match?',
        message: 'This match will be discarded and will not be saved.',
        confirmLabel: 'Discard',
        destructive: true,
      );
      if (!leave || !context.mounted) return;
    }

    unawaited(context.read<MatchPersistence>().discard());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _editSetup(BuildContext context) async {
    final status = context.read<MatchNotifier>().match.status;

    if (status == MatchStatus.playing) {
      final leave = await showConfirmDialog(
        context,
        title: 'Back to setup?',
        message:
            'Returning to setup will discard this match. '
            'You can then change the match settings.',
        confirmLabel: 'Discard',
        destructive: true,
      );
      if (!leave || !context.mounted) return;
    }

    unawaited(context.read<MatchPersistence>().discard());
    Navigator.of(context).pop();
  }

  void _exitToHome(BuildContext context) {
    context.read<MatchNotifier>().pause();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;
    final scoring = SPScoring(notifier);

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;
    final isWide = width >= LayoutBreakpoints.wide;
    final padding = isCompact ? 16.0 : 24.0;

    final isStraightPool = match.config.gameType == GameType.straightPool;
    final isPlaying = match.status == MatchStatus.playing;

    ValueChanged<int>? onSideTap;
    if (match.status == MatchStatus.created) {
      onSideTap = notifier.selectStartingSide;
    } else if (isPlaying) {
      onSideTap = isStraightPool
          ? (_) => scoring.openScoringDialog(context)
          : notifier.scoreRack;
    }

    return PopScope(
      canPop: !isPlaying,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _exitToHome(context);
      },
      child: WinnerCelebration(
        isWinnerDecided:
            match.status == MatchStatus.finished && match.winnerIndex != null,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: isCompact ? 8 : 12,
                children: [
                  MatchHeader(config: match.config),
                  Expanded(
                    child: _MatchBody(
                      match: match,
                      isCompact: isCompact,
                      onSideTap: onSideTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _ControlsBar(
            isCompact: isCompact,
            children: [
              UndoRedoButtons(
                canUndo: notifier.canUndo,
                canRedo: notifier.canRedo,
                onUndo: notifier.undo,
                onRedo: notifier.redo,
              ),
              if (isStraightPool && isPlaying && isWide)
                Flexible(
                  child: SPButtons(
                    ballsRemaining: match.ballsRemaining,
                    onEndInning: scoring.endInning,
                    onOpenScoring: () => scoring.openScoringDialog(context),
                    onNewRack: () => scoring.newRack(context, remaining: 1),
                  ),
                ),
              NavigationButtons(
                onDiscard: () => _discardMatch(context),
                onEdit: showSetupButton ? () => _editSetup(context) : null,
                onExit: () => _exitToHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchBody extends StatelessWidget {
  const new({
    required this.match,
    required this.isCompact,
    required this.onSideTap,
  });

  final Match match;
  final bool isCompact;
  final ValueChanged<int>? onSideTap;

  @override
  Widget build(BuildContext context) {
    final isStraightPool = match.config.gameType == GameType.straightPool;
    final isCreated = match.status == MatchStatus.created;
    final isPlaying = match.status == MatchStatus.playing;
    final isFinished = match.status == MatchStatus.finished;
    final onTap = onSideTap;

    final cards = <Widget>[
      for (final (int i, MatchSide side) in match.sides.indexed)
        Expanded(
          child: SideCard(
            onTap: onTap == null ? null : () => onTap(i),
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

class _ControlsBar extends StatelessWidget {
  const new({
    required this.isCompact,
    required this.children,
  });

  final bool isCompact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 65 : 77,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24,
          vertical: isCompact ? 8 : 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
