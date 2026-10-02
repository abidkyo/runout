import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/match_limits.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';

/// Bottom bar of the setup page: game type, break format, race-to, start.
class MatchConfigPanel extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GameTypeSelector(
                value: notifier.gameType,
                onChanged: (v) => notifier.gameType = v,
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: notifier.gameType != .straightPool,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _BreakFormatSelector(
                  value: notifier.breakFormat,
                  onChanged: (v) => notifier.breakFormat = v,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NumberStepper(
                value: notifier.raceTo,
                min: MatchLimits.minRaceTo,
                max: MatchLimits.maxRaceTo,
                leadingLabel: 'Race to',
                onChanged: (v) => notifier.raceTo = v,
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: notifier.gameType == GameType.straightPool,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: NumberStepper(
                  value: notifier.innings,
                  min: MatchLimits.minInnings,
                  max: MatchLimits.maxInnings,
                  trailingLabel: 'innings',
                  onChanged: (v) => notifier.innings = v,
                ),
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
      style: SegmentedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      segments: [
        for (final type in GameType.values)
          ButtonSegment(value: type, label: Text(type.shortName)),
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
      style: SegmentedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
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
