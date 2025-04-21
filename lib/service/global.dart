import 'package:flutter/material.dart';

Future<T?> push<T>({
  required BuildContext context,
  required Widget screen,
  bool pushUntil = false,
}) {
  if (pushUntil) {
    return Navigator.of(context).pushAndRemoveUntil<T>(MaterialPageRoute(builder: (_) => screen), (Route<dynamic> route) => false);
  }
  return Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));
}