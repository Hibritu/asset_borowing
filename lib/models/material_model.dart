class MaterialModel {
  final String id;
  final String name;
  final String type;
  final int quantity;
  final String location;
  final String imageUrl;
   final String  qrDataString;
  final String description;

  MaterialModel({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.location,
    required this.imageUrl,
    required this.qrDataString,
    required this.description,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['_id'] ?? '', // 👈 assumes MongoDB uses _id
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      qrDataString: json['qrDataString'] ?? '',
      description: json['description'] ?? '',
    );
  }

  
}
