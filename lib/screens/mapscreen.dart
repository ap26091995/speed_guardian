import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class CurrentLocationMapScreen extends StatefulWidget {
  @override
  _CurrentLocationMapScreenState createState() => _CurrentLocationMapScreenState();
}

class _CurrentLocationMapScreenState extends State<CurrentLocationMapScreen>  with WidgetsBindingObserver {
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  fetchCurrentLocation(){
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled. Please enable GPS.'),
            action: SnackBarAction(
              label: 'Enable',
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      } else if (status == ServiceStatus.enabled) {
        _getCurrentLocation(); // Try again when service is re-enabled
      }
    });

  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    fetchCurrentLocation();
    _loadCustomMarkerIcon();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusStream?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the user comes back from settings, try to get the location again
      _getCurrentLocation();
    }
  }

  Future<void> _loadCustomMarkerIcon() async {
    final ByteData bytes = await rootBundle.load('assets/images/gps.png');
    final Uint8List list = bytes.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(list);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? resizedBytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedBytes == null) {
      return;
    }
    final Uint8List resizedList = resizedBytes.buffer.asUint8List();
    setState(() {
      _currentLocationIcon = BitmapDescriptor.bytes(resizedList);
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location services are disabled. Please enable GPS.'),
          action: SnackBarAction(
            label: 'Enable',
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location permission permanently denied. Please enable it in app settings.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    // If permissions are granted
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation!,
            infoWindow: InfoWindow(
              title: 'Current Speed',
              snippet: '${(position.speed * 3.6).toStringAsFixed(2)} km/h', // m/s → km/h
            ),          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 15.0,
            ),
          ),
        );
      });
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location with Custom Icon'),
      ),
      body: _currentLocation == null || _currentLocationIcon == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Location permission not granted or GPS is disabled.\nPlease enable location and allow access.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Geolocator.openLocationSettings();
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Open Location Settings'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Geolocator.openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open App Settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : GoogleMap(
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
    );
  }}