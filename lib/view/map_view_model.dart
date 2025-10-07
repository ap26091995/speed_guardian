// map_view_model.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../service/location_service.dart';

class MapViewModel with ChangeNotifier {
  final LocationService locationService;

  LatLng? _currentLocation;
  double _currentSpeed = 0.0;
  double _highestSpeed = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  MapViewModel({required this.locationService});

  LatLng? get currentLocation => _currentLocation;
  double get currentSpeed => _currentSpeed;
  double get highestSpeed => _highestSpeed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void updateLocation(Position position) {
    _currentLocation = LatLng(position.latitude, position.longitude);
    _currentSpeed = position.speed * 3.6; // m/s to km/h

    if (_currentSpeed > _highestSpeed) {
      _highestSpeed = _currentSpeed;
    }

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void resetHighestSpeed() {
    _highestSpeed = 0.0;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}