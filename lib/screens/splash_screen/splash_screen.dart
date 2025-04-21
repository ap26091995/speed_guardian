import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

import '../../service/global.dart';
import '../speedmap.dart';
import 'offline_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  static const timeout = const Duration(seconds: 3);
  static const ms = const Duration(milliseconds: 1);
  StreamSubscription<ConnectivityStatus>? subscription;

  startTimeout([int? milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return new Timer(duration, checkConnection);
  }

  checkConnection() {
    subscription = ConnectivityWrapper.instance.onStatusChange.listen((event) async {
      if (event == ConnectivityStatus.DISCONNECTED) {
        print("Disconnected 11");
        OfflinePage.show(context);
      } else {
        push(context: context, screen: MapWithSpeedScreen(),pushUntil: true);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    startTimeout();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Container(
       height: MediaQuery.of(context).size.height,
       width: MediaQuery.of(context).size.width,
       child: Image.asset(
         'assets/images/logo.png',
         // fit: BoxFit.fill,
         // height: MediaQuery.of(context).size.height,
       ),
     ),
    );
  }
}
