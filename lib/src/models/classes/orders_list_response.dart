import '../enums/category.dart';
import 'order.dart';

class GetOrdersResponse {
  final Category category;
  final String nextPageCursor;
  final List<Order> orders;

  GetOrdersResponse({
    required this.category,
    required this.nextPageCursor,
    required this.orders,
  });

  factory GetOrdersResponse.fromMap(Map<String, dynamic> json) {
    return GetOrdersResponse(
      category: Category.fromString(json['category']),
      nextPageCursor: json['nextPageCursor'],
      orders: (json['list'] as List).map((i) => Order.fromMap(i)).toList(),
    );
  }
}
