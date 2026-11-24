import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/shared/widgets/choice_button.dart';
import 'package:runout/shared/widgets/match_card.dart';

final Match _previewMatch = Match(
  id: 'settings-preview',
  config: const MatchConfig(
    matchMode: MatchMode.singles,
    gameType: GameType.eightBall,
    raceTo: 7,
    breakFormat: BreakFormat.alternateBreak,
  ),
  sides: [
    MatchSide(
      players: const [Player(id: 'preview-0', name: 'Efren Reyes')],
      score: 7,
    ),
    MatchSide(
      players: const [Player(id: 'preview-1', name: "Ronnie O'Sullivan")],
      score: 4,
    ),
  ],
  status: MatchStatus.finished,
  endedAt: DateTime(2026),
  winnerIndex: 0,
);

/// Lets the user choose the app theme, color, and text size.
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
                      _Section(
                        icon: Icons.format_size_rounded,
                        title: 'Text Size',
                        description: 'Scale text across the app.',
                        child: _TextSizeControl(
                          value: settings.textScale,
                          onChanged: (value) =>
                              unawaited(settings.setTextScale(value)),
                        ),
                      ),
                      const _Section(
                        icon: Icons.visibility_rounded,
                        title: 'Preview',
                        description: "Here's how it looks now!",
                        child: _MatchCardPreview(),
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

class _TextSizeControl extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          spacing: 8,
          children: [
            Slider(
              value: value,
              min: AppSettings.minTextScale,
              max: AppSettings.maxTextScale,
              divisions: 10,
              semanticFormatterCallback: (value) =>
                  '${(value * 100).round()} percent',
              onChanged: onChanged,
            ),
            Text(
              '$percent%',
              style: context.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCardPreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: MatchCard(match: _previewMatch),
      ),
    );
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
