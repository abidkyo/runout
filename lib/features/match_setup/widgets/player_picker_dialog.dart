import 'package:flutter/material.dart';
import 'package:runout/core/constants/app_affiliation.dart';
import 'package:runout/domain/models/player.dart';

/// Dialog for picking a player from a list, with name search and a
/// configurable affiliation filter (club or country).
///
/// Returns the selected [Player], or null if cancelled.
class PlayerPickerDialog extends StatefulWidget {
  const new({
    required this.players,
    super.key,
  });

  /// The pool of players to choose from.
  final List<Player> players;

  @override
  State<PlayerPickerDialog> createState() => _PlayerPickerDialogState();
}

class _PlayerPickerDialogState extends State<PlayerPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _affiliationFilter; // null = all

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// The affiliation value of [player] under the active mode.
  String? _affiliationOf(Player player) => switch (AppAffiliation.mode) {
    .club => player.clubName,
    .country => player.countryCode,
  };

  /// Unique non-null affiliation values, sorted case-insensitively.
  List<String> get _affiliations {
    final set =
        widget.players.map(_affiliationOf).whereType<String>().toSet().toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return set;
  }

  /// Players matching the current search and affiliation filter.
  List<Player> get _filtered {
    final q = _query.toLowerCase().trim();
    return widget.players.where((p) {
      final affiliation = _affiliationOf(p);
      final matchesAffiliation =
          _affiliationFilter == null || affiliation == _affiliationFilter;
      final matchesQuery =
          q.isEmpty ||
          p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          (affiliation?.toLowerCase().contains(q) ?? false);
      return matchesAffiliation && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Player'),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: SizedBox(
        width: 600,
        height: 480,
        child: Column(
          children: [
            _AffiliationDropdown(
              affiliations: _affiliations,
              selectedAffiliation: _affiliationFilter,
              label: switch (AppAffiliation.mode) {
                .club => 'Club',
                .country => 'Country',
              },
              onAffiliationChanged: (v) =>
                  setState(() => _affiliationFilter = v),
            ),
            const SizedBox(height: 12),
            _SearchField(
              controller: _searchController,
              onQueryChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(child: _PlayerList(players: _filtered)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Searchable dropdown for filtering players by affiliation.
class _AffiliationDropdown extends StatelessWidget {
  const new({
    required this.affiliations,
    required this.selectedAffiliation,
    required this.label,
    required this.onAffiliationChanged,
  });

  final List<String> affiliations;
  final String? selectedAffiliation;
  final String label;
  final ValueChanged<String?> onAffiliationChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownMenu<String?>(
      expandedInsets: .zero,
      enableFilter: true,
      requestFocusOnTap: true,
      label: Text(label, style: textTheme.labelMedium),
      initialSelection: selectedAffiliation,
      textStyle: textTheme.labelLarge,
      dropdownMenuEntries: [
        const DropdownMenuEntry<String?>(
          value: null,
          label: 'All',
        ),
        for (final affiliation in affiliations)
          DropdownMenuEntry<String?>(
            value: affiliation,
            label: affiliation,
          ),
      ],
      onSelected: onAffiliationChanged,
    );
  }
}

/// Search field for filtering players by name or affiliation.
class _SearchField extends StatelessWidget {
  const new({
    required this.controller,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      style: theme.textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onChanged: onQueryChanged,
    );
  }
}

/// Scrollable list of players.
class _PlayerList extends StatelessWidget {
  const new({required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No players'));
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) => _PlayerRow(player: players[i]),
    );
  }
}

/// A single selectable player row.
class _PlayerRow extends StatelessWidget {
  const new({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(player.countryCode ?? '', style: textTheme.labelMedium),
      ),
      title: Text(player.fullName, style: textTheme.titleMedium),
      onTap: () => Navigator.of(context).pop(player),
    );
  }
}
