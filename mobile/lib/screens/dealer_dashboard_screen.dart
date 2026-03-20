import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DealerDashboardScreen extends StatelessWidget {
  const DealerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.username}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Manage your official stock levels below.'),
            const SizedBox(height: 24),
            _buildStockcontrol(context),
            const SizedBox(height: 24),
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const Expanded(
              child: Center(child: Text('No recent updates yet.')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateStockDialog(context),
        label: const Text('Update Stock'),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user?.dealerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No dealer profile found for this user.')),
      );
      return;
    }

    final fullController = TextEditingController();
    final emptyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Official Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fullController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Full Cylinders Available'),
            ),
            TextField(
              controller: emptyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Empty Slots / Capacity'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final full = int.tryParse(fullController.text) ?? 0;
              final empty = int.tryParse(emptyController.text) ?? 0;
              
              final success = await auth.updateStock(
                user!.dealerId!,
                full,
                empty,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Stock updated!' : 'Failed to update stock')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildStockcontrol(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStockItem(context, 'Full Cylinders', '12', Colors.green),
            _buildStockItem(context, 'Empty Slots', '45', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
