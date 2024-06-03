class TickerInfo {
  final String symbol;
  final double lastPrice;
  final double indexPrice;
  final double markPrice;
  final double prevPrice24h;
  final double price24hPcnt;
  final double highPrice24h;
  final double lowPrice24h;
  final double prevPrice1h;
  final double openInterest;
  final double openInterestValue;
  final double turnover24h;
  final double volume24h;
  final double? fundingRate;
  final int nextFundingTime;
  final double? predictedDeliveryPrice;
  final double? basisRate;
  final double? basis;
  final double? deliveryFeeRate;
  final int? deliveryTime;
  final double ask1Size;
  final double bid1Price;
  final double ask1Price;
  final double bid1Size;

  TickerInfo({
    required this.symbol,
    required this.lastPrice,
    required this.indexPrice,
    required this.markPrice,
    required this.prevPrice24h,
    required this.price24hPcnt,
    required this.highPrice24h,
    required this.lowPrice24h,
    required this.prevPrice1h,
    required this.openInterest,
    required this.openInterestValue,
    required this.turnover24h,
    required this.volume24h,
    required this.fundingRate,
    required this.nextFundingTime,
    required this.predictedDeliveryPrice,
    required this.basisRate,
    required this.basis,
    required this.deliveryFeeRate,
    required this.deliveryTime,
    required this.ask1Size,
    required this.bid1Price,
    required this.ask1Price,
    required this.bid1Size,
  });

  factory TickerInfo.fromMap(Map<String, dynamic> map) {
    return TickerInfo(
      symbol: map['symbol'],
      lastPrice: double.parse(map['lastPrice']),
      indexPrice: double.parse(map['indexPrice']),
      markPrice: double.parse(map['markPrice']),
      prevPrice24h: double.parse(map['prevPrice24h']),
      price24hPcnt: double.parse(map['price24hPcnt']),
      highPrice24h: double.parse(map['highPrice24h']),
      lowPrice24h: double.parse(map['lowPrice24h']),
      prevPrice1h: double.parse(map['prevPrice1h']),
      openInterest: double.parse(map['openInterest']),
      openInterestValue: double.parse(map['openInterestValue']),
      turnover24h: double.parse(map['turnover24h']),
      volume24h: double.parse(map['volume24h']),
      fundingRate: double.tryParse(map['fundingRate']),
      nextFundingTime: int.parse(map['nextFundingTime']),
      predictedDeliveryPrice: double.tryParse(map['predictedDeliveryPrice']),
      basisRate: double.tryParse(map['basisRate']),
      basis: double.tryParse(map['basis']),
      deliveryFeeRate: double.tryParse(map['deliveryFeeRate']),
      deliveryTime: int.tryParse(map['deliveryTime']),
      ask1Size: double.parse(map['ask1Size']),
      bid1Price: double.parse(map['bid1Price']),
      ask1Price: double.parse(map['ask1Price']),
      bid1Size: double.parse(map['bid1Size']),
    );
  }
}
