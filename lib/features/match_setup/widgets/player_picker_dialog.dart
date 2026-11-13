import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/shared/widgets/empty_state.dart';

/// Dialog for picking an existing player or creating one from the search.
///
/// Returns the selected [Player], or null if cancelled.
class PlayerPickerDialog extends StatefulWidget {
  const new({
    required this.players,
    required this.onCreatePlayer,
    super.key,
  });

  /// The known players to choose from.
  final List<Player> players;

  /// Creates and returns a player from the query.
  final Future<Player> Function(String name) onCreatePlayer;

  @override
  State<PlayerPickerDialog> createState() => _PlayerPickerDialogState();
}

class _PlayerPickerDialogState extends State<PlayerPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Players matching the query.
  List<Player> get _filtered {
    final query = _query.toLowerCase();
    return widget.players
        .where((player) => player.name.toLowerCase().contains(query))
        .toList();
  }

  /// Whether the query should offer an add row.
  bool get _canCreate {
    if (_query.isEmpty) return false;
    return !widget.players.any(
      (player) => player.name.toLowerCase() == _query.toLowerCase(),
    );
  }

  Future<void> _create() async {
    final name = _query;
    if (name.isEmpty || _isCreating) return;

    setState(() => _isCreating = true);
    try {
      final player = await widget.onCreatePlayer(name);
      if (!mounted) return;
      Navigator.of(context).pop(player);
    } on Object catch (error) {
      debugPrint('Failed to add player: $error');
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _errorMessage = 'Could not add player.';
      });
    }
  }

  Future<void> _submit() async {
    final filtered = _filtered;
    if (filtered.length == 1) {
      Navigator.of(context).pop(filtered.single);
      return;
    }

    if (filtered.isEmpty && _canCreate) {
      await _create();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select or add player'),
      content: SizedBox(
        width: 480,
        height: 480,
        child: Column(
          spacing: 16,
          children: [
            _SearchField(
              controller: _searchController,
              enabled: !_isCreating,
              onQueryChanged: (value) => setState(() {
                _query = value.trim();
                _errorMessage = null;
              }),
              onSubmitted: (_) => unawaited(_submit()),
              onClear: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _errorMessage = null;
                });
              },
            ),
            if (_errorMessage != null) _ErrorRow(message: _errorMessage!),
            Expanded(
              child: _PlayerList(
                players: _filtered,
                query: _query,
                isCreating: _isCreating,
                canCreate: _canCreate,
                onCreate: () => unawaited(_create()),
              ),
            ),
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

/// Search field for filtering or naming a player.
class _SearchField extends StatelessWidget {
  const new({
    required this.controller,
    required this.enabled,
    required this.onQueryChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('player-search'),
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Search or add player',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear),
                onPressed: enabled ? onClear : null,
              ),
      ),
      onChanged: onQueryChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// Inline creation error, announced without leaving the dialog.
class _ErrorRow extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('player-picker-error'),
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Row(
          spacing: 8,
          children: [
            Icon(
              Icons.error_outline,
              color: context.colors.error,
              size: 20,
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of players, with an optional create row.
class _PlayerList extends StatelessWidget {
  const new({
    required this.players,
    required this.query,
    required this.isCreating,
    required this.canCreate,
    required this.onCreate,
  });

  final List<Player> players;
  final String query;
  final bool isCreating;
  final bool canCreate;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty && !canCreate) {
      return const EmptyState(
        icon: Icons.person_outline,
        title: 'No players found',
        message: 'Start typing to add new player.',
      );
    }

    final createOffset = canCreate ? 1 : 0;
    return ListView.builder(
      itemCount: players.length + createOffset,
      itemBuilder: (context, index) {
        if (canCreate && index == 0) {
          return _CreateRow(
            name: query,
            isCreating: isCreating,
            onTap: onCreate,
          );
        }
        return _PlayerRow(player: players[index - createOffset]);
      },
    );
  }
}

/// The row that creates a player from the current query.
class _CreateRow extends StatelessWidget {
  const new({
    required this.name,
    required this.isCreating,
    required this.onTap,
  });

  final String name;
  final bool isCreating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !isCreating,
      leading: Icon(Icons.add, color: context.colors.primary),
      title: Text('Add "$name"'),
      trailing: isCreating
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: isCreating ? null : onTap,
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
      title: Text(player.name),
      onTap: () => Navigator.of(context).pop(player),
    );
  }
}
