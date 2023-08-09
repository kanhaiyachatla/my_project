import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,

          child: Column(
            children: [
              SizedBox(
                height: size.height / 5,
              ),
              const Text('Reset Password',
                  style: TextStyle(
                      fontSize: 35,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent)),
              SizedBox(
                height: size.height / 10,
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: double.infinity,
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Form(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter your Email',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 5,),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _email,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'Enter Email',
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (email) => (email != null &&
                                      !EmailValidator.validate(
                                          _email.text.trim()))
                                  ? 'Enter a Valid Email'
                                  : null,
                            ),
                            SizedBox(
                              height: size.height / 35,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  textStyle:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                                onPressed: () {
                                  resetPassword();
                                },
                                child: const Text('Send Link'),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'An Email with a link to reset password with be sent if you are already registered with us.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future resetPassword() async {
    showDialog(
      context: NavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim())
          .then((value) {
        snackbarKey.currentState
            ?.showSnackBar(const SnackBar(content: Text("Password reset Link Sent")));
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.message!)));
      Navigator.of(context).pop();
    }
  }
}
