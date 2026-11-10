import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_destinations.dart';
import 'package:runout/core/constants/app_strings.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Navigation shown beside page content on wide layouts.
class HomeSidebar extends StatelessWidget {
  const new({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            spacing: 32,
            children: [
              const _Header(),
              _Body(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text(
          AppStrings.title,
          style: context.textTheme.appTitle.copyWith(
            color: context.colors.appTitle,
          ),
        ),
        Text(
          AppStrings.subtitle,
          style: context.textTheme.appSubtitle.copyWith(
            color: context.colors.appSubtitle,
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const new({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        for (final d in AppDestinations.values)
          ListTile(
            selected: selectedIndex == d.index,
            selectedTileColor: colors.secondaryContainer,
            selectedColor: colors.onSecondaryContainer,
            textColor: colors.onSurfaceVariant,
            iconColor: colors.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            leading: Icon(
              selectedIndex == d.index ? d.selectedIcon : d.icon,
            ),
            title: Text(
              d.label,
              style: context.textTheme.labelLarge?.copyWith(
                color: selectedIndex == d.index
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
            onTap: () => onDestinationSelected(d.index),
          ),
      ],
    );
  }
}
