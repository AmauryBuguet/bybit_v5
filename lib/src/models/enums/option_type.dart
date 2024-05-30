/// Enumeration of supported sides for queries to the Bybit API.
enum OptionType {
  call("Call"),
  put("Put");

  final String json;

  const OptionType(this.json);

  /// Allows to get a [OptionType] object from API responses
  factory OptionType.fromString(String str) {
    return OptionType.values.singleWhere((e) => e.json == str);
  }
}
