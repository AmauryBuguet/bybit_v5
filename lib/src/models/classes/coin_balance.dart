class CoinBalance {
  final String coin;
  final double equity;
  final double? usdValue;
  final double walletBalance;
  final double? free;
  final double? locked;
  final double? spotHedgingQty;
  final double? borrowAmount;
  final double availableToWithdraw;
  final double? accruedInterest;
  final double? totalOrderIM;
  final double? totalPositionIM;
  final double? totalPositionMM;
  final double unrealisedPnl;
  final double cumRealisedPnl;
  final double? bonus;
  final bool? marginCollateral;
  final bool? collateralSwitch;

  CoinBalance({
    required this.coin,
    required this.equity,
    required this.usdValue,
    required this.walletBalance,
    required this.free,
    required this.locked,
    required this.spotHedgingQty,
    required this.borrowAmount,
    required this.availableToWithdraw,
    required this.accruedInterest,
    required this.totalOrderIM,
    required this.totalPositionIM,
    required this.totalPositionMM,
    required this.unrealisedPnl,
    required this.cumRealisedPnl,
    required this.bonus,
    required this.marginCollateral,
    required this.collateralSwitch,
  });

  factory CoinBalance.fromMap(Map<String, dynamic> map) {
    return CoinBalance(
      coin: map['coin'],
      equity: double.parse(map['equity']),
      usdValue: double.tryParse(map['usdValue']),
      walletBalance: double.parse(map['walletBalance']),
      free: double.tryParse(map['free'] ?? ""),
      locked: double.tryParse(map['locked'] ?? ""),
      spotHedgingQty: double.tryParse(map['spotHedgingQty'] ?? ""),
      borrowAmount: double.tryParse(map['borrowAmount']),
      availableToWithdraw: double.parse(map['availableToWithdraw']),
      accruedInterest: double.tryParse(map['accruedInterest']),
      totalOrderIM: double.tryParse(map['totalOrderIM']),
      totalPositionIM: double.tryParse(map['totalPositionIM']),
      totalPositionMM: double.tryParse(map['totalPositionMM']),
      unrealisedPnl: double.parse(map['unrealisedPnl']),
      cumRealisedPnl: double.parse(map['cumRealisedPnl']),
      bonus: double.tryParse(map['bonus'] ?? ""),
      marginCollateral: map['marginCollateral'],
      collateralSwitch: map['collateralSwitch'],
    );
  }
}
