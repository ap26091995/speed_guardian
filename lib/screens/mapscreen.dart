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

class _CurrentLocationMapScreenState extends State<CurrentLocationMapScreen> {
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
    _getCurrentLocation();
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
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission; // Declare 'permission' outside the if block
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request them.')),
      );
      return;
    }

    if (permission == LocationPermission.whileInUse) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation!,
              infoWindow: const InfoWindow(title: 'Current Location'),
            ),
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
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation!, // Use current location if available initially
          zoom: 15.0,
        ),
        markers: _markers,
        myLocationEnabled: false, // Disable the default blue dot
        myLocationButtonEnabled: false,
      ),
    );
  }
}