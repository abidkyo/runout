import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/features/match/match_timer_notifier.dart';
import 'package:runout/features/match/widgets/match_timer.dart';

// ---------------------------------------------------------------------------

class _FakeTimerNotifier extends ChangeNotifier implements MatchTimerNotifier {
  new({required this.formatted});

  @override
  final String formatted;

  @override
  Duration get elapsed => throw UnimplementedError();
}

Future<void> _pump(
  WidgetTester tester, {
  required String formatted,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<MatchTimerNotifier>(
      create: (_) => _FakeTimerNotifier(formatted: formatted),
      child: const MaterialApp(
        home: Scaffold(body: MatchTimer()),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  testWidgets('renders the formatted value', (tester) async {
    await _pump(tester, formatted: '02:03');
    expect(find.text('02:03'), findsOneWidget);
  });

  testWidgets('renders an hours format', (tester) async {
    await _pump(tester, formatted: '01:02:03');
    expect(find.text('01:02:03'), findsOneWidget);
  });

  testWidgets('uses tabular figures', (tester) async {
    await _pump(tester, formatted: '00:00');

    final text = tester.widget<Text>(find.text('00:00'));
    final features = text.style?.fontFeatures;
    expect(features, isNotNull);
    expect(features!.any((f) => f.feature == 'tnum'), isTrue);
  });
}
