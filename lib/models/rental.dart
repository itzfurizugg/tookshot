// lib/models/rental.dart
class Rental {
  final int id;
  final int cameraId;
  final String cameraName;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;
  final bool isPaid;

  Rental({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.isPaid,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    // camera adalah relasi object dari Laravel: with(['camera'])
    final camera = json['camera'] as Map<String, dynamic>?;

    // payment adalah relasi object dari Laravel: with(['payment'])
    final payment = json['payment'] as Map<String, dynamic>?;

    return Rental(
      id: int.tryParse(json['id'].toString()) ?? 0,
      cameraId: int.tryParse(json['camera_id'].toString()) ?? 0,

      // Nama kamera ada di camera.name, bukan camera_name
      cameraName: camera?['name']?.toString() ?? 'Unknown',

      startDate: json['start_date']?.toString() ?? '-',

      // Field di DB adalah due_date
      endDate: json['due_date']?.toString() ?? '-',

      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'pending',

      // Cek dari payment.status karena Laravel pakai relasi payment
      isPaid: payment?['status']?.toString() == 'paid' ||
              json['is_paid'] == 1 ||
              json['is_paid'] == true ||
              json['is_paid'] == '1',
    );
  }
}