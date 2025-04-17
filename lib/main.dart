import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:practice_app/screens/admobscreen.dart';
import 'package:practice_app/screens/getspeed.dart';
import 'package:practice_app/screens/mapscreen.dart';
import 'package:practice_app/screens/speedmap.dart';

import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  bool granted = await requestLocationPermission();
  if (granted) {
    // Proceed with accessing location
    print('App can now access location.');
    // Your location accessing logic here
  } else {
    // Handle the case where permission is not granted
    print('App cannot access location.');
    // Inform the user or disable location-dependent features
  }
  runApp(const MyApp());
}

Future<bool> requestLocationPermission() async {
  PermissionStatus status = await Permission.location.request();

  if (status.isGranted) {
    // Permission granted
    print('Location permission granted');
    return true;
  } else if (status.isDenied) {
    // Permission denied
    print('Location permission denied');
    return false;
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, take the user to app settings
    print('Location permission permanently denied');
    openAppSettings(); // This will open the app settings
    return false;
  } else if (status.isLimited) {
    // Permission is limited (iOS only)
    print('Location permission limited');
    return true; // Or handle it as denied based on your app's logic
  }
  return false; // Default return in case of unexpected status
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MapWithSpeedScreen(),
    );
  }
}


