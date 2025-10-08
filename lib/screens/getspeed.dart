import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:practice_app/screens/speedometer.dart';

class GetSpeedScreen extends StatefulWidget {
  const GetSpeedScreen({super.key});

  @override
  State<GetSpeedScreen> createState() => _GetSpeedScreenState();
}

class _GetSpeedScreenState extends State<GetSpeedScreen> {
  double _currentSpeed = 0.0;       // In km/h
  double _highestSpeed = 0.0;
  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() async {
    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      );

      _positionStream!.listen((Position position) {
        double speedKmh = (position.speed) * 3.6; // Convert m/s to km/h
      //  print("Speed: ${speedKmh.toStringAsFixed(2)} km/h");

        setState(() {
          _currentSpeed = speedKmh;
          if (_currentSpeed > _highestSpeed) {
            _highestSpeed = _currentSpeed;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 150),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Speed:\n${_currentSpeed.toStringAsFixed(2)} km/h',
                  style: const TextStyle(color: Colors.black, fontSize: 50),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 64),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Highest speed:\n${_highestSpeed.toStringAsFixed(2)} km/h',
                  style: const TextStyle(color: Colors.black, fontSize: 50),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Speedometer(
                  speed: _currentSpeed,
                  speedRecord: _highestSpeed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
