import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/icon_label_button.dart';

/// Undo and redo controls for the match page.
class UndoRedoButtons extends StatelessWidget {
  const new({
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    super.key,
  });

  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: canUndo,
          child: IconLabelButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            onPressed: canUndo ? onUndo : null,
          ),
        ),
        Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: canRedo,
          child: IconLabelButton(
            icon: Icons.redo_rounded,
            label: 'Redo',
            onPressed: canRedo ? onRedo : null,
          ),
        ),
      ],
    );
  }
}
