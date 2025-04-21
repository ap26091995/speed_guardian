import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapWithSpeedScreen extends StatefulWidget {
  @override
  _MapWithSpeedScreenState createState() => _MapWithSpeedScreenState();
}

class _MapWithSpeedScreenState extends State<MapWithSpeedScreen> with WidgetsBindingObserver {
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  StreamSubscription<Position>? _positionStream;

  double _currentSpeed = 0.0; // in km/h
  double _highestSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchCurrentLocation();
    _loadCustomMarkerIcon();
    _startTrackingSpeedAndLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusStream?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTrackingSpeedAndLocation(); // Resume tracking
    }
  }

  void fetchCurrentLocation() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable GPS.'),
            action: SnackBarAction(
              label: 'Enable',
              onPressed: Geolocator.openLocationSettings,
            ),
          ),
        );
      } else if (status == ServiceStatus.enabled) {
        _startTrackingSpeedAndLocation();
      }
    });
  }

  Future<void> _loadCustomMarkerIcon() async {
    final ByteData byteData = await rootBundle.load('assets/images/gps.png');

    final Uint8List imageData = byteData.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      imageData,
      targetWidth: 60, // 👈 make smaller (e.g., 40–80)
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
  }


  void _startTrackingSpeedAndLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled.'),
          action: SnackBarAction(
            label: 'Enable',
            onPressed: Geolocator.openLocationSettings,
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied forever. Open app settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: Geolocator.openAppSettings,
          ),
        ),
      );
      return;
    }

    // Start listening to position stream
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentSpeed = position.speed * 3.6; // m/s to km/h
        _highestSpeed = _currentSpeed > _highestSpeed ? _currentSpeed : _highestSpeed;

        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation!,
            icon: _currentLocationIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: 'Current Speed',
              snippet: '${_currentSpeed.toStringAsFixed(2)} km/h',
            ),
          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 20,
            ),
          ),
        );
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 15.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Speed & Location")),
      body: _currentLocation == null || _currentLocationIcon == null
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
              target: _currentLocation!,
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Speed overlay (top right)
          Positioned(
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
                    'Speed: ${_currentSpeed.toStringAsFixed(2)} km/h',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Top: ${_highestSpeed.toStringAsFixed(2)} km/h',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
