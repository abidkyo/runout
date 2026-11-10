import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Start / Cancel action bar at the bottom of the setup page.
class SetupActions extends StatelessWidget {
  const new({required this.onStart, required this.onCancel, super.key});

  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutBreakpoints.contentMax,
            ),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: 12,
              overflowSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    textStyle: context.textTheme.titleMedium,
                  ),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    textStyle: context.textTheme.titleMedium,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Match'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
