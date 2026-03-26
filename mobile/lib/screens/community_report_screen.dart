import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/dealer_provider.dart';
import '../services/api_service.dart';

class CommunityReportScreen extends StatefulWidget {
  const CommunityReportScreen({super.key});

  @override
  State<CommunityReportScreen> createState() => _CommunityReportScreenState();
}

class _CommunityReportScreenState extends State<CommunityReportScreen> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedBrand = 'NEPAL_GAS';
  bool _isAvailable = true;
  bool _isSubmitting = false;

  final Map<String, String> _brands = {
    'NEPAL_GAS': 'Nepal Gas',
    'EVEREST': 'Everest Gas',
    'SIDDHARTHA': 'Siddhartha Gas',
  };

  void _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter store name')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Get current location
      final position = await Geolocator.getCurrentPosition();
      
      // 2. Create Dealer
      final dealer = await _apiService.createDealer(
        _nameController.text,
        _selectedBrand,
        position.latitude,
        position.longitude,
        'Community added location',
      );

      if (dealer != null) {
        // 3. Report Sighting
        await _apiService.reportSighting(dealer.id, _isAvailable, _notesController.text);
        
        if (mounted) {
          context.read<DealerProvider>().refreshDealers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to create dealer');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Sighting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Store/Dealer Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Kalikasthan Gas Store',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Gas Brand', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              items: _brands.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedBrand = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text('Is gas available?', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 20),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any additional details...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT REPORT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
