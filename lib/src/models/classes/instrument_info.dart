import '../enums/instrument_status.dart';

class InstrumentInfo {
  final String symbol;
  final String contractType;
  final InstrumentStatus status;
  final String baseCoin;
  final String quoteCoin;
  final int launchTime;
  final int deliveryTime;
  final double? deliveryFeeRate;
  final int priceScale;
  final LeverageFilter leverageFilter;
  final PriceFilter priceFilter;
  final LotSizeFilter lotSizeFilter;
  final bool unifiedMarginTrade;
  final int fundingInterval;
  final String settleCoin;
  final String copyTrading;
  final double upperFundingRate;
  final double lowerFundingRate;

  InstrumentInfo({
    required this.symbol,
    required this.contractType,
    required this.status,
    required this.baseCoin,
    required this.quoteCoin,
    required this.launchTime,
    required this.deliveryTime,
    required this.deliveryFeeRate,
    required this.priceScale,
    required this.leverageFilter,
    required this.priceFilter,
    required this.lotSizeFilter,
    required this.unifiedMarginTrade,
    required this.fundingInterval,
    required this.settleCoin,
    required this.copyTrading,
    required this.upperFundingRate,
    required this.lowerFundingRate,
  });

  factory InstrumentInfo.fromMap(Map<String, dynamic> map) {
    return InstrumentInfo(
      symbol: map['symbol'],
      contractType: map['contractType'],
      status: InstrumentStatus.fromString(map['status']),
      baseCoin: map['baseCoin'],
      quoteCoin: map['quoteCoin'],
      launchTime: int.parse(map['launchTime']),
      deliveryTime: int.parse(map['deliveryTime']),
      deliveryFeeRate: double.tryParse(map['deliveryFeeRate']),
      priceScale: int.parse(map['priceScale']),
      leverageFilter: LeverageFilter.fromMap(map['leverageFilter']),
      priceFilter: PriceFilter.fromMap(map['priceFilter']),
      lotSizeFilter: LotSizeFilter.fromMap(map['lotSizeFilter']),
      unifiedMarginTrade: map['unifiedMarginTrade'],
      fundingInterval: map['fundingInterval'],
      settleCoin: map['settleCoin'],
      copyTrading: map['copyTrading'],
      upperFundingRate: double.parse(map['upperFundingRate']),
      lowerFundingRate: double.parse(map['lowerFundingRate']),
    );
  }
}

class LeverageFilter {
  final double minLeverage;
  final double maxLeverage;
  final double leverageStep;

  LeverageFilter({
    required this.minLeverage,
    required this.maxLeverage,
    required this.leverageStep,
  });

  factory LeverageFilter.fromMap(Map<String, dynamic> map) {
    return LeverageFilter(
      minLeverage: double.parse(map['minLeverage']),
      maxLeverage: double.parse(map['maxLeverage']),
      leverageStep: double.parse(map['leverageStep']),
    );
  }
}

class PriceFilter {
  final double minPrice;
  final double maxPrice;
  final double tickSize;

  PriceFilter({
    required this.minPrice,
    required this.maxPrice,
    required this.tickSize,
  });

  factory PriceFilter.fromMap(Map<String, dynamic> map) {
    return PriceFilter(
      minPrice: double.parse(map['minPrice']),
      maxPrice: double.parse(map['maxPrice']),
      tickSize: double.parse(map['tickSize']),
    );
  }
}

class LotSizeFilter {
  final double minNotionalValue;
  final double maxOrderQty;
  final double maxMktOrderQty;
  final double minOrderQty;
  final double qtyStep;
  final double postOnlyMaxOrderQty;

  LotSizeFilter({
    required this.minNotionalValue,
    required this.maxOrderQty,
    required this.maxMktOrderQty,
    required this.minOrderQty,
    required this.qtyStep,
    required this.postOnlyMaxOrderQty,
  });

  factory LotSizeFilter.fromMap(Map<String, dynamic> map) {
    return LotSizeFilter(
      minNotionalValue: double.parse(map['minNotionalValue']),
      maxOrderQty: double.parse(map['maxOrderQty']),
      maxMktOrderQty: double.parse(map['maxMktOrderQty']),
      minOrderQty: double.parse(map['minOrderQty']),
      qtyStep: double.parse(map['qtyStep']),
      postOnlyMaxOrderQty: double.parse(map['postOnlyMaxOrderQty']),
    );
  }
}
