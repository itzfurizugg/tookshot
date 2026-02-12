// lib/models/camera.dart
class Camera {
  final int id;
  final String name;
  final String brand;
  final String description;
  final double pricePerDay;
  final String? imageUrl;
  final bool isAvailable;

  Camera({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.pricePerDay,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'],
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      pricePerDay: double.parse(json['price_per_day'].toString()),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
    );
  }
}