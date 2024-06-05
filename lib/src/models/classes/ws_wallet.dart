class WsWalletMessage {
  final String id;
  final String topic;
  final int creationTime;
  final List<WalletData> data;

  WsWalletMessage({
    required this.id,
    required this.topic,
    required this.creationTime,
    required this.data,
  });

  factory WsWalletMessage.fromMap(Map<String, dynamic> map) {
    return WsWalletMessage(
      id: map['id'],
      topic: map['topic'],
      creationTime: map['creationTime'],
      data: List<WalletData>.from(map['data']?.map((x) => WalletData.fromMap(x))),
    );
  }
}

class WalletData {
  final String accountType;
  final double? accountLTV;
  final double? accountIMRate;
  final double? accountMMRate;
  final double? totalEquity;
  final double? totalWalletBalance;
  final double? totalMarginBalance;
  final double? totalAvailableBalance;
  final double? totalPerpUPL;
  final double? totalInitialMargin;
  final double? totalMaintenanceMargin;
  final List<CoinData> coinData;

  WalletData({
    required this.accountType,
    this.accountLTV,
    this.accountIMRate,
    this.accountMMRate,
    this.totalEquity,
    this.totalWalletBalance,
    this.totalMarginBalance,
    this.totalAvailableBalance,
    this.totalPerpUPL,
    this.totalInitialMargin,
    this.totalMaintenanceMargin,
    required this.coinData,
  });

  factory WalletData.fromMap(Map<String, dynamic> map) {
    return WalletData(
      accountType: map['accountType'],
      accountLTV: double.tryParse(map['accountLTV']),
      accountIMRate: double.tryParse(map['accountIMRate']),
      accountMMRate: double.tryParse(map['accountMMRate']),
      totalEquity: double.tryParse(map['totalEquity']),
      totalWalletBalance: double.tryParse(map['totalWalletBalance']),
      totalMarginBalance: double.tryParse(map['totalMarginBalance']),
      totalAvailableBalance: double.tryParse(map['totalAvailableBalance']),
      totalPerpUPL: double.tryParse(map['totalPerpUPL']),
      totalInitialMargin: double.tryParse(map['totalInitialMargin']),
      totalMaintenanceMargin: double.tryParse(map['totalMaintenanceMargin']),
      coinData: List<CoinData>.from(map['coin']?.map((x) => CoinData.fromMap(x))),
    );
  }
}

class CoinData {
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
  final bool? collateralSwitch;
  final bool? marginCollateral;

  CoinData({
    required this.coin,
    required this.equity,
    required this.usdValue,
    required this.walletBalance,
    this.free,
    this.locked,
    this.spotHedgingQty,
    required this.borrowAmount,
    required this.availableToWithdraw,
    required this.accruedInterest,
    this.totalOrderIM,
    this.totalPositionIM,
    this.totalPositionMM,
    required this.unrealisedPnl,
    required this.cumRealisedPnl,
    this.bonus,
    this.collateralSwitch,
    this.marginCollateral,
  });

  factory CoinData.fromMap(Map<String, dynamic> map) {
    return CoinData(
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
      collateralSwitch: map['collateralSwitch'],
      marginCollateral: map['marginCollateral'],
    );
  }
}
