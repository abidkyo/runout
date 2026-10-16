import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/match_timer_notifier.dart';

import '../../helpers/factories.dart';

// ---------------------------------------------------------------------------

void main() {
  late MatchNotifier match;
  late MatchTimerNotifier timer;

  setUp(() {
    match = MatchNotifier(makeMatch());
    timer = MatchTimerNotifier(match);
  });

  tearDown(() {
    timer.dispose();
    match.dispose();
  });

  group('elapsed', () {
    test('returns zero when created', () {
      expect(timer.elapsed, Duration.zero);
    });

    test('uses clock.now() while playing', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(seconds: 5));

        expect(timer.elapsed, const Duration(seconds: 5));
      });
    });

    test('is endedAt minus startedAt when finished', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(minutes: 42));
        match.incrementScore(0, points: match.match.config.raceTo);

        expect(timer.elapsed, const Duration(minutes: 42));
      });
    });
  });

  group('formatted', () {
    test('returns 00:00 when created', () {
      expect(timer.formatted, '00:00');
    });

    test('pads single-digit values', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(seconds: 7));

        expect(timer.formatted, '00:07');
      });
    });

    test('returns MM:SS under an hour', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(minutes: 2, seconds: 3));

        expect(timer.formatted, '02:03');
      });
    });

    test('returns 59:59 at the last second before an hour', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(minutes: 59, seconds: 59));

        expect(timer.formatted, '59:59');
      });
    });

    test('returns HH:MM:SS at exactly one hour', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(hours: 1));

        expect(timer.formatted, '01:00:00');
      });
    });

    test('returns HH:MM:SS above an hour', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(hours: 1, minutes: 2, seconds: 3));

        expect(timer.formatted, '01:02:03');
      });
    });

    test('keeps two-digit hours at ten hours', () {
      fakeAsync((async) {
        match.selectBreaker(0);
        async.elapse(const Duration(hours: 10, minutes: 2, seconds: 3));

        expect(timer.formatted, '10:02:03');
      });
    });
  });

  group('ticker', () {
    test('does not tick when created', () {
      fakeAsync((async) {
        var notifications = 0;

        timer.addListener(() => notifications++);
        async.elapse(const Duration(seconds: 5));

        expect(notifications, 0);
      });
    });

    test('notifies listeners once per second while playing', () {
      fakeAsync((async) {
        var notifications = 0;

        match.selectBreaker(0);
        timer.addListener(() => notifications++);
        async.elapse(const Duration(seconds: 5));

        expect(notifications, 5);
      });
    });

    test('stops ticking when the match finishes', () {
      fakeAsync((async) {
        var notifications = 0;

        match.selectBreaker(0);
        match.incrementScore(0, points: match.match.config.raceTo);

        timer.addListener(() => notifications++);
        async.elapse(const Duration(seconds: 5));

        expect(notifications, 0);
      });
    });
  });
}
