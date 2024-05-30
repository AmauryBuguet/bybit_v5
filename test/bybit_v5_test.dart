import 'package:bybit_v5/bybit_v5.dart';
import 'package:test/test.dart';

void main() {
  group('BybitApi tests :', () {
    final bybit = BybitApi();

    setUp(() {
      // Additional setup goes here.
    });

    test('BybitApi object is not authenticated', () {
      expect(bybit.isAuthenticated, isFalse);
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
  });
}
