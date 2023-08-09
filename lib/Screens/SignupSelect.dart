import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'SignupScreen.dart';

class SignupSelect extends StatefulWidget {
  const SignupSelect({Key? key}) : super(key: key);

  @override
  State<SignupSelect> createState() => _SignupSelectState();
}

class _SignupSelectState extends State<SignupSelect> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Text(
                    'DigiAtt',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: size.width / 6,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 70,
                  )
                ],
              ),
              SizedBox(
                height: size.height / 8,
              ),
              const Text(
                'Select a role to Sign Up',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(
                height: size.height / 35,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignupScreen(
                                role: 'teacher',
                              )));
                },
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 14.0, bottom: 14, left: 30, right: 30),
                  child: Text(
                    'I am a Teacher',
                    style: TextStyle(
                      fontSize: size.width / 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 35,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignupScreen(role: "student")));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 14.0, bottom: 14, left: 30, right: 30),
                    child: Text(
                      'I am a Student',
                      style: TextStyle(
                        fontSize: size.width / 20,
                      ),
                    ),
                  )),
              SizedBox(
                height: size.height / 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  thickness: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              SizedBox(
                height: size.height / 35,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    ' Login ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
