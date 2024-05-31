import '../enums/category.dart';
import 'user_trade.dart';

class GetTradesResponse {
  final Category category;
  final List<UserTrade> trades;
  final String nextPageCursor;

  GetTradesResponse({
    required this.category,
    required this.trades,
    required this.nextPageCursor,
  });

  factory GetTradesResponse.fromMap(Map<String, dynamic> map) {
    return GetTradesResponse(
      category: Category.fromString(map['category']),
      trades: List<UserTrade>.from(map['list'].map((trade) => UserTrade.fromMap(trade))),
      nextPageCursor: map['nextPageCursor'] as String,
    );
  }
}
