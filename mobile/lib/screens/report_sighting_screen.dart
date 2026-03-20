import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dealer.dart';
import '../providers/dealer_provider.dart';
import '../services/location_service.dart';

class ReportSightingScreen extends StatefulWidget {
  final Dealer dealer;

  const ReportSightingScreen({super.key, required this.dealer});

  @override
  State<ReportSightingScreen> createState() => _ReportSightingScreenState();
}

class _ReportSightingScreenState extends State<ReportSightingScreen> {
  final _locationService = LocationService();
  final _notesController = TextEditingController();
  bool _isAvailable = true;
  bool _isCheckingLocation = false;

  void _submitReport() async {
    setState(() => _isCheckingLocation = true);

    // 1. Geo-fence check
    final isNearby = await _locationService.isWithinRadius(
      targetLat: widget.dealer.latitude,
      targetLng: widget.dealer.longitude,
      radiusInMeters: 500, // 500m radius
    );

    setState(() => _isCheckingLocation = false);

    if (!isNearby && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Too Far Away'),
          content: const Text('You must be near the dealer to report a sighting. This helps us maintain data accuracy.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Submit report
    final success = await context.read<DealerProvider>().addSighting(
      widget.dealer.id,
      _isAvailable,
      _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your report!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Sighting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reporting at: ${widget.dealer.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(widget.dealer.address, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            
            const Text('Is gas available here right now?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('AVAILABLE')),
                    selected: _isAvailable,
                    onSelected: (val) => setState(() => _isAvailable = true),
                    selectedColor: Colors.green[100],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('OUT OF STOCK')),
                    selected: !_isAvailable,
                    onSelected: (val) => setState(() => _isAvailable = false),
                    selectedColor: Colors.red[100],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Long queue, only 1 cylinder per person...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCheckingLocation ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: _isCheckingLocation
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT REPORT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Note: We verify your location before submission.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
