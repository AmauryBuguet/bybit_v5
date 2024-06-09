import 'order.dart';

class WsOrderMessage {
  final String id;
  final String topic;
  final int creationTime;
  final List<Order> data;

  WsOrderMessage({
    required this.id,
    required this.topic,
    required this.creationTime,
    required this.data,
  });

  factory WsOrderMessage.fromMap(Map<String, dynamic> map) {
    return WsOrderMessage(
      id: map['id'],
      topic: map['topic'],
      creationTime: map['creationTime'],
      data: List<Order>.from(map['data']?.map((x) => Order.fromMap(x))),
    );
  }
}
