import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/dealer_provider.dart';
import '../models/dealer.dart';

import 'dealer_list_screen.dart';
import 'dealer_detail_screen.dart';
import 'report_sighting_screen.dart';
import 'community_report_screen.dart';
import 'profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(27.7172, 85.3240); // Kathmandu

  BitmapDescriptor _getMarkerIcon(String status) {
    // Note: In a real app, you might use different asset icons.
    // For now, we'll use hue-based colors for Google Maps pins.
    switch (status) {
      case 'OFFICIAL_AVAILABLE':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'COMMUNITY_CONFIRMED':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'COMMUNITY_REPORTED':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DealerProvider>().refreshDealers();
    });
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final position = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(position.latitude, position.longitude);
      
      // Update _center so the search button uses real location
      setState(() => _center = userLatLng);
      
      _mapController?.animateCamera(CameraUpdate.newLatLng(userLatLng));
      
      // Auto-search for nearby gas stores on load
      if (mounted) {
        context.read<DealerProvider>().findNearbyGasStores(position.latitude, position.longitude);
      }
    }
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommunityReportScreen()),
              );
            },
            label: const Text('Report Sighting'),
            icon: const Icon(Icons.add_location_alt),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          )
        : null,
    );
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    // Optionally fetch nearby places when camera stops moving
    // context.read<DealerProvider>().findNearbyGasStores(_center.latitude, _center.longitude);
  }

  Widget _buildMap(BuildContext context) {
    return Consumer<DealerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.dealers.isEmpty && provider.nearbyPlaces.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final Set<Marker> markers = {};
        
        // 1. Official/Community Dealers (from our DB)
        markers.addAll(provider.dealers.map((dealer) {
          return Marker(
            markerId: MarkerId(dealer.id.toString()),
            position: LatLng(dealer.latitude, dealer.longitude),
            icon: _getMarkerIcon(dealer.availabilityStatus),
            onTap: () => _showDealerDetails(context, dealer),
            infoWindow: InfoWindow(title: dealer.name, snippet: dealer.brandName),
          );
        }));

        // 2. Nearby Places (from Google API)
        markers.addAll(provider.nearbyPlaces.map((place) {
          final location = place['geometry']['location'];
          final placeId = place['place_id'];
          
          // Check if this place is already in our dealers list to avoid duplicates
          final alreadyManaged = provider.dealers.any((d) => 
            (d.latitude - location['lat'] as double).abs() < 0.0001 && 
            (d.longitude - location['lng'] as double).abs() < 0.0001);

          if (alreadyManaged) return null;

          return Marker(
            markerId: MarkerId('google_$placeId'),
            position: LatLng(location['lat'], location['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan), // Cyan for Google POIs
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: 'Found via Google Maps',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityReportScreen(
                      prefillName: place['name'],
                      prefillAddress: place['vicinity'],
                      fixedLat: location['lat'],
                      fixedLng: location['lng'],
                    ),
                  ),
                );
              },
            ),
          );
        }).whereType<Marker>());

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              padding: const EdgeInsets.only(bottom: 70),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: () => provider.findNearbyGasStores(_center.latitude, _center.longitude),
                backgroundColor: Colors.white,
                child: const Icon(Icons.search, color: Colors.deepOrange),
              ),
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
