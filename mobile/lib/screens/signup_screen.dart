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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  void _handleSignup() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields (Phone & Password)')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().signup(
      _phoneController.text,
      _passwordController.text,
      _selectedRole,
      name: _nameController.text,
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
                height: 120,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join the Gas Management Network',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name (Optional)', border: OutlineInputBorder()),
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
            ListTile(
              title: const Text('Customer'),
              leading: Radio<UserRole>(
                value: UserRole.customer,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
            ),
            ListTile(
              title: const Text('Dealer / Seller'),
              leading: Radio<UserRole>(
                value: UserRole.dealer,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
            ),
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
