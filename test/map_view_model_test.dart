// test/map_view_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:practice_app/service/location_service.dart';
import 'package:practice_app/view/map_view_model.dart';


class MockLocationService extends Mock implements LocationService {}

void main() {
  late MapViewModel viewModel;
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
    viewModel = MapViewModel(locationService: mockLocationService);
  });

  test('initial values are correct', () {
    expect(viewModel.currentLocation, isNull);
    expect(viewModel.currentSpeed, 0.0);
    expect(viewModel.highestSpeed, 0.0);
    expect(viewModel.isLoading, true);
    expect(viewModel.errorMessage, isNull);
  });

  test('updateLocation updates values correctly', () {
    // Arrange
    final position = Position(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      heading: 0,
      speed: 10, // 10 m/s = 36 km/h
      speedAccuracy: 0,
      headingAccuracy: 0,
      altitudeAccuracy: 0
    );

    // Act
    viewModel.updateLocation(position);

    // Assert
    expect(viewModel.currentLocation, const LatLng(40.7128, -74.0060));
    expect(viewModel.currentSpeed, 36.0);
    expect(viewModel.highestSpeed, 36.0);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, isNull);
  });

  test('setError updates error state', () {
    // Act
    viewModel.setError('Test error message');

    // Assert
    expect(viewModel.errorMessage, 'Test error message');
    expect(viewModel.isLoading, true); // Should remain unchanged
  });

  test('setLoading updates loading state', () {
    // Act
    viewModel.setLoading(false);

    // Assert
    expect(viewModel.isLoading, false);
  });

  test('clearError removes error message', () {
    // Arrange
    viewModel.setError('Test error');

    // Act
    viewModel.clearError();

    // Assert
    expect(viewModel.errorMessage, isNull);
  });

  test('resetHighestSpeed resets highest speed', () {
    // Arrange
    final position = Position(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      heading: 0,
      speed: 20,
      speedAccuracy: 0,
        headingAccuracy: 0,
        altitudeAccuracy: 0
    );
    viewModel.updateLocation(position);

    // Act
    viewModel.resetHighestSpeed();

    // Assert
    expect(viewModel.highestSpeed, 0.0);
    expect(viewModel.currentSpeed, 72.0); // Current speed should remain
  });
}