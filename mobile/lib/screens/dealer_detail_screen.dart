import 'package:flutter/material.dart';
import '../models/dealer.dart';
import 'package:intl/intl.dart';

class DealerDetailScreen extends StatelessWidget {
  final Dealer dealer;

  const DealerDetailScreen({super.key, required this.dealer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dealer.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStockCard(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 20),
            Text(
              'Recent Community Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildSightingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_gas_station, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dealer.brandName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(dealer.address, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
        if (dealer.isVerified)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.verified, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text('Verified Dealer', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStockCard(BuildContext context) {
    bool hasOfficial = dealer.availabilityStatus == 'OFFICIAL_AVAILABLE';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2),
                SizedBox(width: 8),
                Text('Official Stock Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStockItem(
                  'Full', 
                  hasOfficial ? 'Available' : 'Out of Stock', 
                  hasOfficial ? Colors.green : Colors.red
                ),
                _buildStockItem('Empty', 'Accepting', Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Last officially updated: ${DateFormat.yMMMd().format(DateTime.now())}',
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: color
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Open external map
            },
            icon: const Icon(Icons.directions),
            label: const Text('Directions'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Status'),
          ),
        ),
      ],
    );
  }

  Widget _buildSightingsList(BuildContext context) {
    // In a real app, this would be fetched from the provider/API
    // Here we show a placeholder list matching the theme
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          leading: Icon(
            index == 0 ? Icons.check_circle : Icons.help_outline,
            color: index == 0 ? Colors.green : Colors.grey,
          ),
          title: Text(index == 0 ? 'Confirmed Available' : 'Reported Unavailable'),
          subtitle: Text(index == 0 ? 'Seen 2 hours ago' : 'Reported yesterday'),
          trailing: Text(index == 0 ? 'By Bishal' : 'Anonymous', style: const TextStyle(fontSize: 10)),
        );
      },
    );
  }
}
