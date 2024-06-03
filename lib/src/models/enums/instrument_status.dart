/// Enumeration of supported time-in-force options for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#status).
enum InstrumentStatus {
  preLaunch("PreLaunch"),
  trading("Trading"),
  delivering("Delivering"),
  closed("Closed");

  final String json;

  const InstrumentStatus(this.json);

  /// Allows to get a [InstrumentStatus] object from API responses
  factory InstrumentStatus.fromString(String str) {
    return InstrumentStatus.values.singleWhere((e) => e.json == str);
  }
}
