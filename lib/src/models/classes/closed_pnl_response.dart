import '../enums/category.dart';
import 'closed_pnl_record.dart';

class ClosedPnlResponse {
  final Category category;
  final List<ClosedPnlRecord> list;
  final String nextPageCursor;

  ClosedPnlResponse({
    required this.category,
    required this.list,
    required this.nextPageCursor,
  });

  factory ClosedPnlResponse.fromMap(Map<String, dynamic> map) {
    return ClosedPnlResponse(
      category: Category.fromString(map['category']),
      list: List<ClosedPnlRecord>.from(
        map['list']?.map((item) => ClosedPnlRecord.fromMap(item)) ?? [],
      ),
      nextPageCursor: map['nextPageCursor'] ?? '',
    );
  }
}
