import '../enums/account_type.dart';
import 'coin_balance.dart';

class WalletBalance {
  final AccountType accountType;
  final double? accountIMRate;
  final double? accountMMRate;
  final double? totalEquity;
  final double? totalWalletBalance;
  final double? totalMarginBalance;
  final double? totalAvailableBalance;
  final double? totalPerpUPL;
  final double? totalInitialMargin;
  final double? totalMaintenanceMargin;
  final List<CoinBalance> coins;

  WalletBalance({
    required this.accountType,
    this.accountIMRate,
    this.accountMMRate,
    this.totalEquity,
    this.totalWalletBalance,
    this.totalMarginBalance,
    this.totalAvailableBalance,
    this.totalPerpUPL,
    this.totalInitialMargin,
    this.totalMaintenanceMargin,
    required this.coins,
  });

  factory WalletBalance.fromMap(Map<String, dynamic> map) {
    return WalletBalance(
      accountType: AccountType.fromString(map['accountType']),
      accountIMRate: double.tryParse(map['accountIMRate']),
      accountMMRate: double.tryParse(map['accountMMRate']),
      totalEquity: double.tryParse(map['totalEquity']),
      totalWalletBalance: double.tryParse(map['totalWalletBalance']),
      totalMarginBalance: double.tryParse(map['totalMarginBalance']),
      totalAvailableBalance: double.tryParse(map['totalAvailableBalance']),
      totalPerpUPL: double.tryParse(map['totalPerpUPL']),
      totalInitialMargin: double.tryParse(map['totalInitialMargin']),
      totalMaintenanceMargin: double.tryParse(map['totalMaintenanceMargin']),
      coins: List<CoinBalance>.from((map['coin'] as List<dynamic>).map((item) => CoinBalance.fromMap(item))),
    );
  }
}
