import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-2811193248484236/3358944209';
    }else if(Platform.isIOS){
      return 'ca-app-pub-2811193248484236/6379821221';
    }

    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) => print('Ad loaded'),
    onAdFailedToLoad: (ad,error) {
      ad.dispose();
      print('Ad failed to Load : $error');
    },
    onAdOpened: (ad) => print('Ad opened'),
  );

}