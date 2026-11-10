import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';

/// Break format choices backed by [MatchSetupNotifier].
class BreakFormatSelector extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    final buttons = [
      for (final format in BreakFormat.values)
        ChoiceButton(
          label: format.displayName,
          selected: notifier.breakFormat == format,
          onPressed: () => notifier.breakFormat = format,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < LayoutBreakpoints.compact;

        return isCompact
            ? Column(
                spacing: 16,
                children: buttons,
              )
            : Row(
                spacing: 16,
                children: [
                  for (final button in buttons) Expanded(child: button),
                ],
              );
      },
    );
  }
}
