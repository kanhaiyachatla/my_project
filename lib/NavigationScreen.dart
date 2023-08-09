import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Screens/HomeScreen.dart';
import 'Screens/SignupSelect.dart';
import 'Screens/VerifyEmailScreen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(!snapshot.data!.emailVerified){
            return VerifyEmailScreen();
          }else{
            return HomeScreen();
          }

        } else {
          return SignupSelect();
        }
      },
    );
  }
}
