import 'package:material_ui/material_ui.dart';

enum AppDestinations {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  players(
    label: 'Players',
    icon: Icons.people_outlined,
    selectedIcon: Icons.people,
  ),
  matches(
    label: 'Matches',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
  ;

  new({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
