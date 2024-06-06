/// Enumeration of supported intervalTime options for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#intervaltime).
enum IntervalTime {
  fiveMinutes("5min"),
  fifteenMinutes("15min"),
  thirtyMinutes("30min"),
  oneHour("1h"),
  fourHours("4h"),
  oneDay("1d");

  final String json;

  const IntervalTime(this.json);
}
