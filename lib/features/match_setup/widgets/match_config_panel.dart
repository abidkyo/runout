import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/constants/match_limits.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';

/// Bottom bar of the setup page: game type, break format, race-to, innings.
///
/// Above [LayoutBreakpoints.wide] the selectors sit in a two-column row
/// (selectors left, steppers right). Below it everything stacks vertically.
class MatchConfigPanel extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return (constraints.maxWidth < LayoutBreakpoints.wide)
              ? const _NarrowLayout()
              : const _WideLayout();
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              key: const ValueKey('break-format-visibility'),
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
              key: const ValueKey('innings-visibility'),
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
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GameTypeSelector(
          value: notifier.gameType,
          onChanged: (v) => notifier.gameType = v,
        ),
        Visibility(
          key: const ValueKey('break-format-visibility'),
          visible: notifier.gameType != .straightPool,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _BreakFormatSelector(
              value: notifier.breakFormat,
              onChanged: (v) => notifier.breakFormat = v,
            ),
          ),
        ),
        const SizedBox(height: 16),
        NumberStepper(
          value: notifier.raceTo,
          min: MatchLimits.minRaceTo,
          max: MatchLimits.maxRaceTo,
          leadingLabel: 'Race to',
          onChanged: (v) => notifier.raceTo = v,
        ),
        Visibility(
          key: const ValueKey('innings-visibility'),
          visible: notifier.gameType == GameType.straightPool,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: NumberStepper(
              value: notifier.innings,
              min: MatchLimits.minInnings,
              max: MatchLimits.maxInnings,
              trailingLabel: 'innings',
              onChanged: (v) => notifier.innings = v,
            ),
          ),
        ),
      ],
    );
  }
}

class _GameTypeSelector extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final GameType value;
  final ValueChanged<GameType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 360,
      child: SegmentedButton<GameType>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        segments: [
          for (final type in GameType.values)
            ButtonSegment(value: type, label: Text(type.shortName)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _BreakFormatSelector extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final BreakFormat value;
  final ValueChanged<BreakFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 360,
      child: SegmentedButton<BreakFormat>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
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
      ),
    );
  }
}
