import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Plays a one-shot confetti celebration when a winner is decided.
///
/// The burst starts only on a transition from not decided to decided, so
/// opening an already-finished match does not replay it. It is skipped
/// when the platform requests reduced motion.
class WinnerCelebration extends StatefulWidget {
  const new({
    required this.isWinnerDecided,
    required this.child,
    super.key,
  });

  /// Whether a winner has been decided for the current match.
  final bool isWinnerDecided;

  /// The match UI the celebration is drawn over.
  final Widget child;

  @override
  State<WinnerCelebration> createState() => _WinnerCelebrationState();
}

class _WinnerCelebrationState extends State<WinnerCelebration> {
  @override
  void didUpdateWidget(covariant WinnerCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isWinnerDecided || oldWidget.isWinnerDecided) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;

      Confetti.launch(
        context,
        options: ConfettiOptions(
          particleCount: 120,
          spread: 120,
          colors: [
            context.colors.primary,
            context.colors.secondary,
            context.colors.tertiary,
            context.colors.primaryContainer,
            context.colors.error,
            Colors.amber,
            Colors.white,
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
