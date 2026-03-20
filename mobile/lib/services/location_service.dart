import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check if user is within [radiusInMeters] of a target [lat] and [lng].
  Future<bool> isWithinRadius({
    required double targetLat,
    required double targetLng,
    double radiusInMeters = 500, // Default 500m geo-fence
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;

    final position = await Geolocator.getCurrentPosition();
    
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLng,
    );

    return distance <= radiusInMeters;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
}
