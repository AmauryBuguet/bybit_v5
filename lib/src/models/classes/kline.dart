/// Represents a single candlestick (kline) in the Bybit API response.
class Kline {
  final int startTime;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final double volume;
  final double turnover;

  /// Default constructor
  Kline({
    required this.startTime,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.turnover,
  });

  /// Create a [Kline] object from Bybit API json response
  factory Kline.fromList(List<dynamic> jsonList) {
    return Kline(
      startTime: int.parse(jsonList[0]),
      openPrice: double.parse(jsonList[1]),
      highPrice: double.parse(jsonList[2]),
      lowPrice: double.parse(jsonList[3]),
      closePrice: double.parse(jsonList[4]),
      volume: double.parse(jsonList[5]),
      turnover: double.parse(jsonList[6]),
    );
  }
}
