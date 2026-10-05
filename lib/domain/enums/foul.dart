/// A foul committed during a straight-pool visit.
enum Foul {
  none,
  standard,
  breakFoul,
  ;

  String get displayName => switch (this) {
    .none => 'No Foul',
    .standard => 'Foul',
    .breakFoul => 'Break Foul',
  };

  int get value => switch (this) {
    .none => 0,
    .standard => 1,
    .breakFoul => 2,
  };
}
