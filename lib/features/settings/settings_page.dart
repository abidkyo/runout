import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/shared/widgets/choice_button.dart';

/// Lets the user choose the app theme and color.
class SettingsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    final settings = context.watch<SettingsNotifier>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutBreakpoints.contentMax,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              const _PageHeader(),
              Card(
                color: context.colors.surfaceContainerLowest,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 24,
                    children: [
                      _Section(
                        icon: Icons.brightness_6_rounded,
                        title: 'Theme',
                        description:
                            'Choose light, dark, or match your system.',
                        child: _ThemeSelector(
                          selected: settings.themeMode,
                          onSelected: (mode) =>
                              unawaited(settings.setThemeMode(mode)),
                        ),
                      ),
                      _Section(
                        icon: Icons.palette_rounded,
                        title: 'Color',
                        description:
                            'Pick the color scheme used across the app.',
                        child: _ColorSelector(
                          selected: settings.appColor,
                          onSelected: (color) =>
                              unawaited(settings.setAppColor(color)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PageHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          'Settings',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Make Runout look the way you like.',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
            Expanded(
              child: Text(title, style: context.textTheme.titleMedium),
            ),
          ],
        ),
        Text(
          description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        child,
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const new({
    required this.selected,
    required this.onSelected,
  });

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  IconData _themeModeIcon(ThemeMode mode) => switch (mode) {
    .system => Icons.brightness_auto_rounded,
    .light => Icons.light_mode_rounded,
    .dark => Icons.dark_mode_rounded,
  };

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    .system => 'System',
    .light => 'Light',
    .dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final mode in ThemeMode.values)
        ChoiceButton(
          label: _themeModeLabel(mode),
          leading: Icon(_themeModeIcon(mode), size: 18),
          selected: selected == mode,
          onPressed: () => onSelected(mode),
        ),
    ];

    return _AdaptiveButtonGroup(buttons: buttons);
  }
}

class _ColorSelector extends StatelessWidget {
  const new({
    required this.selected,
    required this.onSelected,
  });

  final AppColor selected;
  final ValueChanged<AppColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final color in AppColor.values)
        ChoiceButton(
          label: color.label,
          leading: _ColorSwatch(
            color: color.seed,
            selected: selected == color,
          ),
          selected: selected == color,
          onPressed: () => onSelected(color),
        ),
    ];

    return _AdaptiveButtonGroup(buttons: buttons);
  }
}

class _AdaptiveButtonGroup extends StatelessWidget {
  const new({required this.buttons});

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < LayoutBreakpoints.compact) {
          return Column(spacing: 12, children: buttons);
        }

        return Row(
          spacing: 12,
          children: [
            for (final button in buttons) Expanded(child: button),
          ],
        );
      },
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const new({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? context.colors.onPrimary : context.colors.outline,
            width: selected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
