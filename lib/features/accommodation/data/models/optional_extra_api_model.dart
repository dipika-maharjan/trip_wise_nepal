class OptionalExtraApiModel {
  final String id;
  final String accommodationId;
  final String name;
  final String description;
  final double price;
  final String priceType;
  final bool isActive;

  OptionalExtraApiModel({
    required this.id,
    required this.accommodationId,
    required this.name,
    required this.description,
    required this.price,
    required this.priceType,
    required this.isActive,
  });

  factory OptionalExtraApiModel.fromJson(Map<String, dynamic> json) {
    return OptionalExtraApiModel(
      id: json['_id'] ?? '',
      accommodationId: json['accommodationId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priceType: json['priceType'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
