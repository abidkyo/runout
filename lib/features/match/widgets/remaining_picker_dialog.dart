import 'package:flutter/material.dart';
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
  static const _rowSizes = [2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    var next = 2;
    final rows = <List<int>>[];
    for (final size in _rowSizes) {
      rows.add(List.generate(size, (_) => next++));
    }

    return AlertDialog(
      title: const Text('How many balls left?'),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in row)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: BallButton(
                      value: value,
                      selected: _foul != Foul.breakFoul && value <= _selected,
                      onTap:
                          _foul != Foul.breakFoul && value <= widget.remaining
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
          if (_foul == Foul.breakFoul) ...[
            const SizedBox(height: 8),
            _TurnSelector(
              keepsTurn: _keepsTurn,
              onChanged: (value) => setState(() => _keepsTurn = value),
            ),
          ],
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
          onPressed: () => Navigator.of(context).pop(
            (
              remaining: _selected,
              keepsTurn: _foul == Foul.breakFoul && _keepsTurn,
              foul: _foul,
            ),
          ),
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
    return SegmentedButton<Foul>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(padding: const EdgeInsets.all(12)),
      segments: [
        ButtonSegment(value: Foul.none, label: Text(Foul.none.displayName)),
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
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(padding: const EdgeInsets.all(12)),
      segments: const [
        ButtonSegment(value: true, label: Text('Re-break')),
        ButtonSegment(value: false, label: Text('Continue')),
      ],
      selected: {keepsTurn},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
