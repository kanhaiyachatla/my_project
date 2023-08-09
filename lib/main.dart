
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'SplashScreen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AwesomeNotifications().initialize(null, [
  //   NotificationChannel(channelKey: 'basic_channel', channelName: 'Basic Notifications', channelDescription: 'Basic Notifications for DigiAtt app')
  // ]);
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final NavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> snackbarKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: NavigatorKey,
        scaffoldMessengerKey: snackbarKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define the default brightness and colors.
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF2f58ca),
            // primary: const Color(0xFF3e7fe6),
            primaryContainer: const Color(0xff3ebde6),
            secondary: const Color(0xFF2f58ca),
          ),

          // Define the default font family.

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
        ),


        home: Splash()

      // home: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       if(!snapshot.data!.emailVerified){
      //         return VerifyEmailScreen();
      //       }else{
      //         return HomeScreen();
      //       }
      //
      //     } else {
      //       return SignupSelect();
      //     }
      //   },
      // ),
    );
  }
}

