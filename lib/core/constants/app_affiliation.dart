/// How a player is affiliated for display and filtering.
enum AffiliationMode {
  /// Affiliation is a club name.
  club,

  /// Affiliation is a country code.
  country,
}

/// App-wide configuration for how players are affiliated.
class AppAffiliation {
  // Private constructor to prevent instantiation.
  new _();

  /// The affiliation mode this build uses.
  static const AffiliationMode mode = AffiliationMode.club;
}
