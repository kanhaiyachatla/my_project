import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'ForgotPasswordScreen.dart';
import 'SignupSelect.dart';
import 'VerifyEmailScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isVisible = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height / 10,
              ),
              Text(
                'Login',
                style: TextStyle(
                    fontSize: size.height * 0.07,
                    fontFamily: 'Inter',
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.height / 10,
              ),
              SizedBox(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 7, left: 10.0),
                              child: Text(
                                'Username',
                                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                              ),
                            ),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _email,
                              decoration: InputDecoration(
                                  focusColor:
                                      Theme.of(context).colorScheme.primary,
                                  hintText: 'Enter Email',
                                  prefixIcon: const Icon(Icons.email_rounded),
                                  hintStyle: const TextStyle(fontSize: 12)),
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 13, left: 10.0),
                              child: Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                              ),
                            ),
                            TextField(
                                controller: _password,
                                obscureText: !isVisible,
                                decoration: InputDecoration(
                                  focusColor:
                                      Theme.of(context).colorScheme.primary,
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  hintStyle: const TextStyle(fontSize: 12),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isVisible = !isVisible;
                                        });
                                      },
                                      icon: Icon(!isVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off)),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPasswordScreen()));
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(6),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                  onPressed: () {
                                    Login(_email.text.trim(),
                                        _password.text.trim());
                                  },
                                  child: const Text(
                                    'Login',
                                    style:
                                        TextStyle(fontSize: 20,),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'New User? ',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignupSelect()));
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: size.height / 70,
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                height: size.height / 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future Login(String email, String password) async {
    showDialog(
        context: NavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => {
            Navigator.of(context).pop(),
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => VerifyEmailScreen()))
              });
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.message!)));
      Navigator.of(context).pop();
    }
  }
}
