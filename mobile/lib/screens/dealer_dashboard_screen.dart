import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dealer_provider.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.dealerId != null) {
        final dealerProvider = context.read<DealerProvider>();
        dealerProvider.fetchStock(user!.dealerId!);
        dealerProvider.fetchTokens(context.read<AuthProvider>().token!, user.dealerId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stock = context.watch<DealerProvider>().officialStock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (user?.dealerId != null) {
                context.read<DealerProvider>().fetchStock(user!.dealerId!);
              }
            },
          ),
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
            _buildStockcontrol(context, stock),
            const SizedBox(height: 24),
            const Text('Token Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: context.watch<DealerProvider>().tokens.isEmpty
                ? const Center(child: Text('No active tokens in queue.'))
                : ListView.builder(
                    itemCount: context.watch<DealerProvider>().tokens.length,
                    itemBuilder: (context, index) {
                      final token = context.watch<DealerProvider>().tokens[index];
                      final isFulfilled = token['is_fulfilled'] ?? false;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isFulfilled ? Colors.grey : Colors.orange,
                          child: Text('#${token['token_number']}', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('Customer: ${token['user_name']}'),
                        subtitle: Text('Requested: ${token['requested_at'].split('T')[0]}'),
                        trailing: isFulfilled 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () async {
                                final auth = context.read<AuthProvider>();
                                final success = await context.read<DealerProvider>().fulfillToken(
                                  auth.token!, 
                                  token['id'],
                                  user!.dealerId!,
                                );
                                if (context.mounted && !success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to fulfill token')),
                                  );
                                }
                              },
                              child: const Text('Fulfill'),
                            ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateStockDialog(context, stock),
        label: const Text('Update Stock'),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, Map<String, dynamic>? currentStock) {
    final auth = context.read<AuthProvider>();
    final dealerProvider = context.read<DealerProvider>();
    final user = auth.user;
    
    if (user?.dealerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No dealer profile found.')),
      );
      return;
    }

    final fullController = TextEditingController(text: currentStock?['full_cylinders']?.toString() ?? '0');
    final emptyController = TextEditingController(text: currentStock?['empty_cylinders']?.toString() ?? '0');

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
                currentStock?['id'] ?? user!.dealerId!, // Use stock record ID if available
                full,
                empty,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  dealerProvider.fetchStock(user!.dealerId!);
                }
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

  Widget _buildStockcontrol(BuildContext context, Map<String, dynamic>? stock) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStockItem(context, 'Full Cylinders', stock?['full_cylinders']?.toString() ?? '0', Colors.green),
            _buildStockItem(context, 'Empty Slots', stock?['empty_cylinders']?.toString() ?? '0', Colors.blue),
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
