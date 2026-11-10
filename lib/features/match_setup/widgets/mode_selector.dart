import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';

/// Match mode choices backed by [MatchSetupNotifier].
class ModeSelector extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchSetupNotifier>();

    final buttons = [
      for (final mode in MatchMode.values)
        ChoiceButton(
          label: mode.displayName,
          icon: mode.icon,
          selected: notifier.mode == mode,
          onPressed: () => notifier.mode = mode,
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

extension on MatchMode {
  IconData get icon => switch (this) {
    .singles => Icons.person_rounded,
    .doubles => Icons.people_alt_rounded,
    .threePlayer => Icons.groups_rounded,
  };
}
