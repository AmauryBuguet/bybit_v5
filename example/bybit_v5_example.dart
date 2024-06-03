import 'package:bybit_v5/bybit_v5.dart';
import 'package:bybit_v5/src/models/enums/account_type.dart';
import 'package:bybit_v5/src/models/enums/instrument_status.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  final DotEnv env;
  env = DotEnv()..load();
  final apiKey = env["API_KEY"];
  final apiSecret = env["API_SECRET"];
  final bybit = BybitApi.authenticated(apiKey: apiKey, apiSecret: apiSecret);
  // print('auth: ${bybit.isAuthenticated}');
  // final time = await bybit.getServerTime();
  // print(time.toString());
  try {
    // final result = await bybit.getPositionInfo(category: Category.linear, symbol: "BTCUSDT", limit: 10);
    final result = await bybit.getDerivativesTickers(category: Category.linear);
    // final result = await bybit.getWalletBalance(accountType: AccountType.contract);
    // final result = await bybit.getTradeHistory(category: Category.linear, symbol: "BTCUSDT", limit: 10);
    print(result.length);
  } catch (e) {
    print(e);
  }
}
