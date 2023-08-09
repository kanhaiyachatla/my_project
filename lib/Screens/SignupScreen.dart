import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../methods/UserModel.dart';
import 'LoginScreen.dart';
import 'VerifyEmailScreen.dart';

class SignupScreen extends StatefulWidget {
  String role;

  SignupScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState(role);
}

class _SignupScreenState extends State<SignupScreen> {
  String role1;

  _SignupScreenState(this.role1);

  @override
  final FormKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _repassword = TextEditingController();
  final _password = TextEditingController();

  bool obscure = false, obscure1 = false;
  bool termsAgreed = false;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    void initState() {
      obscure = false;
      obscure1 = false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Text('Register',
                    style: TextStyle(
                        fontSize: size.height * 0.07,
                        fontFamily: 'Inter',
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  width: size.width * 0.93,
                  height: size.height * 0.64,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: FormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _name,
                                  decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.person_outline),
                                      hintText: 'Enter Name'),
                                  validator: (value) => (value!.isEmpty ||
                                          !RegExp(r'^[a-z A-Z]+$')
                                              .hasMatch(value))
                                      ? 'Enter Valid Name'
                                      : null,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'E-mail',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
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
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _password,
                                  obscureText: !obscure,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      hintText: 'Enter Password',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscure = !obscure;
                                          });
                                        },
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      )),
                                  validator: (value) => (_password
                                              .text.isEmpty ||
                                          (_password.text.length < 8))
                                      ? 'Enter Valid Password with min 8 characters'
                                      : null,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _repassword,
                                  obscureText: !obscure1,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    hintText: 'Re-Enter Password',
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscure1 = !obscure1;
                                          });
                                        },
                                        icon: Icon(!obscure1
                                            ? Icons.visibility
                                            : Icons.visibility_off)),
                                  ),
                                  validator: (value) =>
                                      (_password.text.trim() !=
                                              _repassword.text.trim())
                                          ? 'Passwords don\'t Match '
                                          : null,
                                ),
                              ],
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: termsAgreed,
                                            onChanged: (value) {
                                              setState(() {
                                                termsAgreed = value!;
                                              });
                                            }),
                                        Flexible(
                                          child: Text.rich(
                                            TextSpan(
                                              text:
                                                  'By checking this box, you agree to the ',
                                              children: [
                                                TextSpan(
                                                    recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        showDialog(
                                                            context:
                                                            context,
                                                            barrierDismissible:
                                                            false,
                                                            builder:
                                                                (context) =>
                                                                Center(
                                                                  child:
                                                                  Container(
                                                                    height:
                                                                    size.height / 1.5,
                                                                    margin:
                                                                    EdgeInsets.symmetric(horizontal: 32.0),
                                                                    child:
                                                                    Card(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            InkWell(onTap: () {
                                                                              Navigator.of(context).pop();},child: Text('X',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                                                                            SizedBox(height: 10,),
                                                                            Container(
                                                                              width: double.maxFinite,
                                                                              height: (size.height /1.5)-80,
                                                                              color: Colors.grey.shade200,
                                                                              child: SingleChildScrollView(
                                                                                child: Container(
                                                                                  margin: EdgeInsets.all(12),
                                                                                  child: Flexible(
                                                                                    child: Text.rich(
                                                                                      TextSpan(
                                                                                          text: '\n',
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Privacy Policy',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: '\n\nAppsilon Inc. built the DigiAtt app as an Ad Supported app. This SERVICE is provided by Appsilon Inc. at no cost and is intended for use as is.\n\n',

                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.\n\n',

                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which are accessible at DigiAtt unless otherwise defined in this Privacy Policy.\n\n',

                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Information Collection and Use\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),

                                                                                            TextSpan(
                                                                                              text: 'For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to email address , name, any files you upload. The information that we request will be retained by us and used as described in this privacy policy.\n\n',
                                                                                            ),
                                                                                            TextSpan(
                                                                                                text: 'The app does use third-party services that may collect information used to identify you.\n\n'
                                                                                            ),
                                                                                            TextSpan(
                                                                                                text: 'Link to the privacy policy of third-party service providers used by the app\n\n'
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: ' \u2022 Google Play Services \n \u2022 AdMob\n\u2022 Google Analytics for Firebase\n\u2022 Firebase Crashlytics\n\u2022 Log Data \n\nWe want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.\n\n',
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Cookies\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third-party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Service Providers\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "We may employ third-party companies and individuals due to the following reasons:\n\nTo facilitate our Service;\nTo provide the Service on our behalf;\nTo perform Service-related services; or\nTo assist us in analyzing how our Service is used.\n\n\nWe want to inform users of this Service that these third parties have access to their Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Security\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Links to Other Sites\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Children’s Privacy\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13 years of age. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do the necessary actions.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Changes to This Privacy Policy\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'This policy is effective as of 2023-08-03\n\n',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Contact Us\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at appsilon3107@gmail.com.\n\n',
                                                                                            ),

                                                                                          ]
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ));
                                                      },
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    )),
                                                const TextSpan(
                                                  text: ' and ',
                                                ),
                                                TextSpan(
                                                    recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        showDialog(
                                                            context:
                                                            context,
                                                            barrierDismissible:
                                                            false,
                                                            builder:
                                                                (context) =>
                                                                Center(
                                                                  child:
                                                                  Container(
                                                                    height:
                                                                    size.height / 1.5,
                                                                    margin:
                                                                    EdgeInsets.symmetric(horizontal: 32.0),
                                                                    child:
                                                                    Card(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            InkWell(onTap: () {
                                                                              Navigator.of(context).pop();},child: Text('X',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                                                                            SizedBox(height: 10,),
                                                                            Container(
                                                                              width: double.maxFinite,
                                                                              height: (size.height /1.5)-80,
                                                                              color: Colors.grey.shade200,
                                                                              child: SingleChildScrollView(
                                                                                child: Container(
                                                                                  margin: EdgeInsets.all(12),
                                                                                  child: Flexible(
                                                                                    child: Text.rich(
                                                                                      TextSpan(
                                                                                          text: '\n',
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Terms & Conditions',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: '\n\nBy downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages or make derivative versions. The app itself, and all the trademarks, copyright, database rights, and other intellectual property rights related to it, still belong to Appsilon Inc..\n\n',

                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Appsilon Inc. is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.\n\n',

                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'The DigiAtt app stores and processes personal data that you have provided to us, to provide our Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the DigiAtt app won’t work properly or at all.\n\nThe app does use third-party services that declare their Terms and Conditions\n\nLink to Terms and Conditions of third-party service providers used by the app\n\n',

                                                                                            ),

                                                                                            TextSpan(
                                                                                              text: ' \u2022 Google Play Services \n \u2022 AdMob\n\u2022 Google Analytics for Firebase\n\u2022 Firebase Crashlytics \n\nYou should be aware that there are certain things that Appsilon Inc. will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi or provided by your mobile network provider, but Appsilon Inc. cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.\n\n',
                                                                                            ),

                                                                                            TextSpan(
                                                                                              text: "Along the same lines, Appsilon Inc. cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Appsilon Inc. cannot accept responsibility.\n\nWith respect to Appsilon Inc.’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavor to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Appsilon Inc. accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.\n\nAt some point, we may wish to update the app. The app is currently available on Android & iOS – the requirements for the both systems(and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Appsilon Inc. does not promise that it will always update the app so that it is relevant to you and/or works with the Android & iOS version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.\n\n",
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Changes to This Terms and Conditions\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: "We may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Terms and Conditions on this page.\n\n",
                                                                                            ),

                                                                                            TextSpan(
                                                                                              text: 'These terms and conditions are effective as of 2023-08-03\n\n',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'Contact Us\n\n',
                                                                                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: 'If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us at appsilon3107@gmail.com.\n\n',
                                                                                            ),

                                                                                          ]
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ));
                                                      },
                                                    text: 'Terms & Conditions',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (FormKey.currentState!
                                              .validate()) {
                                            if (termsAgreed) {
                                              Register();
                                            } else {
                                              snackbarKey.currentState!
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Please Accept The Terms.')));
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            textStyle: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                            elevation: 7,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        child: Text('Register'),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Already a User? ',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600)),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginScreen()));
                                          },
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future Register() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text.trim(), password: _password.text.trim())
          .then((value) {
        if (value != null) {
          value.user?.updateDisplayName(_name.text.trim());
          value.user?.updatePhotoURL("");
          value.user?.updateEmail(_email.text.trim());
        }
        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        final user = UserModel(
            name: _name.text.trim(),
            email: _email.text.trim(),
            photourl: "",
            role: role1,
            inGroup: []);
        final json = user.toJson();

        docRef.set(json).then((value) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          NavigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyEmailScreen()));
        });
      });
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.message!)));
      Navigator.of(context).pop();
    }
  }
}
