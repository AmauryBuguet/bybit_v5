import 'dart:convert';

import 'package:http/http.dart' as http;

import '../bybit_v5.dart';
import 'models/enums/option_type.dart';

/// A class to interact with the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/intro).
///
/// Use the `BybitApi.authenticated` constructor when performing
/// actions that require authentication, such as placing orders.
class BybitApi {
  /// The base URL for the Bybit API.
  static const String baseUrl = "api.bybit.com";

  /// Indicates if the instance is authenticated.
  final bool isAuthenticated;

  /// The API key for authenticated requests.
  final String? apiKey;

  /// The API secret for authenticated requests.
  final String? apiSecret;

  /// Creates a non-authenticated instance of the Bybit API client.
  BybitApi()
      : isAuthenticated = false,
        apiKey = null,
        apiSecret = null;

  /// Creates an authenticated instance of the Bybit API client.
  ///
  /// The [apiKey] and [apiSecret] are required for authenticated API calls.
  BybitApi.authenticated({required this.apiKey, required this.apiSecret}) : isAuthenticated = true;

  /// Fetches the server time from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// Returns the server time as a DateTime object using the `timeNano` parameter.
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/time).
  Future<DateTime> getServerTime() async {
    final uri = Uri.https(baseUrl, '/v5/market/time');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int timeNano = int.parse(data['result']['timeNano']);
      final int microseconds = timeNano ~/ Duration.microsecondsPerSecond;
      return DateTime.fromMicrosecondsSinceEpoch(microseconds);
    } else {
      throw Exception('Failed to get server time, code : ${response.statusCode}');
    }
  }

  /// Fetches the server time from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// The [Category] can be [Category.spot], [Category.linear] or [Category.inverse], it default to [Category.linear].
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/kline).
  Future<List<Kline>> getKlines({
    required String symbol,
    required TimeInterval interval,
    Category? category,
    int? start,
    int? end,
    int? limit,
  }) async {
    final queryParams = {
      'symbol': symbol.toUpperCase(),
      'interval': interval.json,
      if (category != null) 'category': category.name,
      if (start != null) 'start': start.toString(),
      if (end != null) 'end': end.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final uri = Uri.https(baseUrl, '/v5/market/kline', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> klineList = data['result']['list'];
      return klineList.map((klineData) => Kline.fromList(klineData)).toList();
    } else {
      throw Exception('Failed to fetch klines, code ${response.statusCode}');
    }
  }

  /// Fetches recent public trading data from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// Parameters [baseCoin] and [optionType] are needed only when [category] is [Category.option].
  ///
  /// Max and default [limit] is 60 when [category] is [Category.option], else default is 500 and max is 1000.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/recent-trade).
  Future<List<Trade>> getPublicRecentTrades({
    required Category category,
    String? symbol,
    String? baseCoin,
    OptionType? optionType,
    int? limit,
  }) async {
    final queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol.toUpperCase(),
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (optionType != null) 'optionType': optionType.name,
      if (limit != null) 'limit': limit.toString(),
    };

    final uri = Uri.https(baseUrl, '/v5/market/recent-trade', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> tradeList = data['result']['list'];
      return tradeList.map((tradeData) => Trade.fromMap(tradeData)).toList();
    } else {
      throw Exception('Failed to fetch recent trades, code ${response.statusCode}');
    }
  }

  /// Places an order using the Bybit API.
  ///
  /// This method requires authentication.
  /// Throws an [Exception] if the instance is not authenticated.
  void placeOrder() {
    if (!isAuthenticated) {
      throw Exception("Authentication required to place an order.");
    }
    // Logic for placing an order
    print("Placing order with API key: $apiKey");
  }
}
