// location_service.dart
import 'package:geolocator/geolocator.dart';
import 'location_wrapper.dart';

class LocationService {
  final LocationWrapper locationWrapper;

  LocationService({LocationWrapper? wrapper})
      : locationWrapper = wrapper ?? LocationWrapper();

  Stream<Position> getPositionStream() {
    return locationWrapper.getPositionStream();
  }

  Future<bool> checkLocationService() async {
    return await locationWrapper.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await locationWrapper.checkPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await locationWrapper.requestPermission();
  }

  Stream<ServiceStatus> getServiceStatusStream() {
    return locationWrapper.getServiceStatusStream();
  }

  Future<void> openLocationSettings() async {
    return await locationWrapper.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    return await locationWrapper.openAppSettings();
  }
}