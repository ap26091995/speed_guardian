import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:practice_app/screens/speedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GetSpeedScreen extends StatefulWidget {
  const GetSpeedScreen({super.key});

  @override
  State<GetSpeedScreen> createState() => _GetSpeedScreenState();
}

class _GetSpeedScreenState extends State<GetSpeedScreen> {

  String? speedInMps;
  double velocity = 0;
  double highestVelocity = 0.0;

  getSpeed(){
    Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 2,
            timeLimit: Duration(seconds: 3)
        )).listen((position) {
       speedInMps =
      position.speed.toStringAsPrecision(2); // this is your speed
      print("Speed is:${speedInMps}");
    });}


  void _onAccelerate(UserAccelerometerEvent? event) {
    double newVelocity = sqrt(
        event!.x * event.x + event.y * event.y + event.z * event.z
    );


    if ((newVelocity - velocity).abs() < 1) {
      return;
    }

    setState(() {
      velocity = newVelocity;

      if (velocity > highestVelocity) {
        highestVelocity = velocity;
      }

      print("Velocity:${velocity}");
    });
  }


  getAccelerate(){
    userAccelerometerEventStream().listen(
          (UserAccelerometerEvent event) {
        print("event:$event");
        _onAccelerate(event);
        setState(() {

        });
      },
      onError: (error) {

      },
      cancelOnError: true,
    );
  }


  @override
  void initState() {
    // TODO: implement initState
   // getSpeed();

    getAccelerate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Stack(
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 150),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Speed:\n${velocity.toStringAsFixed(2)} km/h',
                        style: TextStyle(
                            color: Colors.black,fontSize: 50
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 64),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Highest speed:\n${highestVelocity.toStringAsFixed(2)} km/h',
                        style: TextStyle(
                            color: Colors.black,fontSize: 50
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                  Center(
                      child: Speedometer(
                        speed: velocity,
                        speedRecord: highestVelocity,
                      )
                  )
                ]
            ),
          ),
        ],
      )
    );
  }
}
