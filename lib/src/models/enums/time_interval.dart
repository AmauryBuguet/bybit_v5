/// Enumeration of supported intervals for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#interval).
enum TimeInterval {
  /// 1 minute interval.
  oneMinute("1"),

  /// 3 minutes interval.
  threeMinutes("3"),

  /// 5 minutes interval.
  fiveMinutes("5"),

  /// 15 minutes interval.
  fifteenMinutes("15"),

  /// 30 minutes interval.
  thirtyMinutes("30"),

  /// 1 hour interval.
  oneHour("60"),

  /// 2 hours interval.
  twoHours("120"),

  /// 4 hours interval.
  fourHours("240"),

  /// 6 hours interval.
  sixHours("360"),

  /// 12 hours interval.
  twelveHours("720"),

  /// 1 day interval.
  oneDay("D"),

  /// 1 week interval.
  oneWeek("W"),

  /// 1 month interval.
  oneMonth("M");

  final String json;

  const TimeInterval(this.json);

  /// Allows to get a [TimeInterval] object from API responses
  factory TimeInterval.fromString(String str) {
    return TimeInterval.values.singleWhere((e) => e.json == str);
  }
}
