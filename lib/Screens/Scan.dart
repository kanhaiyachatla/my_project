import 'dart:async';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'AttendanceAuth.dart';

class Scan extends StatefulWidget {
  var attend_data;
  var userModel;
  var classModel;
  Scan(
      {Key? key,
      required this.attend_data,
      required this.userModel,
      required this.classModel})
      : super(key: key);

  @override
  State<Scan> createState() => _ScanState(attend_data, userModel, classModel);
}

class _ScanState extends State<Scan> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState __supportState = _SupportState.unknown;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  bool authenticated = false;

  final regions = <Region>[];
  late StreamSubscription _streamRanging;
  bool isScanning = false;
  var attend_data;
  var userModel;
  var classModel;

  _ScanState(this.attend_data, this.userModel, this.classModel);

  @override
  void initState() {
    Permission.bluetoothConnect.request().then((value) {
      if (value.isGranted) {
        flutterBeacon.initializeAndCheckScanning;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Attendance'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // flutter_beacon Package code

          (isScanning)
              ? GestureDetector(
                  onLongPress: () async {
                    // to stop ranging beacons
                    await _streamRanging.cancel();
                    setState(() {
                      isScanning = false;
                    });
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.asset('lib/assets/images/scan_pulse.json'),
                          const Icon(
                            Icons.bluetooth_connected,
                            size: 80,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      const Text(
                        'Long Press to Start/Stop Scanning...',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 18),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onLongPress: () async {
                    await Permission.bluetoothScan.request();
                    PermissionStatus statusScan =
                        await Permission.bluetoothScan.status;
                    if (Platform.isIOS) {
                      // iOS platform, at least set identifier and proximityUUID for region scanning
                      regions.add(Region(
                          identifier: 'Apple Airlocate',
                          proximityUUID:
                              'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
                      setState(() {
                        isScanning = true;
                      });
                    } else {
                      // Android platform, it can ranging out of beacon that filter all of Proximity UUID
                      regions.add(Region(identifier: 'com.beacon'));
                      setState(() {
                        isScanning = true;
                      });
                    }

// to start monitoring beacons
                    _streamRanging = flutterBeacon
                        .ranging(regions)
                        .listen((RangingResult result) {
                      print(result);
                      result.beacons.forEach((element) async {
                        var code = element.proximityUUID.split('-');
                        if (code.last == attend_data['id']) {
                          _streamRanging.cancel();
                          setState(() {
                            isScanning = false;
                          });

                          await authenticate();

                          if (authenticated) {
                            var reference = await FirebaseFirestore.instance
                                .collection('Classes')
                                .doc(classModel['id'])
                                .collection('Attendance')
                                .doc(attend_data['id'].toString());

                            reference
                                .collection('Lists')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'Present': true,
                            }).then((value) {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AttendanceAuth()));
                            });
                          }
                        }
                      });
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 2.1,
                          child: const Icon(
                            Icons.bluetooth_disabled,
                            size: 80,
                            color: Colors.grey,
                          )),
                      const Text(
                        'Long Press to Start/Stop Scanning...',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
//

          const Text(
              '- Make sure your Location and Bluetooth is on. \n - Check if your Attendance details are correct')
        ],
      ),
    );
  }

  Future authenticate() async {
    try {
      setState(() {
        isAuthenticating = true;
        authorized = 'Authenticating';
      });

      authenticated = await auth.authenticate(
          localizedReason: 'Verify fingerprint',
          options: const AuthenticationOptions(
            stickyAuth: true,
            useErrorDialogs: true,
            biometricOnly: true,
          ));
    } on PlatformException catch (e) {
      print(e.message);
      setState(() {
        isAuthenticating = false;
        authorized = 'Error : ' + e.message!;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
