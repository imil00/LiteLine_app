// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../constants/app_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final loc.Location _location = loc.Location();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  // Check location permission
  Future<LocationPermission> checkLocationPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      print('Error checking location permission: $e');
      return LocationPermission.denied;
    }
  }

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission;
    } catch (e) {
      print('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check and request permission
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  // Listen to position changes
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Calculate distance between two points
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate bearing between two points
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (500m)';
      case LocationAccuracy.low:
        return 'Low (500m)';
      case LocationAccuracy.medium:
        return 'Medium (100-500m)';
      case LocationAccuracy.high:
        return 'High (0-100m)';
      case LocationAccuracy.best:
        return 'Best (0-100m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation';
      default:
        return 'Unknown';
    }
  }

  // Create location data for message
  Map<String, dynamic> createLocationData(Position position) {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'timestamp': position.timestamp?.millisecondsSinceEpoch ?? 
                  DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Parse location data from message
  Position? parseLocationData(Map<String, dynamic> locationData) {
    try {
      return Position(
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        timestamp: locationData['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(locationData['timestamp'])
          : DateTime.now(),
        accuracy: locationData['accuracy'] ?? 0.0,
        altitude: locationData['altitude'] ?? 0.0,
        heading: locationData['heading'] ?? 0.0,
        speed: locationData['speed'] ?? 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    } catch (e) {
      print('Error parsing location data: $e');
      return null;
    }
  }

  // Generate Google Maps URL
  String generateGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  // Generate location share text
  String generateLocationShareText(Position position) {
    return 'I\'m at https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  // Check if location is within radius
  bool isLocationWithinRadius({
    required double centerLatitude,
    required double centerLongitude,
    required double targetLatitude,
    required double targetLongitude,
    required double radiusInMeters,
  }) {
    double distance = calculateDistance(
      startLatitude: centerLatitude,
      startLongitude: centerLongitude,
      endLatitude: targetLatitude,
      endLongitude: targetLongitude,
    );

    return distance <= radiusInMeters;
  }

  // Open location in maps app
  Future<void> openLocationInMaps(double latitude, double longitude) async {
    try {
      bool opened = await Geolocator.openLocationSettings();
      if (!opened) {
        // Fallback to web URL
        final url = generateGoogleMapsUrl(latitude, longitude);
        print('Open URL: $url');
        // You can use url_launcher package to open the URL
      }
    } catch (e) {
      print('Error opening location in maps: $e');
    }
  }

  // Get location name from coordinates (requires geocoding)
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      // This would require geocoding service
      // For now, returning coordinates as string
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Error getting location name: $e');
      return 'Unknown Location';
    }
  }

  // Validate coordinates
  bool isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

    // Get default location (can be used as fallback)
  Position getDefaultLocation() {
    return Position(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}