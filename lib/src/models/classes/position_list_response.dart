import 'package:bybit_v5/src/models/enums/category.dart';

import 'position.dart';

class PositionListResponse {
  final Category category;
  final List<Position> positions;
  final String? nextPageCursor;

  PositionListResponse({
    required this.category,
    required this.positions,
    this.nextPageCursor,
  });

  factory PositionListResponse.fromMap(Map<String, dynamic> map) {
    return PositionListResponse(
      category: Category.fromString(map['category']),
      positions: List<Position>.from(
        (map['list'] as List<dynamic>).map(
          (item) => Position.fromMap(item as Map<String, dynamic>),
        ),
      ),
      nextPageCursor: map['nextPageCursor'] as String?,
    );
  }
}
