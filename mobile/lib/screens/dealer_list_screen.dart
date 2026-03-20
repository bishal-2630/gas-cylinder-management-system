import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dealer_provider.dart';
import '../models/dealer.dart';

class DealerListScreen extends StatelessWidget {
  const DealerListScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OFFICIAL_AVAILABLE': return Colors.green;
      case 'COMMUNITY_CONFIRMED': return Colors.blue;
      case 'COMMUNITY_REPORTED': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Dealers'),
      ),
      body: Consumer<DealerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dealers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.dealers.isEmpty) {
            return const Center(child: Text('No dealers found.'));
          }

          return ListView.builder(
            itemCount: provider.dealers.length,
            itemBuilder: (context, index) {
              final dealer = provider.dealers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(dealer.availabilityStatus),
                    child: const Icon(Icons.local_gas_station, color: Colors.white),
                  ),
                  title: Text(dealer.name),
                  subtitle: Text('${dealer.brandName}\n${dealer.address}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dealer.availabilityStatus.replaceAll('_', ' '),
                        style: TextStyle(
                          color: _getStatusColor(dealer.availabilityStatus),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    // Navigate to details or back to map
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
