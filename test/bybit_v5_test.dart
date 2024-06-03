import 'package:bybit_v5/bybit_v5.dart';
import 'package:bybit_v5/src/models/classes/order_ids.dart';
import 'package:bybit_v5/src/models/classes/position_list_response.dart';
import 'package:bybit_v5/src/models/enums/account_type.dart';
import 'package:test/test.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  group('BybitApi tests :', () {
    late BybitApi bybit;
    setUp(() {
      final DotEnv env;
      // load env variables
      env = DotEnv()..load();
      final apiKey = env["API_KEY"];
      expect(apiKey, isNotNull);
      final apiSecret = env["API_SECRET"];
      expect(apiSecret, isNotNull);
      bybit = BybitApi.authenticated(apiKey: apiKey, apiSecret: apiSecret);
      expect(bybit.isAuthenticated, isTrue);
    });

    test('getServerTime function returns a DateTime object', () async {
      // Call the getServerTime function
      final DateTime serverTime = await bybit.getServerTime();

      // Validate that the serverTime is not null
      expect(serverTime, isNotNull);

      // Validate that the serverTime is a DateTime object
      expect(serverTime, isA<DateTime>());
    });

    test('getKlines returns a List<Kline> object', () async {
      // Call the getKlines function
      final klines = await bybit.getKlines(
        symbol: 'BTCUSDT',
        interval: TimeInterval.oneHour,
        limit: 3,
      );

      // Validate the response
      expect(klines, isA<List<Kline>>());
      expect(klines.length, equals(3));
      expect(klines[0].startTime, isA<DateTime>());
    });

    test('getRecentTrades returns a List<Trade> object', () async {
      // Call the function
      final trades = await bybit.getPublicRecentTrades(
        category: Category.spot,
        limit: 10,
        symbol: 'BTCUSDT',
      );

      // Assert that the returned value is a list of Trade objects
      expect(trades, isA<List<Trade>>());

      // Assert that the list has the correct length
      expect(trades.length, 10);

      // Assert the properties of the first trade
      expect(trades[0].price, isA<double>());
      expect(trades[0].side, isA<Side>());
    });

    test('Place, edit, get and cancel an order', () async {
      // Call the placeOrder function
      OrderIds tradeIds = await bybit.placeOrder(
        category: Category.linear,
        symbol: "BTCUSDT",
        side: Side.buy,
        orderType: OrderType.limit,
        qty: "0.001",
        price: "56500.2",
      );

      // Validate the response
      expect(tradeIds.orderId, isA<String>());

      // Wait a few seconds
      await Future.delayed(Duration(seconds: 2));

      // Update the order
      tradeIds = await bybit.amendOrder(category: Category.linear, symbol: "BTCUSDT", orderId: tradeIds.orderId, price: "57111");

      // Validate the response
      expect(tradeIds.orderId, isA<String>());

      // Wait a few seconds
      await Future.delayed(Duration(seconds: 2));

      // Get all active orders
      final orders = await bybit.getOrders(category: Category.linear, symbol: "BTCUSDT");

      // Validate the response
      expect(orders.orders, isNotEmpty);
      expect(orders.orders.first.orderId, isA<String>());

      // Wait a few seconds
      await Future.delayed(Duration(seconds: 2));

      // Cancel the order
      tradeIds = await bybit.cancelOrder(category: Category.linear, symbol: "BTCUSDT", orderId: tradeIds.orderId);

      // Validate the response
      expect(tradeIds, isA<OrderIds>());
    });

    test('getPositionInfo returns a PositionListResponse object', () async {
      // Call the function
      final response = await bybit.getPositionInfo(
        category: Category.linear,
        limit: 10,
        symbol: 'BTCUSDT',
      );

      // Assert that the returned value is a list of Trade objects
      expect(response, isA<PositionListResponse>());

      // Assert that the list has the correct length
      expect(response.positions.length, isPositive);
    });

    test('set and get leverage value', () async {
      // Call the function
      await bybit.setLeverage(
        category: Category.linear,
        symbol: 'BTCUSDT',
        buyLeverage: 15,
        sellLeverage: 15,
      );
    });

    test('wallet balance properly returned', () async {
      // Call the function
      final result = await bybit.getWalletBalance(
        accountType: AccountType.contract,
        coin: "USDT",
      );

      expect(result.coins.length, 1);
      expect(result.coins.first.equity, isA<double>());
    });

    test('fee rate properly returned', () async {
      // Call the function
      final result = await bybit.getFeeRates(
        category: Category.linear,
        symbol: 'BTCUSDT',
      );

      expect(result.length, 1);
      expect(result.first.makerFeeRate, isA<double>());
    });
  });
}
