/// Enumeration of supported time-in-force options for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#timeinforce).
enum TimeInForce {
  gtc("GTC"),
  ioc("IOC"),
  fok("FOK"),
  postOnly("PostOnly");

  final String json;

  const TimeInForce(this.json);

  /// Allows to get a [TimeInForce] object from API responses
  factory TimeInForce.fromString(String str) {
    return TimeInForce.values.singleWhere((e) => e.json == str);
  }
}
