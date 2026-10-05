import 'package:flutter/material.dart';
import 'package:runout/features/match/widgets/ball_button.dart';

/// Dialog for picking the number of balls remaining on the table.
///
/// Shows a triangle of 2..15. Buttons above [remaining] are disabled.
/// Tapping a number selects the range 2..that number. Returns the
/// selected number on confirm, or null on cancel.
class RemainingPickerDialog extends StatefulWidget {
  const new({required this.remaining, super.key});

  final int remaining;

  @override
  State<RemainingPickerDialog> createState() => _RemainingPickerDialogState();
}

class _RemainingPickerDialogState extends State<RemainingPickerDialog> {
  late int _selected = widget.remaining;

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
                      selected: value <= _selected,
                      onTap: value <= widget.remaining
                          ? () => setState(() => _selected = value)
                          : null,
                    ),
                  ),
              ],
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
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
