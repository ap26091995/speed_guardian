import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../service/location_service.dart';
import '../view/map_view_model.dart';


class MapWithSpeedScreen extends StatefulWidget {
  @override
  _MapWithSpeedScreenState createState() => _MapWithSpeedScreenState();
}

class _MapWithSpeedScreenState extends State<MapWithSpeedScreen>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  late MapViewModel _viewModel;

  GoogleMapController? _mapController;
  BitmapDescriptor? _currentLocationIcon;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = MapViewModel(locationService: _locationService);
    _loadCustomMarkerIcon();
    _startTrackingSpeedAndLocation();
    _setupViewModelListener();
  }

  void _setupViewModelListener() {
    // Listen to ViewModel changes to rebuild UI
    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusStream?.cancel();
    _positionStream?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTrackingSpeedAndLocation(); // Resume tracking
    }
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      final ByteData byteData = await rootBundle.load('assets/images/gps.png');
      final Uint8List imageData = byteData.buffer.asUint8List();

      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: 60,
        targetHeight: 60,
      );

      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? resizedByteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (resizedByteData == null) return;

      final Uint8List resizedMarker = resizedByteData.buffer.asUint8List();

      setState(() {
        _currentLocationIcon = BitmapDescriptor.fromBytes(resizedMarker);
      });
    } catch (e) {
      // Use default marker if custom icon fails to load
      _currentLocationIcon = BitmapDescriptor.defaultMarker;
    }
  }

  void _startTrackingSpeedAndLocation() async {
    _viewModel.setLoading(true);

    // Check service status stream
    _serviceStatusStream = _locationService.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        _viewModel.setError('Location services are disabled. Please enable GPS.');
        _showLocationServiceSnackBar('Location services are disabled. Please enable GPS.');
      } else if (status == ServiceStatus.enabled) {
        _viewModel.clearError();
        _initializeLocationTracking();
      }
    });

    await _initializeLocationTracking();
  }

  Future<void> _initializeLocationTracking() async {
    bool serviceEnabled = await _locationService.checkLocationService();
    if (!serviceEnabled) {
      _viewModel.setError('Location services are disabled.');
      _showLocationServiceSnackBar('Location services are disabled.');
      return;
    }

    LocationPermission permission = await _locationService.checkLocationPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestLocationPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _viewModel.setError('Permission denied forever. Open app settings.');
      _showPermissionSnackBar('Permission denied forever. Open app settings.');
      return;
    }

    if (permission == LocationPermission.denied) {
      _viewModel.setError('Location permission denied.');
      return;
    }

    // Start listening to position stream
    _positionStream?.cancel();
    _positionStream = _locationService.getPositionStream().listen((Position position) {
      _viewModel.updateLocation(position);

      // Update map camera to follow current location
      if (_mapController != null && _viewModel.currentLocation != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _viewModel.currentLocation!,
              zoom: 20,
            ),
          ),
        );
      }
    });
  }

  void _showLocationServiceSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: _locationService.openLocationSettings,
        ),
      ),
    );
  }

  void _showPermissionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: _locationService.openAppSettings,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_viewModel.currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: _viewModel.currentLocation!,
              zoom: 15.0
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    if (_viewModel.currentLocation == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _viewModel.currentLocation!,
        icon: _currentLocationIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: 'Current Speed',
          snippet: '${_viewModel.currentSpeed.toStringAsFixed(2)} km/h',
        ),
      ),
    };
  }

  Widget _buildSpeedOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Speed: ${_viewModel.currentSpeed.toStringAsFixed(2)} km/h',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              'Top: ${_viewModel.highestSpeed.toStringAsFixed(2)} km/h',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_viewModel.errorMessage == null) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _viewModel.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _viewModel.clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_viewModel.isLoading) return const SizedBox.shrink();

    return const Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Speed & Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startTrackingSpeedAndLocation,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _viewModel.resetHighestSpeed,
            tooltip: 'Reset Top Speed',
          ),
        ],
      ),
      body: _currentLocationIcon == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            onMapCreated: _onMapCreated,
            compassEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _viewModel.currentLocation ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          _buildSpeedOverlay(),
          _buildErrorBanner(),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }
}