import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_side.dart';

/// A compact summary of a [Match].
///
/// [onTap] is optional so the card can be display-only in history.
class MatchCard extends StatelessWidget {
  const new({
    required this.match,
    super.key,
    this.onTap,
  });

  /// The match to display.
  final Match match;

  /// Called when the card or the continue action is tapped.
  final VoidCallback? onTap;

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  bool get isPlaying => match.status == MatchStatus.playing;

  bool get isFinished => match.status == MatchStatus.finished;

  String get _label =>
      '${match.config.gameType.displayName} · '
      '${match.config.matchMode.displayName}';

  String get _date {
    final activity = match.endedAt ?? match.startedAt;
    if (activity == null) return 'Not started';

    final today = DateUtils.dateOnly(clock.now());
    final day = DateUtils.dateOnly(activity);
    final daysAgo = today.difference(day).inDays;

    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    if (daysAgo > 1 && daysAgo < 7) return '$daysAgo days ago';

    return '${day.day} ${_monthNames[day.month - 1]} ${day.year}';
  }

  String _sideName(MatchSide side) =>
      side.players.map((player) => player.name).join(' & ');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MatchCardHeader(label: _label, date: _date),
              const SizedBox(height: 8),
              for (var i = 0; i < match.sides.length; i++) ...[
                _PlayerRow(
                  name: _sideName(match.sides[i]),
                  score: match.scores[i],
                  isWinner: isFinished && match.winnerIndex == i,
                  isPlaying: isPlaying,
                ),
              ],
              if (isPlaying) ...[
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: onTap,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Continue'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchCardHeader extends StatelessWidget {
  const new({
    required this.label,
    required this.date,
  });

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          date,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const new({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.isPlaying,
  });

  final String name;
  final int score;
  final bool isWinner;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final weight = isWinner ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isWinner
                ? Icon(
                    Icons.emoji_events,
                    color: context.colors.tertiary,
                    semanticLabel: 'Winner',
                  )
                : isPlaying
                ? Icon(
                    Icons.circle,
                    size: 10,
                    color: context.colors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: weight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            textAlign: TextAlign.end,
            maxLines: 1,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: weight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
