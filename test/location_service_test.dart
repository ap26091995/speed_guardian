// test/location_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:practice_app/service/location_service.dart';
import 'package:practice_app/service/location_wrapper.dart';


class MockLocationWrapper extends Mock implements LocationWrapper {}

void main() {
  late LocationService locationService;
  late MockLocationWrapper mockLocationWrapper;

  setUp(() {
    mockLocationWrapper = MockLocationWrapper();
    locationService = LocationService(wrapper: mockLocationWrapper);
  });

  test('checkLocationService returns true when enabled', () async {
    // Arrange
    when(mockLocationWrapper.isLocationServiceEnabled())
        .thenAnswer((_) async => true);

    // Act
    final result = await locationService.checkLocationService();

    // Assert
    expect(result, true);
    verify(mockLocationWrapper.isLocationServiceEnabled()).called(1);
  });


  test('checkLocationService returns false when disabled', () async {
    // Arrange
    when(mockLocationWrapper.isLocationServiceEnabled())
        .thenAnswer((_) async => false);

    // Act
    final result = await locationService.checkLocationService();

    // Assert
    expect(result, false);
    verify(mockLocationWrapper.isLocationServiceEnabled()).called(1);
  });

  test('checkLocationPermission returns granted permission', () async {
    // Arrange
    when(mockLocationWrapper.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);

    // Act
    final result = await locationService.checkLocationPermission();

    // Assert
    expect(result, LocationPermission.always);
    verify(mockLocationWrapper.checkPermission()).called(1);
  });

  test('requestLocationPermission returns whileInUse permission', () async {
    // Arrange
    when(mockLocationWrapper.requestPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);

    // Act
    final result = await locationService.requestLocationPermission();

    // Assert
    expect(result, LocationPermission.whileInUse);
    verify(mockLocationWrapper.requestPermission()).called(1);
  });

  test('getPositionStream returns stream from wrapper', () {
    // Arrange
    final mockStream = Stream<Position>.fromIterable([]);
    when(mockLocationWrapper.getPositionStream())
        .thenAnswer((_) => mockStream);

    // Act
    final result = locationService.getPositionStream();

    // Assert
    expect(result, mockStream);
    verify(mockLocationWrapper.getPositionStream()).called(1);
  });

  test('openLocationSettings calls wrapper method', () async {
    // Arrange
    when(mockLocationWrapper.openLocationSettings())
        .thenAnswer((_) async => Future.value());

    // Act
    await locationService.openLocationSettings();

    // Assert
    verify(mockLocationWrapper.openLocationSettings()).called(1);
  });

  test('openAppSettings calls wrapper method', () async {
    // Arrange
    when(mockLocationWrapper.openAppSettings())
        .thenAnswer((_) async => Future.value());

    // Act
    await locationService.openAppSettings();

    // Assert
    verify(mockLocationWrapper.openAppSettings()).called(1);
  });
}