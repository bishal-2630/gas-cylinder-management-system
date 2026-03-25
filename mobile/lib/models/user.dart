enum UserRole {
  customer,
  dealer,
}

class User {
  final int id;
  final String username;
  final UserRole role;
  final String? phoneNumber;
  final int? dealerId;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.phoneNumber,
    this.dealerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['profile']['role'] == 'DEALER' ? UserRole.dealer : UserRole.customer,
      phoneNumber: json['profile']['phone_number'],
      dealerId: json['dealer_profile_id'], // Need to update backend serializer!
    );
  }
}
