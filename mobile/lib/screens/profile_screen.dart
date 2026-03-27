import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dealer_provider.dart';
import '../models/user.dart';
import '../models/dealer.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        Dealer? dealerInfo;
        if (user.role == UserRole.dealer && user.dealerId != null) {
          final dealerProvider = Provider.of<DealerProvider>(context, listen: false);
          try {
            dealerInfo = dealerProvider.dealers.firstWhere((d) => d.id == user.dealerId);
          } catch (e) {
            // Dealer not found in the list, maybe not updated yet
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: user, dealerInfo: dealerInfo),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Pop back to the root (Home) before logging out to ensure 
                  // the LoginScreen is shown correctly by main.dart
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  await authProvider.logout();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepOrange,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 8),
                _buildInfoTile('Full Name', user.fullName),
                _buildInfoTile('Username', user.username),
                _buildInfoTile('Role', user.role.name.toUpperCase()),
                _buildInfoTile('Phone Number', user.phoneNumber ?? 'Not provided'),

                if (dealerInfo != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Dealership Information'),
                  const SizedBox(height: 8),
                  _buildInfoTile('Dealership Name', dealerInfo.name),
                  _buildInfoTile('Brand', dealerInfo.brandName ?? dealerInfo.brand),
                  _buildInfoTile('Address', dealerInfo.address),
                  _buildInfoTile('License Number', dealerInfo.licenseNumber ?? 'Not provided'),
                  _buildInfoTile('PAN Number', dealerInfo.panNumber ?? 'Not provided'),
                  _buildInfoTile('Contact Person', dealerInfo.contactPerson ?? 'Not provided'),
                  _buildInfoTile('Operating Hours', '${dealerInfo.openingTime ?? 'N/A'} - ${dealerInfo.closingTime ?? 'N/A'}'),
                  _buildInfoTile('Status', dealerInfo.isVerified ? 'Verified' : 'Pending Verification'),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
