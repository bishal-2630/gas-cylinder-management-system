enum UserRole {
  customer,
  dealer,
}

class User {
  final int id;
  final String username;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final int? dealerId;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.dealerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['profile']['full_name'] ?? '',
      role: json['profile']['role'] == 'DEALER' ? UserRole.dealer : UserRole.customer,
      phoneNumber: json['profile']['phone_number'],
      dealerId: json['dealer_profile_id'], // Need to update backend serializer!
    );
  }
}
