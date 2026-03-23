import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/dealer_provider.dart';
import '../models/dealer.dart';

import 'dealer_list_screen.dart';
import 'dealer_detail_screen.dart';
import 'report_sighting_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(27.7172, 85.3240); // Kathmandu

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  BitmapDescriptor _getMarkerColor(String status) {
    switch (status) {
      case 'OFFICIAL_AVAILABLE':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'COMMUNITY_CONFIRMED':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'COMMUNITY_REPORTED':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DealerProvider>().refreshDealers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas Availability Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DealerProvider>().refreshDealers(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMap(context),
          const DealerListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Dealers'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tap a pin to report sighting')),
              );
            },
            label: const Text('Report Sighting'),
            icon: const Icon(Icons.add_location_alt),
          )
        : null,
    );
  }

  Widget _buildMap(BuildContext context) {
    return Consumer<DealerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.dealers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final markers = provider.dealers.map((dealer) {
          return Marker(
            markerId: MarkerId(dealer.id.toString()),
            position: LatLng(dealer.latitude, dealer.longitude),
            icon: _getMarkerColor(dealer.availabilityStatus),
            infoWindow: InfoWindow(
              title: dealer.name,
              snippet: '${dealer.brandName} - ${(dealer.availabilityStatus ?? 'UNKNOWN').replaceAll('_', ' ')}',
              onTap: () => _showDealerDetails(context, dealer),
            ),
          );
        }).toSet();

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              markers: markers,
            ),
            if (provider.isLoading)
              const Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Refreshing...'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDealerDetails(BuildContext context, Dealer dealer) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dealer.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(dealer.brandName, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
              Text('Status: ${(dealer.availabilityStatus ?? 'UNKNOWN').replaceAll('_', ' ')}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportSightingScreen(dealer: dealer),
                      ),
                    );
                  },
                  child: const Text('Add Sighting Report'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[100]),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DealerDetailScreen(dealer: dealer),
                      ),
                    );
                  },
                  child: const Text('View Official Stock Details'),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Quick Report:'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _submitSighting(context, dealer.id, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Available'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _submitSighting(context, dealer.id, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Out of Stock'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitSighting(BuildContext context, int dealerId, bool isAvailable) async {
    Navigator.pop(context); // Close bottom sheet
    final success = await context.read<DealerProvider>().addSighting(dealerId, isAvailable, 'Community report');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Report submitted!' : 'Failed to submit report')),
      );
    }
  }
}
