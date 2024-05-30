import 'package:bybit_v5/bybit_v5.dart';

void main() {
  var bybit = BybitApi();
  print('auth: ${bybit.isAuthenticated}');
  bybit.getServerTime();
}
