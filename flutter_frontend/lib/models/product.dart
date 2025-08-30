class Product {
  final String barcode;
  final String name;
  final String category;
  final String manufacturer;
  final String manufactureDate;
  final String? owner;
  final String currentStatus;
  final List<Map<String, dynamic>>? distributionHistory;

  Product({
    required this.barcode,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.manufactureDate,
    this.owner,
    required this.currentStatus,
    this.distributionHistory,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      manufactureDate: json['manufactureDate'] ?? '',
      owner: json['owner'],
      currentStatus: json['currentStatus'] ?? 'unknown',
      distributionHistory: json['distributionHistory'] != null
          ? List<Map<String, dynamic>>.from(json['distributionHistory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'category': category,
      'manufacturer': manufacturer,
      'manufactureDate': manufactureDate,
      'owner': owner,
      'currentStatus': currentStatus,
      'distributionHistory': distributionHistory,
    };
  }
}
