import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // New Dealer Fields
  final _licenseController = TextEditingController();
  final _panController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _contactPersonController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  void _handleSignup() async {
    if (_usernameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields (Username, Mobile Number & Password)')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().signup(
      username: _usernameController.text,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
      role: _selectedRole,
      licenseNumber: _selectedRole == UserRole.dealer ? _licenseController.text : null,
      panNumber: _selectedRole == UserRole.dealer ? _panController.text : null,
      openingTime: _selectedRole == UserRole.dealer ? _openingTimeController.text : null,
      closingTime: _selectedRole == UserRole.dealer ? _closingTimeController.text : null,
      contactPerson: _selectedRole == UserRole.dealer ? _contactPersonController.text : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please login.')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed. Username might be taken.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join the Gas Management Network',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name / Business Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('I am a:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Customer'),
                    leading: Radio<UserRole>(
                      value: UserRole.customer,
                      groupValue: _selectedRole,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Dealer'),
                    leading: Radio<UserRole>(
                      value: UserRole.dealer,
                      groupValue: _selectedRole,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_selectedRole == UserRole.dealer) ...[
              const Divider(height: 48),
              const Text('Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 16),
              TextField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: 'Business License Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _panController,
                decoration: const InputDecoration(labelText: 'PAN / VAT Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _openingTimeController,
                      decoration: const InputDecoration(labelText: 'Opening Time (e.g. 09:00)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _closingTimeController,
                      decoration: const InputDecoration(labelText: 'Closing Time (e.g. 18:00)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contactPersonController,
                decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder()),
              ),
            ],
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}
