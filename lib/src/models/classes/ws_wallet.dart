import 'coin_balance.dart';

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
  final List<CoinBalance> coinData;

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
      coinData: List<CoinBalance>.from(map['coin']?.map((x) => CoinBalance.fromMap(x))),
    );
  }
}
