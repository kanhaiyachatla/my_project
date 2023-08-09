import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart' as Broadcast;
import 'package:digiatt/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../methods/UserModel.dart';
import '../AttendanceData.dart';
import '../ShowAttendance.dart';
import '../TakeAttendance.dart';
import 'AttendanceScreen.dart';

class BodyClassHomeScreen extends StatefulWidget {
  var classModel;
  var userModel;

  BodyClassHomeScreen(
      {Key? key, required this.classModel, required this.userModel})
      : super(key: key);

  @override
  State<BodyClassHomeScreen> createState() =>
      _BodyClassHomeScreenState(classModel, userModel);
}

class _BodyClassHomeScreenState extends State<BodyClassHomeScreen> {
  var classModel;
  var userModel;
  var user = FirebaseAuth.instance.currentUser!;
  final FormKey = GlobalKey<FormState>();

  //attendance get
  late final int presentPercent;
  late final int absentPercent;
  int totalCount = 0;

  //auth
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState __supportState = _SupportState.unknown;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  bool authenticated = false;
  late TooltipBehavior _tooltipBehavior;
  var timestamp;
  bool isClicked = false;
  bool isLoading = true;

  //Teacher VAriables
  final last5AttendData = [];

  //STudent VAriables
  final subLists = [];
  DateTime Date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  var initialvalue;
  late List<AttData> attendanceData;

  _BodyClassHomeScreenState(this.classModel, this.userModel);

  @override
  void initState() {
    if (userModel.role == 'student') {
      getData();
      _tooltipBehavior = TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text(
                  data.Label,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            );
          });
    } else {
      getTeacherData();
    }
    for (int i = 0; i < classModel['subjects'].length; i++) {
      subLists.add(classModel['subjects'][i]);
    }

    auth.isDeviceSupported().then((bool isSupported) => setState(() =>
        __supportState =
            isSupported ? _SupportState.supported : _SupportState.unsupported));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        floatingActionButton: (userModel.role == 'teacher')
            ? null
            : FloatingActionButton.extended(
                heroTag: 'ClassHomeScreenButton',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TakeAttendance(
                              classModel: classModel, userModel: userModel)));
                },
                label: Text('Mark attendance'),
              ),
        body: (userModel.role == 'teacher')
            ? (isLoading) ? Center(child: CircularProgressIndicator(),):SingleChildScrollView(
              child: Container(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                    child: Column(
                      children: [
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Take Attendance',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Divider(
                                  thickness: 1.5,
                                ),
                                Form(
                                  key: FormKey,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0),
                                    child: DropdownButtonFormField(
                                      validator: (value) => (value == null)
                                          ? 'Please Select Subject'
                                          : null,
                                      hint: Text('Select Subjects'),
                                      isExpanded: true,
                                      value: initialvalue,
                                      items: subLists
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          initialvalue = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Date : ${DateFormat('d MMM yyyy').format(Date)}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(),
                                    IconButton(
                                      onPressed: () async {
                                        DateTime? newDate = await showDatePicker(
                                          context: context,
                                          initialDate: Date,
                                          firstDate: DateTime(1999),
                                          lastDate: DateTime(2300),
                                        );

                                        if (newDate == null) return;

                                        setState(() {
                                          Date = newDate;
                                        });
                                      },
                                      icon: Icon(Icons.date_range_rounded),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Time : ${time.format(context)}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        TimeOfDay? newTime = await showTimePicker(
                                          context: context,
                                          initialTime: time,
                                        );
                                        if (newTime == null) return;

                                        setState(() {
                                          time = newTime;
                                        });
                                      },
                                      icon: Icon(Icons.access_time),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.1,
                                ),
                                Container(
                                  child: __supportState == _SupportState.supported
                                      ? ElevatedButton(
                                          onPressed: (isClicked) ? null :() async {
                                            if (FormKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                isClicked = true;
                                              });
                                              timestamp = DateTime(
                                                      Date.year,
                                                      Date.month,
                                                      Date.day,
                                                      time.hour,
                                                      time.minute)
                                                  .millisecondsSinceEpoch;
                                              var attend_id = (DateTime(
                                                              Date.year,
                                                              Date.month,
                                                              Date.day,
                                                              time.hour,
                                                              time.minute)
                                                          .millisecondsSinceEpoch /
                                                      10)
                                                  .toInt()
                                                  .toString();
                                              var map = {
                                                'subject': initialvalue,
                                                'datetime' : DateTime.fromMillisecondsSinceEpoch(timestamp),
                                                'timestamp': timestamp,
                                                'id': attend_id,
                                              };
                                              var reference =
                                                  await FirebaseFirestore.instance
                                                      .collection('Classes')
                                                      .doc(classModel['id'])
                                                      .collection('Attendance')
                                                      .doc(attend_id);
                                              await reference.set(map);

                                              await FirebaseFirestore.instance
                                                  .collection('Classes')
                                                  .doc(classModel['id'])
                                                  .collection('members')
                                                  .where('role',
                                                      isEqualTo: 'student')
                                                  .get()
                                                  .then((querySnapshot) async {
                                                var ref =
                                                    reference.collection('Lists');
                                                for (var docSnapshot
                                                    in querySnapshot.docs) {
                                                  await ref.doc(docSnapshot.id);
                                                  await ref
                                                      .doc(docSnapshot.id)
                                                      .set({
                                                    'Present': false,
                                                    'id': docSnapshot.id,
                                                    'name': docSnapshot
                                                        .data()['name'],
                                                    'email': docSnapshot
                                                        .data()['email'],
                                                    'photourl': docSnapshot
                                                        .data()['photourl']
                                                  });
                                                  print(
                                                      '${docSnapshot.id} => ${docSnapshot.data()}');
                                                }
                                              });

                                              Broadcast.BeaconStatus status =
                                                  await checkStatus();
                                              if (status ==
                                                  Broadcast
                                                      .BeaconStatus.supported) {
                                                setState(() {
                                                  isClicked = false;
                                                });
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AttendanceScreen(
                                                              attend_data: map,
                                                              userModel:
                                                                  userModel,
                                                              ClassModel:
                                                                  classModel,
                                                            )));
                                              }
                                              setState(() {
                                                isClicked = false;
                                              });
                                            }
                                          },
                                          child: (isClicked) ? Container(width: 20,height: 20,child: CircularProgressIndicator()):Text('Take Attendance'),)
                                      : Text('not supported'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Attendance History',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Divider(
                                  thickness: 2,
                                ),
                               Container(
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.only(bottomRight: Radius.circular(12),bottomLeft: Radius.circular(12)),
                                   color: Colors.grey.shade200,
                                 ),
                                 margin: EdgeInsets.symmetric(horizontal: 16),

                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: ListView.builder(shrinkWrap: true,reverse: true,physics:NeverScrollableScrollPhysics(),itemCount: last5AttendData.length,itemBuilder: (context,index) {
                                     return Card(
                                         child: ListTile(
                                           onTap: () {
                                             Navigator.push(context, MaterialPageRoute(builder: (context) => ShowAttendance(attend_data: last5AttendData[index], classModel: classModel)));
                                           },
                                           title: Text(last5AttendData[index]['subject'], style: TextStyle(fontWeight: FontWeight.bold),),
                                           subtitle: Text('Date : '+DateFormat('d MMM yyyy, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(last5AttendData[index]['timestamp']))),
                                         ),
                                     );
                                   }),
                                 ),
                               ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AttendanceData(classModel: classModel,)));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16,top: 6,),
                                    child: Align(alignment: Alignment.bottomRight,child: Text('Show More',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,decoration: TextDecoration.underline),)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            )
            : (isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : (attendanceData.isEmpty)
                    ? Center(
                        child: Text('No Attendance data'),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8),
                          child: Column(
                            children: [
                              Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16.0, left: 8.0, right: 8.0),
                                  child: Column(
                                    children: [
                                      SfCircularChart(
                                        legend: Legend(isVisible: true),
                                        title: ChartTitle(
                                            text: 'Your Overall Attendance',
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        tooltipBehavior: _tooltipBehavior,
                                        palette: [
                                          Colors.green.shade400,
                                          Colors.red.shade400
                                        ],
                                        series: <CircularSeries>[
                                          PieSeries<AttData, String>(
                                            radius: '90%',
                                            dataSource: attendanceData,
                                            xValueMapper: (AttData data, _) =>
                                                data.status,
                                            yValueMapper: (AttData data, _) =>
                                                data.count,
                                            dataLabelMapper:
                                                (AttData data, _) =>
                                                    '${data.count}%',
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true,
                                                    showZeroValue: false,
                                                    textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                            enableTooltip: true,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 9,
                                      ),
                                      Text(
                                        'Total Lectures : ${totalCount}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
  }

  Future<Broadcast.BeaconStatus> checkStatus() async {
    Broadcast.BeaconStatus transmissionSupportStatus =
        await Broadcast.BeaconBroadcast().checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case Broadcast.BeaconStatus.supported:
        print("You're good to go, you can advertise as a beacon");
        break;
      case Broadcast.BeaconStatus.notSupportedMinSdk:
        snackbarKey.currentState!.showSnackBar(SnackBar(
            content:
                Text("Your Android system version is too low (min. is 21)")));
        break;
      case Broadcast.BeaconStatus.notSupportedBle:
        snackbarKey.currentState!.showSnackBar(
            SnackBar(content: Text('Your device doesnt support BLE')));
        break;
      case Broadcast.BeaconStatus.notSupportedCannotGetAdvertiser:
        snackbarKey.currentState!.showSnackBar(SnackBar(
            content: Text('Either your chipset or driver is incompatible')));
        break;
    }
    return transmissionSupportStatus;
  }

  Future<UserModel?> ReadUser() async {
    final Docid = FirebaseFirestore.instance.collection("Users").doc(user.uid);
    final snapshot = await Docid.get();

    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
  }

  List<AttData> getChartData(
      final presentval, final absentval, int presentCount, int absentCount) {
    final List<AttData> chartData = [
      AttData('Present', presentval, 'Present Lectures : ${presentCount}'),
      AttData('Absent', absentval, 'Absent Lectures : ${absentCount}')
    ];
    return chartData;
  }

  Future<void> getData() async {
    int presentCount = 0;
    int absentCount = 0;
    await FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Attendance')
        .snapshots()
        .forEach((element) async {
      if (element.size == 0) {
        print('no attendance data');
        attendanceData = [];
      } else {
        for (int i = 0; i < element.size; i++) {
          print(element.docs[i]['id']);
          var value = await FirebaseFirestore.instance
              .collection('Classes')
              .doc(classModel['id'])
              .collection('Attendance')
              .doc(element.docs[i]['id'])
              .collection('Lists')
              .doc(user.uid)
              .get();
          print(value.data()?['Present']);

          if (value.data()?['Present']) {
            presentCount++;
            totalCount++;
          } else {
            absentCount++;
            totalCount++;
          }
        }
        presentPercent = ((presentCount / totalCount) * 100).truncate();
        absentPercent = ((absentCount / totalCount) * 100).truncate();
        attendanceData = getChartData(
            presentPercent, absentPercent, presentCount, absentCount);
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getTeacherData() async {

    await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').orderBy('timestamp').limit(5).get().then((element) {
      for(int i=0;i< element.size;i++) {
        var data = element.docs[i].data();
        last5AttendData.add(data);
      }
    });
    setState(() {
      isLoading = false;
    });
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AttData {
  AttData(this.status, this.count, this.Label);
  final String status;
  final int count;
  final String Label;
}
