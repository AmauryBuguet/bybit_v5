import '../enums/category.dart';
import 'instrument_info.dart';

class InstrumentsResponse {
  final Category category;
  final String? nextPageCursor;
  final List<InstrumentInfo> instruments;

  InstrumentsResponse({
    required this.category,
    required this.nextPageCursor,
    required this.instruments,
  });

  factory InstrumentsResponse.fromMap(Map<String, dynamic> map) {
    return InstrumentsResponse(
      category: Category.fromString(map['category']),
      nextPageCursor: map['nextPageCursor'],
      instruments: List<InstrumentInfo>.from(map['list'].map((x) => InstrumentInfo.fromMap(x))),
    );
  }
}
