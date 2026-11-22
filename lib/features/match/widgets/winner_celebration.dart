import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Plays a one-shot confetti celebration when a winner is decided.
///
/// The burst starts only on a transition from not decided to decided, so
/// opening an already-finished match does not replay it. The effect is
/// decorative: it ignores pointers and is excluded from semantics. It is
/// skipped when the platform requests reduced motion.
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
  final ConfettiController _controller = ConfettiController();

  bool _isCelebrating = false;

  @override
  void didUpdateWidget(covariant WinnerCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isWinnerDecided || oldWidget.isWinnerDecided) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;

      setState(() => _isCelebrating = true);
    });
  }

  void _onFinished() {
    if (!mounted) return;

    setState(() => _isCelebrating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isCelebrating)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Confetti(
                  controller: _controller,
                  instant: true,
                  onFinished: _onFinished,
                  options: ConfettiOptions(
                    colors: [
                      context.colors.primary,
                      context.colors.tertiary,
                      context.colors.secondary,
                      context.colors.primaryContainer,
                    ],
                    particleCount: 120,
                    spread: 120,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
