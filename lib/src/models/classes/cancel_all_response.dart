import 'order_ids.dart';

class CancelAllResponse {
  final List<OrderIds> list;
  final bool success;

  CancelAllResponse({
    required this.list,
    required this.success,
  });

  factory CancelAllResponse.fromMap(Map<String, dynamic> json) {
    var listFromJson = json['list'] as List;
    List<OrderIds> orderList = listFromJson.map((i) => OrderIds.fromJson(i)).toList();

    return CancelAllResponse(
      list: orderList,
      success: json['success'] == "1",
    );
  }
}
