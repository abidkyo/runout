import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/number_stepper.dart';

/// Bottom bar of the setup page: game type, break format, race-to, start.
class SettingsBar extends StatelessWidget {
  const new({required this.onStart, required this.onCancel, super.key});

  /// Called when the user taps Start/Cancel.
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _GameTypeSelector(
                value: notifier.gameType,
                onChanged: (v) => notifier.gameType = v,
              ),
              const SizedBox(width: 24),
              _BreakFormatSelector(
                value: notifier.breakFormat,
                onChanged: (v) => notifier.breakFormat = v,
              ),
              const SizedBox(width: 24),
              _RaceToLabel(),
              const SizedBox(width: 8),
              NumberStepper(
                value: notifier.raceTo,
                onChanged: (v) => notifier.raceTo = v,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Match'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameTypeSelector extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final GameType value;
  final ValueChanged<GameType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<GameType>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: GameType.eightBall, label: Text('8-Ball')),
        ButtonSegment(value: GameType.nineBall, label: Text('9-Ball')),
        ButtonSegment(value: GameType.tenBall, label: Text('10-Ball')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _BreakFormatSelector extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final BreakFormat value;
  final ValueChanged<BreakFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BreakFormat>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: BreakFormat.winnerBreak,
          label: Text('Winner Break'),
        ),
        ButtonSegment(
          value: BreakFormat.alternateBreak,
          label: Text('Alternate Break'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _RaceToLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Race to',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
