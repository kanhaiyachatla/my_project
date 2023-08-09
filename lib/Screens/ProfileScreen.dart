import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../methods/UserModel.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  final user1 = FirebaseAuth.instance.currentUser!;
  final _name = TextEditingController();
  var Urldownload = '';
  XFile? ImageFile;
  ImagePicker imagePicker = ImagePicker();
  // var _email = TextEditingController();
  bool editingEnabled = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded), onPressed: () {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => HomeScreen()));
          },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (editingEnabled) {
                    updateProfile(_name.text.trim());
                  }

                  setState(() {
                    editingEnabled = !editingEnabled;
                  });
                },
                icon: Icon(editingEnabled ? Icons.check : Icons.edit))
          ],

          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0.0,
          title: const Text(
            'Profile'
          ),
        ),
        body: FutureBuilder<UserModel?>(
          future: ReadUser(),
          builder: (context, snap) {
            if (snap.hasError) {
              snackbarKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Something went wrong')));
            } else if (snap.hasData) {
              final user = snap.data;

              return user == null
                  ? const Center(
                      child: Text('No user'),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: double.infinity,

                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: size.height / 6,
                              ),
                              Center(
                                child: CircleAvatar(
                                  radius: size.height * 0.12,
                                  backgroundColor: Colors.grey,

                                  child: editingEnabled
                                      ? CircleAvatar(
                                          radius: size.height * 0.11,

                                          backgroundColor: Colors.black.withOpacity(0.2),
                                          backgroundImage: ImageFile == null
                                              ? null
                                              : FileImage(
                                                  File(ImageFile!.path)),
                                          child: ImageFile == null ? Icon(Icons.person,color: Colors.grey.shade500,size: 100,) :null,
                                        )
                                      : CircleAvatar(
                                          radius: size.height * 0.11,
                                          backgroundColor: user.photourl == '' ? Colors.grey.shade300 : null,
                                          backgroundImage: user.photourl == ''
                                              ? null
                                              : NetworkImage(user.photourl),
                                          child: user.photourl == '' ? Icon(Icons.person,color: Colors.grey.shade500,size: 100,) : null,
                                        ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Container(
                                    child: editingEnabled
                                        ? ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 5,
                                              shadowColor: Colors.grey.shade900
                                            ),
                                            onPressed: () {
                                              getImagefromGallery();
                                            },
                                            icon: const Icon(Icons.upload),
                                            label: const Text('Upload Image'),
                                          )
                                        : null),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Container(
                                child: Card(
                                  elevation:10,
                                  shadowColor: Colors.grey.shade900,
                                  margin: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 24,
                                        right: 24,
                                        top: 24,
                                        bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          'Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          enabled: editingEnabled,
                                          controller: _name,
                                          decoration: InputDecoration(
                                              hintText: user.name,
                                              focusColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary)),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                color: Colors.grey,
                                              )),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey))),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Email',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                              hintText: user.email,
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary)),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                color: Colors.grey,
                                              )),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey))),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: editingEnabled
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      editingEnabled = false;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  child: const Text('Cancel'),
                                                )
                                              : ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    elevation: 5,
                                                  ),
                                                  onPressed: () {
                                                    FirebaseAuth.instance.signOut();
                                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));

                                                  }
                                                  ,
                                                  icon: const Icon(
                                                    Icons.exit_to_app,
                                                    color: Colors.white,
                                                  ),
                                                  label: const Text(
                                                    'Log Out',
                                                    style: TextStyle(fontSize: 18,color: Colors.white)
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ),
                              Align(alignment: Alignment.center,
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(onPressed: (){
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
                                  }, child:const Text('Privacy & Policy')),
                                  const Text('•',style:TextStyle(fontSize: 20)),

                                  TextButton(onPressed: (){
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
                                  }, child: const Text('Terms & Condition')),
                                ],
                              ),
                              ),
                          ]
                        ),
                        ),

                      ),
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  Future updateProfile(String name) async {
    await uploadFile();

    try {
      if (name.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user1.uid)
            .update({'name': name});
        await user1.updateDisplayName(name);
      }
      if (Urldownload != '') {
        
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user1.uid)
            .update({'photourl': Urldownload}).then((value) => user1.updatePhotoURL(Urldownload));
        setState(() {

        });
      }
    } on Exception catch (e) {
      snackbarKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    Navigator.of(context).pop();
    snackbarKey.currentState!
        .showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  uploadFile() async {
    showDialog(
        context: NavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    if (ImageFile == null) {
      Urldownload = '';
    } else {
      final path = 'userImages/${user1.uid}/profile.png';
      final file = File(ImageFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);

      UploadTask? uploadtask = ref.putFile(file);
      final snapshot = await uploadtask!.whenComplete(() => {});

      Urldownload = await snapshot.ref.getDownloadURL();
    }
  }

  getImagefromGallery() async {
    ImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 40,);

    setState(() {
      ImageFile;
    });
  }

  Future<UserModel?> ReadUser() async {
    final Docid = FirebaseFirestore.instance.collection("Users").doc(user1.uid);
    final snapshot = await Docid.get();

    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
  }
}
