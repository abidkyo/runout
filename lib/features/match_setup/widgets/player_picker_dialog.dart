import 'package:flutter/material.dart';
import 'package:runout/domain/models/player.dart';

/// Dialog for picking a player from a list, with search and country filter.
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
  String? _country; // null = all countries

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Unique country codes in the player list, sorted.
  List<String> get _countries {
    final set =
        widget.players
            .map((p) => p.countryCode)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return set;
  }

  /// Players matching the current search and country filter.
  List<Player> get _filtered {
    final q = _query.toLowerCase().trim();
    return widget.players.where((p) {
      final matchesCountry = _country == null || p.countryCode == _country;
      final matchesQuery =
          q.isEmpty ||
          p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q);
      return matchesCountry && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Player'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            _FilterRow(
              controller: _searchController,
              countries: _countries,
              selectedCountry: _country,
              onQueryChanged: (v) => setState(() => _query = v),
              onCountryChanged: (v) => setState(() => _country = v),
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

/// Search field and country dropdown.
class _FilterRow extends StatelessWidget {
  const new({
    required this.controller,
    required this.countries,
    required this.selectedCountry,
    required this.onQueryChanged,
    required this.onCountryChanged,
  });

  final TextEditingController controller;
  final List<String> countries;
  final String? selectedCountry;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String?>(
          value: selectedCountry,
          hint: const Text('Country'),
          items: [
            const DropdownMenuItem<String?>(
              child: Text('All'),
            ),
            for (final c in countries)
              DropdownMenuItem<String?>(
                value: c,
                child: Text(c),
              ),
          ],
          onChanged: onCountryChanged,
        ),
      ],
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
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(
          player.countryCode ?? '',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
      title: Text(player.fullName),
      onTap: () => Navigator.of(context).pop(player),
    );
  }
}
