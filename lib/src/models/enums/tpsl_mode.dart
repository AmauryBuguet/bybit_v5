/// Enumeration of supported tpsl modes for queries to the Bybit API.
enum TpslMode {
  full("Full"),
  partial("Partial");

  final String json;

  const TpslMode(this.json);

  /// Allows to get a [TpslMode] object from API responses
  factory TpslMode.fromString(String str) {
    return TpslMode.values.singleWhere((e) => e.json == str);
  }
}
