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

  await bybit.getOrders(category: Category.linear, symbol: "BTCUSDT");
  return;
  // print('auth: ${bybit.isAuthenticated}');
  // final time = await bybit.getServerTime();
  // final s2 = bybit.subscribeToKlines(interval: TimeInterval.fifteenMinutes, symbol: "BTCUSDT", category: Category.linear);
  // final s = bybit.subscribeToOrderbook(depth: OrderbookDepth.lvl500, symbol: "BTCUSDT", category: Category.linear);
  final s = bybit.subscribeToWalletUpdates();
  // final s = bybit.subscribeToOrderUpdates(category: Category.linear);
  s.stream.listen((data) {
    print("websocket ${data.data.first.coinData.map((e) => e.walletBalance)}");
  });

  await Future.delayed(Duration(seconds: 5));

  final ids = await bybit.placeOrder(
    category: Category.linear,
    symbol: "BTCUSDT",
    side: Side.buy,
    orderType: OrderType.market,
    qty: "0.001",
    // price: "67000",
  );
  await Future.delayed(Duration(seconds: 4));

  final resp = await bybit.getWalletBalance(accountType: AccountType.contract);
  print(resp.coins.map((e) => " ${e.walletBalance} ${e.coin}"));
  // final resp = await bybit.getPositionInfo(category: Category.linear, symbol: "BTCUSDT");
  // print(resp.positions.first.unrealisedPnl);

  // return;

  await Future.delayed(Duration(seconds: 4));

  // await bybit.cancelAllOrders(category: Category.linear, symbol: "BTCUSDT");
  await bybit.placeOrder(
    category: Category.linear,
    symbol: "BTCUSDT",
    side: Side.sell,
    orderType: OrderType.market,
    qty: "0.001",
    reduceOnly: true,
    // price: "67000",
  );

  await Future.delayed(Duration(seconds: 4));

  // final resp2 = await bybit.getPositionInfo(category: Category.linear, symbol: "BTCUSDT");
  // print(resp2.positions.length);

  // await Future.delayed(Duration(seconds: 4));

  bybit.unsubscribeFromTopic(s.topic);

  await Future.delayed(Duration(seconds: 4));

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
