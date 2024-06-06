import 'package:bybit_v5/bybit_v5.dart';
import 'package:bybit_v5/src/models/enums/account_type.dart';
import 'package:bybit_v5/src/models/enums/instrument_status.dart';
import 'package:bybit_v5/src/models/enums/orderbook_depth.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  final DotEnv env;
  env = DotEnv()..load();
  final apiKey = env["API_KEY"];
  final apiSecret = env["API_SECRET"];
  final bybit = BybitApi.authenticated(apiKey: apiKey, apiSecret: apiSecret);
  final r = await bybit.getOpenInterest(category: Category.linear, symbol: "BTCUSDT", interval: IntervalTime.fifteenMinutes);
  print(r.first.value);
  return;
  // print('auth: ${bybit.isAuthenticated}');
  // final time = await bybit.getServerTime();
  // final s2 = bybit.subscribeToKlines(interval: TimeInterval.fifteenMinutes, symbol: "BTCUSDT", category: Category.linear);
  // final s = bybit.subscribeToOrderbook(depth: OrderbookDepth.lvl500, symbol: "BTCUSDT", category: Category.linear);
  // final s = bybit.subscribeToPosition();
  final s = bybit.subscribeToPositionUpdates(category: Category.linear);
  s.stream.listen((data) {
    print("order ${data.data.first.unrealisedPnl}");
  });

  await Future.delayed(Duration(minutes: 2));

  // final ids = await bybit.placeOrder(
  //   category: Category.linear,
  //   symbol: "BTCUSDT",
  //   side: Side.buy,
  //   orderType: OrderType.limit,
  //   qty: "0.001",
  //   price: "69000",
  // );
  // await Future.delayed(Duration(seconds: 5));

  // await bybit.cancelAllOrders(category: Category.linear, symbol: "BTCUSDT");

  // await Future.delayed(Duration(seconds: 5));

  bybit.unsubscribeFromTopic(s.topic);

  await Future.delayed(Duration(seconds: 5));
  // bybit.disconnectWs();

  // print(time.toString());
  // try {
  //   // final result = await bybit.getPositionInfo(category: Category.linear, symbol: "BTCUSDT", limit: 10);
  //   final result = await bybit.getDerivativesTickers(category: Category.linear);
  //   // final result = await bybit.getWalletBalance(accountType: AccountType.contract);
  //   // final result = await bybit.getTradeHistory(category: Category.linear, symbol: "BTCUSDT", limit: 10);
  //   print(result.length);
  // } catch (e) {
  //   print(e);
  // }
}
