import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/features/match/widgets/ball_button.dart';
import 'package:runout/shared/widgets/choice_button.dart';

/// Result of [SPScoringDialog].
typedef SPScoreResult = ({int remaining, bool keepsTurn, Foul foul});

/// Dialog for picking the balls remaining and the foul, if any.
///
/// Shows a triangle of 2..15. Buttons above [remaining] are disabled.
/// Tapping a number selects the range 2..that number. Also selects a
/// foul ([Foul.none] or [Foul.standard], plus [Foul.breakFoul] when
/// [showBreakFoul] is true). Returns the selection on confirm, or null
/// on cancel.
class SPScoringDialog extends StatefulWidget {
  const new({
    required this.sideName,
    required this.remaining,
    required this.showBreakFoul,
    super.key,
  });

  final String sideName;
  final int remaining;
  final bool showBreakFoul;

  @override
  State<SPScoringDialog> createState() => _SPScoringDialogState();
}

class _SPScoringDialogState extends State<SPScoringDialog> {
  late int _selected = widget.remaining;
  Foul _foul = Foul.none;
  bool _keepsTurn = false;

  @override
  Widget build(BuildContext context) {
    final isBreakFoul = _foul == Foul.breakFoul;

    return AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(sideName: widget.sideName),
          const SizedBox(height: 24),
          _BallButtons(
            enabled: !isBreakFoul,
            remaining: widget.remaining,
            selected: _selected,
            onTap: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 16),
          _Info(
            remaining: widget.remaining,
            selected: _selected,
            foul: _foul,
          ),
          const SizedBox(height: 8),
          const PopupMenuDivider(thickness: 2),
          const SizedBox(height: 8),
          _FoulSelector(
            value: _foul,
            showBreakFoul: widget.showBreakFoul,
            onPressed: (foul) => setState(() {
              _foul = foul;
              if (foul != Foul.breakFoul) _keepsTurn = false;
            }),
          ),
          if (isBreakFoul) ...[
            const SizedBox(height: 12),
            _TurnSelector(
              keepsTurn: _keepsTurn,
              onPressed: (value) => setState(() => _keepsTurn = value),
            ),
          ],
          const SizedBox(height: 8),
          const PopupMenuDivider(thickness: 2),
          const SizedBox(height: 8),
          _NewRackButton(
            onPressed: (value) => Navigator.of(context).pop<SPScoreResult>((
              remaining: value,
              keepsTurn: true,
              foul: Foul.none,
            )),
          ),
          const SizedBox(height: 16),
          _NextButton(
            onPressed: () => Navigator.of(context).pop<SPScoreResult>((
              remaining: _selected,
              keepsTurn: isBreakFoul && _keepsTurn,
              foul: _foul,
            )),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new({required this.sideName});

  final String sideName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          'Record Inning',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sideName,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.playerName,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: .ellipsis,
        ),
        const SizedBox(height: 16),
        Text(
          'How many balls left?',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: .ellipsis,
        ),
      ],
    );
  }
}

class _BallButtons extends StatelessWidget {
  const new({
    required this.enabled,
    required this.selected,
    required this.remaining,
    required this.onTap,
  });

  final bool enabled;
  final int selected;
  final int remaining;
  final ValueChanged<int> onTap;

  /// Rows of the triangle, top to bottom: 2, 3, 4, 5 balls.
  static const _rows = <List<int>>[
    [2, 3],
    [4, 5, 6],
    [7, 8, 9, 10],
    [11, 12, 13, 14, 15],
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ballSize = (size.width / 10).clamp(40.0, 52.0);

    return Column(
      spacing: 8,
      children: [
        for (final row in _rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              for (final value in row)
                BallButton(
                  width: ballSize,
                  value: value,
                  selected: enabled && value <= selected,
                  onTap: enabled && value <= remaining
                      ? () => onTap(value)
                      : null,
                ),
            ],
          ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const new({
    required this.remaining,
    required this.selected,
    required this.foul,
  });

  final int remaining;
  final int selected;
  final Foul foul;

  @override
  Widget build(BuildContext context) {
    final points = remaining - selected - foul.value;
    final sign = points > 0 ? '+' : '';

    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$selected balls remaining',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          '$sign$points points',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }
}

/// Segmented selector for the foul type.
class _FoulSelector extends StatelessWidget {
  const new({
    required this.value,
    required this.showBreakFoul,
    required this.onPressed,
  });

  final Foul value;
  final bool showBreakFoul;
  final ValueChanged<Foul> onPressed;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ChoiceButton(
        label: Foul.none.displayName,
        selected: Foul.none == value,
        onPressed: () => onPressed(Foul.none),
        verticalPadding: 16, // 40 px
      ),
      ChoiceButton(
        label: Foul.standard.displayName,
        selected: Foul.standard == value,
        onPressed: () => onPressed(Foul.standard),
        verticalPadding: 16, // 40 px
      ),
      if (showBreakFoul)
        ChoiceButton(
          label: Foul.breakFoul.displayName,
          selected: Foul.breakFoul == value,
          onPressed: () => onPressed(Foul.breakFoul),
          verticalPadding: 16, // 40 px
        ),
    ];
    return SizedBox(
      key: const ValueKey('foul-selector'),
      width: 360,
      child: Row(
        spacing: 8,
        children: [
          for (final button in buttons) Expanded(child: button),
        ],
      ),
    );
  }
}

/// Segmented selector for re-break vs continue after a break foul.
class _TurnSelector extends StatelessWidget {
  const new({required this.keepsTurn, required this.onPressed});

  final bool keepsTurn;
  final ValueChanged<bool> onPressed;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ChoiceButton(
        label: 'Re-break',
        selected: keepsTurn,
        onPressed: () => onPressed(true),
        verticalPadding: 16, // 40 px
      ),
      ChoiceButton(
        label: 'Continue',
        selected: !keepsTurn,
        onPressed: () => onPressed(false),
        verticalPadding: 16, // 40 px
      ),
    ];

    return SizedBox(
      key: const ValueKey('turn selector'),
      width: 240,
      child: Row(
        spacing: 8,
        children: [
          for (final button in buttons) Expanded(child: button),
        ],
      ),
    );
  }
}

class _NewRackButton extends StatelessWidget {
  const new({required this.onPressed});

  final ValueChanged<int> onPressed;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium?.copyWith(
      color: context.colors.onSecondaryContainer,
    );
    final subtitleStyle = context.textTheme.labelMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    final params = [
      ('New Rack', '0 ball remaining', () => onPressed(0)),
      ('New Rack', '1 ball remaining', () => onPressed(1)),
    ];

    return Row(
      spacing: 16,
      children: [
        for (final (String title, String subtitle, VoidCallback callback)
            in params)
          Expanded(
            child: FilledButton.tonal(
              onPressed: callback,
              style: FilledButton.styleFrom(
                padding: padding,
                side: BorderSide(color: context.colors.outline),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: subtitleStyle,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const new({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.titleMedium;
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 20);

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              textStyle: textStyle,
              padding: padding,
            ),
            child: const Text(
              'Next Inning',
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
