import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/match_persistence.dart';

import '../../helpers/factories.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  late MatchNotifier notifier;
  late FakeMatchRepository repository;
  late List<String> errors;
  late MatchPersistence persistence;

  void create() {
    notifier = MatchNotifier(makeMatch());
    repository = FakeMatchRepository();
    errors = [];
    persistence = MatchPersistence(
      notifier: notifier,
      repository: repository,
      onError: errors.add,
      retryDelay: Duration.zero,
    );
  }

  setUp(create);

  tearDown(() async {
    await persistence.dispose();
    notifier.dispose();
  });

  test('does not save without changes', () async {
    await persistence.dispose();

    expect(repository.saves, isEmpty);
    expect(repository.deletes, isEmpty);
  });

  test('saves when play starts', () async {
    notifier.selectStartingSide(0);
    await persistence.dispose();

    expect(repository.saves, hasLength(1));
    expect(repository.saves.single.status, MatchStatus.playing);
  });

  test('coalesces rapid changes into the final state', () async {
    notifier
      ..selectStartingSide(0)
      ..scoreRack(0)
      ..scoreRack(0);
    await persistence.dispose();

    expect(repository.saves, hasLength(1));
    expect(repository.saves.single.sides.first.score, 2);
  });

  test('saves a finished match', () async {
    notifier.selectStartingSide(0);
    for (var i = 0; i < 10; i++) {
      notifier.scoreRack(0);
    }
    await persistence.dispose();

    expect(repository.saves.last.status, MatchStatus.finished);
  });

  test('deletes when the start is undone', () async {
    notifier
      ..selectStartingSide(0)
      ..undo();
    await persistence.dispose();

    expect(repository.deletes, ['match-1']);
    expect(repository.saves, isEmpty);
  });

  test('discard deletes instead of saving queued changes', () async {
    notifier.selectStartingSide(0);

    await persistence.discard();

    expect(repository.deletes, ['match-1']);
    expect(repository.saves, isEmpty);
  });

  test('discard blocks later saves', () async {
    notifier.selectStartingSide(0);
    await persistence.discard();

    notifier.scoreRack(0);
    await persistence.dispose();

    expect(repository.saves, isEmpty);
    expect(repository.deletes, ['match-1']);
  });

  test('retries a failed save before giving up', () async {
    repository.failSaves = 2;

    notifier.selectStartingSide(0);
    await persistence.dispose();

    expect(repository.saves, hasLength(1));
    expect(errors, isEmpty);
  });

  test('reports a save failure after all attempts', () async {
    repository.failSaves = 3;

    notifier.selectStartingSide(0);
    await persistence.dispose();

    expect(repository.saves, isEmpty);
    expect(errors, ['Could not save match progress.']);
  });

  test('reports a discard failure', () async {
    repository.failDeletes = 3;

    notifier.selectStartingSide(0);
    await persistence.discard();

    expect(repository.deletes, isEmpty);
    expect(errors, ['Could not discard match.']);
  });
}
