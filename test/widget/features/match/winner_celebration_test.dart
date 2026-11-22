import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/winner_celebration.dart';

// ---------------------------------------------------------------------------

class _Host extends StatefulWidget {
  const new({
    required this.initiallyDecided,
    this.disableAnimations = false,
    this.onChildTap,
  });

  final bool initiallyDecided;
  final bool disableAnimations;
  final VoidCallback? onChildTap;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late bool _isDecided = widget.initiallyDecided;

  void _decide() {
    setState(() => _isDecided = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          final media = MediaQuery.of(context).copyWith(
            disableAnimations: widget.disableAnimations,
          );

          return MediaQuery(
            data: media,
            child: WinnerCelebration(
              isWinnerDecided: _isDecided,
              child: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _decide,
                        child: const Text('decide'),
                      ),
                      ElevatedButton(
                        onPressed: widget.onChildTap,
                        child: const Text('tap through'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

void main() {
  testWidgets('does not celebrate a match that is already decided', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host(initiallyDecided: true));
    await tester.pump();

    expect(find.byType(Confetti), findsNothing);
  });

  testWidgets('celebrates when a winner is decided', (tester) async {
    await tester.pumpWidget(const _Host(initiallyDecided: false));

    await tester.tap(find.text('decide'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(Confetti), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(Confetti), findsNothing);
  });

  testWidgets('does not block taps while celebrating', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _Host(
        initiallyDecided: false,
        onChildTap: () => taps++,
      ),
    );

    await tester.tap(find.text('decide'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(Confetti), findsOneWidget);

    await tester.tap(find.text('tap through'));
    expect(taps, 1);

    await tester.pumpAndSettle();
  });

  testWidgets('skips the celebration when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _Host(
        initiallyDecided: false,
        disableAnimations: true,
      ),
    );

    await tester.tap(find.text('decide'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(Confetti), findsNothing);
  });
}
