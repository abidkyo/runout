import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/player.dart';

/// Dialog for picking a player from a list, with name search and a club filter.
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
  String? _club; // null = all

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Unique non-null club values, sorted case-insensitively.
  List<String> get _clubs {
    final set =
        widget.players
            .map((p) => p.clubName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return set;
  }

  /// Players matching the current search and club filter.
  List<Player> get _filtered {
    final q = _query.toLowerCase().trim();
    return widget.players.where((p) {
      final matchesClub = _club == null || p.clubName == _club;
      final matchesQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.name.toLowerCase().contains(q);
      return matchesClub && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Player'),
      titleTextStyle: context.textTheme.dialogTitle,
      content: SizedBox(
        width: 600,
        height: 480,
        child: Column(
          children: [
            _ClubDropdown(
              clubs: _clubs,
              selectedClub: _club,
              onClubChanged: (v) => setState(() => _club = v),
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
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Searchable dropdown for filtering players by club.
class _ClubDropdown extends StatelessWidget {
  const new({
    required this.clubs,
    required this.selectedClub,
    required this.onClubChanged,
  });

  final List<String> clubs;
  final String? selectedClub;
  final ValueChanged<String?> onClubChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      expandedInsets: .zero,
      enableFilter: true,
      requestFocusOnTap: true,
      label: Text(
        'Club',
        style: context.textTheme.fieldLabel.copyWith(
          color: context.colors.fieldLabel,
        ),
      ),
      initialSelection: selectedClub,
      textStyle: context.textTheme.fieldValue,
      dropdownMenuEntries: [
        const DropdownMenuEntry<String?>(
          value: null,
          label: 'All',
        ),
        for (final club in clubs)
          DropdownMenuEntry<String?>(
            value: club,
            label: club,
          ),
      ],
      onSelected: onClubChanged,
    );
  }
}

/// Search field for filtering players by name.
class _SearchField extends StatelessWidget {
  const new({
    required this.controller,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('player-search'),
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: context.textTheme.fieldText,
      decoration: const InputDecoration(
        hintText: 'Search',
        prefixIcon: Icon(Icons.search),
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
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(
          player.countryCode ?? '',
          style: context.textTheme.fieldLabel.copyWith(
            color: context.colors.fieldLabel,
          ),
        ),
      ),
      title: Text(player.name, style: context.textTheme.fieldText),
      onTap: () => Navigator.of(context).pop(player),
    );
  }
}
