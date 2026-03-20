class Dealer {
  final int id;
  final String name;
  final String brand;
  final String brandName;
  final double latitude;
  final double longitude;
  final String address;
  final bool isVerified;
  final String availabilityStatus;

  Dealer({
    required this.id,
    required this.name,
    required this.brand,
    required this.brandName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isVerified,
    required this.availabilityStatus,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      brandName: json['brand_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'] ?? '',
      isVerified: json['is_verified'],
      availabilityStatus: json['availability_status'],
    );
  }
}
