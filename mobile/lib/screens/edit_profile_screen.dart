import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/dealer.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final Dealer? dealerInfo;

  const EditProfileScreen({super.key, required this.user, this.dealerInfo});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  // Dealer specific controllers
  TextEditingController? _dealerNameController;
  TextEditingController? _addressController;
  TextEditingController? _licenseController;
  TextEditingController? _panController;
  TextEditingController? _contactPersonController;
  TextEditingController? _openingTimeController;
  TextEditingController? _closingTimeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');

    if (widget.user.role == UserRole.dealer) {
      _dealerNameController = TextEditingController(text: widget.dealerInfo?.name ?? '');
      _addressController = TextEditingController(text: widget.dealerInfo?.address ?? '');
      _licenseController = TextEditingController(text: widget.dealerInfo?.licenseNumber ?? '');
      _panController = TextEditingController(text: widget.dealerInfo?.panNumber ?? '');
      _contactPersonController = TextEditingController(text: widget.dealerInfo?.contactPerson ?? '');
      _openingTimeController = TextEditingController(text: widget.dealerInfo?.openingTime ?? '');
      _closingTimeController = TextEditingController(text: widget.dealerInfo?.closingTime ?? '');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dealerNameController?.dispose();
    _addressController?.dispose();
    _licenseController?.dispose();
    _panController?.dispose();
    _contactPersonController?.dispose();
    _openingTimeController?.dispose();
    _closingTimeController?.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Map<String, dynamic> data = {
        'full_name': _fullNameController.text,
        'phone_number': _phoneController.text,
      };

      if (widget.user.role == UserRole.dealer) {
        data['dealer_name'] = _dealerNameController?.text;
        data['address'] = _addressController?.text;
        data['license_number'] = _licenseController?.text;
        data['pan_number'] = _panController?.text;
        data['contact_person'] = _contactPersonController?.text;
        data['opening_time'] = _openingTimeController?.text;
        data['closing_time'] = _closingTimeController?.text;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(data);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),

                    if (widget.user.role == UserRole.dealer) ...[
                      const SizedBox(height: 32),
                      const Text('Dealership Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dealerNameController,
                        decoration: const InputDecoration(labelText: 'Dealership Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openingTimeController,
                              decoration: const InputDecoration(labelText: 'Opening Time (HH:MM)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _closingTimeController,
                              decoration: const InputDecoration(labelText: 'Closing Time (HH:MM)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licenseController,
                        decoration: const InputDecoration(labelText: 'License Number', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _panController,
                        decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
