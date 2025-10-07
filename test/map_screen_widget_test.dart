// test/map_screen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:practice_app/screens/speedmap.dart';
import 'package:practice_app/service/location_service.dart';
import 'package:practice_app/view/map_view_model.dart';
import 'package:provider/provider.dart';


class MockLocationService extends Mock implements LocationService {}
class MockMapViewModel extends Mock implements MapViewModel {}

void main() {
  late MockLocationService mockLocationService;
  late MockMapViewModel mockMapViewModel;

  setUp(() {
    mockLocationService = MockLocationService();
    mockMapViewModel = MockMapViewModel();
  });

  testWidgets('shows loading indicator when location is null', (tester) async {
    when(mockMapViewModel.currentLocation).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MapViewModel>.value(
          value: mockMapViewModel,
          child:  MapWithSpeedScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows speed information when location is available', (tester) async {
    when(mockMapViewModel.currentLocation).thenReturn(const LatLng(40.7128, -74.0060));
    when(mockMapViewModel.currentSpeed).thenReturn(50.0);
    when(mockMapViewModel.highestSpeed).thenReturn(80.0);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MapViewModel>.value(
          value: mockMapViewModel,
          child: MapWithSpeedScreen(),
        ),
      ),
    );

    expect(find.text('Speed: 50.00 km/h'), findsOneWidget);
    expect(find.text('Top: 80.00 km/h'), findsOneWidget);
  });

  testWidgets('shows GoogleMap when location is available', (tester) async {
    when(mockMapViewModel.currentLocation).thenReturn(const LatLng(40.7128, -74.0060));
    when(mockMapViewModel.currentSpeed).thenReturn(0.0);
    when(mockMapViewModel.highestSpeed).thenReturn(0.0);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MapViewModel>.value(
          value: mockMapViewModel,
          child: MapWithSpeedScreen(),
        ),
      ),
    );

    expect(find.byType(GoogleMap), findsOneWidget);
  });
}