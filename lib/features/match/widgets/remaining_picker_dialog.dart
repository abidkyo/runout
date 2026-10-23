import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/features/match/widgets/ball_button.dart';

/// Result of [RemainingPickerDialog].
typedef RemainingResult = ({int remaining, bool keepsTurn, Foul foul});

/// Dialog for picking the balls remaining and the foul, if any.
///
/// Shows a triangle of 2..15. Buttons above [remaining] are disabled.
/// Tapping a number selects the range 2..that number. Also selects a
/// foul ([Foul.none] or [Foul.standard], plus [Foul.breakFoul] when
/// [showBreakFoul] is true). Returns the selection on confirm, or null
/// on cancel.
class RemainingPickerDialog extends StatefulWidget {
  const new({
    required this.remaining,
    required this.showBreakFoul,
    super.key,
  });

  final int remaining;
  final bool showBreakFoul;

  @override
  State<RemainingPickerDialog> createState() => _RemainingPickerDialogState();
}

class _RemainingPickerDialogState extends State<RemainingPickerDialog> {
  late int _selected = widget.remaining;
  Foul _foul = Foul.none;
  bool _keepsTurn = false;

  /// Rows of the triangle, top to bottom: 2, 3, 4, 5 balls.
  static const _rows = <List<int>>[
    [2, 3],
    [4, 5, 6],
    [7, 8, 9, 10],
    [11, 12, 13, 14, 15],
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 425;

    final isBreakFoul = _foul == Foul.breakFoul;
    final result = (
      remaining: _selected,
      keepsTurn: isBreakFoul && _keepsTurn,
      foul: _foul,
    );

    return AlertDialog(
      scrollable: true,
      title: const Text('How many balls left?'),
      titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in _rows)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in row)
                  Padding(
                    padding: EdgeInsets.all(isNarrow ? 2 : 4),
                    child: BallButton(
                      width: isNarrow ? 48 : 60,
                      value: value,
                      selected: !isBreakFoul && value <= _selected,
                      onTap: !isBreakFoul && value <= widget.remaining
                          ? () => setState(() => _selected = value)
                          : null,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          _FoulSelector(
            value: _foul,
            showBreakFoul: widget.showBreakFoul,
            onChanged: (foul) => setState(() {
              _foul = foul;
              if (foul != Foul.breakFoul) _keepsTurn = false;
            }),
          ),
          Visibility(
            key: const ValueKey('turn-selector-visibility'),
            visible: isBreakFoul,
            maintainSize: widget.showBreakFoul,
            maintainAnimation: widget.showBreakFoul,
            maintainState: widget.showBreakFoul,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _TurnSelector(
                keepsTurn: _keepsTurn,
                onChanged: (value) => setState(() => _keepsTurn = value),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(result),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Segmented selector for the foul type.
class _FoulSelector extends StatelessWidget {
  const new({
    required this.value,
    required this.showBreakFoul,
    required this.onChanged,
  });

  final Foul value;
  final bool showBreakFoul;
  final ValueChanged<Foul> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: SegmentedButton<Foul>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        segments: [
          ButtonSegment(
            value: Foul.none,
            label: Text(Foul.none.displayName),
          ),
          ButtonSegment(
            value: Foul.standard,
            label: Text(Foul.standard.displayName),
          ),
          if (showBreakFoul)
            ButtonSegment(
              value: Foul.breakFoul,
              label: Text(Foul.breakFoul.displayName),
            ),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

/// Segmented selector for re-break vs continue after a break foul.
class _TurnSelector extends StatelessWidget {
  const new({required this.keepsTurn, required this.onChanged});

  final bool keepsTurn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        segments: const [
          ButtonSegment(value: true, label: Text('Re-break')),
          ButtonSegment(value: false, label: Text('Continue')),
        ],
        selected: {keepsTurn},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
