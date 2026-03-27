class Dealer {
  final int id;
  final String name;
  final String brand;
  final String brandName;
  final double latitude;
  final double longitude;
  final String address;
  final String? phoneNumber;
  final String? licenseNumber;
  final String? panNumber;
  final String? openingTime;
  final String? closingTime;
  final String? contactPerson;
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
    this.phoneNumber,
    this.licenseNumber,
    this.panNumber,
    this.openingTime,
    this.closingTime,
    this.contactPerson,
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
      phoneNumber: json['phone_number'],
      licenseNumber: json['license_number'],
      panNumber: json['pan_number'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      contactPerson: json['contact_person'],
      isVerified: json['is_verified'],
      availabilityStatus: json['availability_status'],
    );
  }
}
