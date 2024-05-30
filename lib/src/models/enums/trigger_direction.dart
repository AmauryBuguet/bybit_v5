/// Enumeration of supported trigger directions for queries to the Bybit API.
enum TriggerDirection {
  riseToTriggerPrice(1),
  fallsToTriggerPrice(2);

  final int json;

  const TriggerDirection(this.json);

  /// Allows to get a [TriggerDirection] object from API responses
  factory TriggerDirection.fromInt(int number) {
    return TriggerDirection.values.singleWhere((e) => e.json == number);
  }
}
