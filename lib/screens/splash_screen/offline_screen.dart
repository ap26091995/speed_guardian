import 'package:flutter/material.dart';


class OfflinePage{

  static void show(BuildContext context){
    showDialog(
        context: context,
        builder: (ctx) {
          return Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off,color: Colors.red,size: 150,),
                    SizedBox(height: 50,),
                    Center(child: Text("No internet", style: TextStyle(fontSize: 24,color: Colors.red),)),
                  ],
                ),
              ));
        });
  }
}