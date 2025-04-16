import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ShowAdsScreen extends StatefulWidget {
  const ShowAdsScreen({super.key});

  @override
  State<ShowAdsScreen> createState() => _ShowAdsScreenState();
}

class _ShowAdsScreenState extends State<ShowAdsScreen> {

  BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/9214589741",
      listener: BannerAdListener(onAdLoaded: (Ad? ad) {
        print("Ad Loaded");
      }, onAdFailedToLoad: (Ad? ad, LoadAdError error) {
        print("Error");
        ad!.dispose();
      }, onAdOpened: (Ad? ad) {
        print("Ad Opened");
      }),
      request: const AdRequest());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        child: AdWidget(ad: bannerAd..load(),
          key: UniqueKey(),),
      ),
      body: SafeArea(
          child: Center(child: Text("Ads Screen"))),
    );
  }
}
