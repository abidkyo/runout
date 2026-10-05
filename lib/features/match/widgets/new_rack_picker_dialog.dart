import 'package:flutter/material.dart';
import 'package:runout/features/match/widgets/ball_button.dart';

/// Dialog for picking the rack-end remaining count: 0 or 1.
///
/// Tapping a ball pops the dialog with that value. Dismissing pops null.
class NewRackPickerDialog extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How many balls left?'),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: Row(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          for (final value in const [0, 1])
            Padding(
              padding: const EdgeInsets.all(8),
              child: BallButton(
                value: value,
                onTap: () => Navigator.of(context).pop(value),
              ),
            ),
        ],
      ),
    );
  }
}
