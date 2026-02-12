import 'package:intl/intl.dart';

String formatRupiah(dynamic price) {
  final number = double.tryParse(price.toString()) ?? 0;
  return 'Rp ${NumberFormat('#,###', 'id_ID').format(number)}';
}