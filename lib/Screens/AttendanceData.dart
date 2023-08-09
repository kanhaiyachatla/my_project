import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

import '../main.dart';
import 'ShowAttendance.dart';

class AttendanceData extends StatefulWidget {
  var classModel;
  AttendanceData({Key? key, required this.classModel}) : super(key: key);

  @override
  State<AttendanceData> createState() => _AttendanceDataState(classModel);
}

class _AttendanceDataState extends State<AttendanceData> {
  DateTimeRange SelectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  DateTime SelectedDate = DateTime.now();
  TimeOfDay SelectedTime = TimeOfDay.now();
  var classModel;
  late DateTime firstDate, lastDate;
  final subLists = ['All Subjects'];
  final subLists1 = [];
  final FormKey = GlobalKey<FormState>();
  final FormKey1 = GlobalKey<FormState>();
  var subject;
  bool isClicked = false;

  _AttendanceDataState(this.classModel);

  @override
  void initState() {
    getDates();
    for (int i = 0; i < classModel['subjects'].length; i++) {
      subLists.add(classModel['subjects'][i]);
      subLists1.add(classModel['subjects'][i]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 16.0, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Monthly Attendance Data',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 32.0, right: 32.0),
                      child: Text(
                        'Select Subject',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Form(
                      key: FormKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: DropdownButtonFormField(
                          validator: (value) =>
                              (value == null) ? 'Please Select Subject' : null,
                          hint: const Text('Select Subjects'),
                          isExpanded: true,
                          value: subject,
                          items: subLists
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              subject = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 8.0),
                      child: Text(
                        'Select Date Range',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final DateTimeRange? dateTimeRange =
                              await showDateRangePicker(
                                  context: context,
                                  firstDate: firstDate,
                                  lastDate: lastDate);
                          if (dateTimeRange != null) {
                            setState(() {
                              SelectedDates = dateTimeRange;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(
                                  0.0,
                                  2.0,
                                ),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month),
                                Text(
                                  '    ${DateFormat('d / MMM / yyyy').format(SelectedDates.start)}   -   ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  '${DateFormat('d / MMM / yyyy').format(SelectedDates.end)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: ElevatedButton(
                                onPressed: (isClicked)
                                    ? null
                                    : () async {
                                        if (FormKey.currentState!.validate()) {
                                          setState(() {
                                            isClicked = true;
                                          });
                                          var Docref = FirebaseFirestore
                                              .instance
                                              .collection('Classes')
                                              .doc(classModel['id'])
                                              .collection('Attendance');
                                          var snapshots =
                                              await FirebaseFirestore.instance
                                                  .collection('Classes')
                                                  .doc(classModel['id'])
                                                  .collection('Attendance')
                                                  .where('subject',
                                                      isEqualTo: subject)
                                                  .where('datetime',
                                                      isGreaterThanOrEqualTo:
                                                          SelectedDates.start)
                                                  .where('datetime',
                                                      isLessThanOrEqualTo:
                                                          SelectedDates.end.add(
                                                              const Duration(
                                                                  days: 1)))
                                                  .get();
                                          if (snapshots.docs.isNotEmpty) {
                                            final excel.Workbook workbook =
                                                excel.Workbook();
                                            final excel.Worksheet sheet =
                                                workbook.worksheets[0];

                                            sheet
                                                .getRangeByName('C1')
                                                .setText('Subject : ');
                                            sheet
                                                .getRangeByName('D1')
                                                .setText('${subject}');
                                            sheet
                                                .getRangeByName('C2')
                                                .setText('Date : ');
                                            sheet.getRangeByName('D2').setText(
                                                '${DateFormat('d MMM yyyy').format(SelectedDates.start)} - ${DateFormat('d MMM yyyy').format(SelectedDates.end)}');
                                            sheet
                                                .getRangeByName('A5')
                                                .setText('Sr.No');
                                            sheet
                                                .getRangeByName('B5')
                                                .setText('Student Name');
                                            sheet
                                                .getRangeByName('C5')
                                                .setText('Email');
                                            sheet.getRangeByName('D5').setText(
                                                DateFormat(
                                                        'd MMM yyyy , h:mm a')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            snapshots.docs[0]
                                                                    .data()[
                                                                'timestamp'])));
                                            final excel.Range range =
                                                sheet.getRangeByName('A5:D5');
                                            range.cellStyle.backColor =
                                                '#b7b5b5';

                                            int rows = 6;

                                            await Docref.doc(snapshots.docs[0]
                                                    .data()['id'])
                                                .collection('Lists')
                                                .get()
                                                .then((element) {
                                              for (int i = 0;
                                                  i < element.docs.length;
                                                  i++) {
                                                var data =
                                                    element.docs[i].data();
                                                sheet
                                                    .getRangeByName('A${6 + i}')
                                                    .setNumber(i + 1);
                                                sheet
                                                    .getRangeByName('B${6 + i}')
                                                    .setText(data['name']);
                                                sheet
                                                    .getRangeByName('C${6 + i}')
                                                    .setText(data['email']);
                                                if (data['Present']) {
                                                  sheet
                                                      .getRangeByName(
                                                          'D${i + 6}')
                                                      .cellStyle
                                                      .backColor = '#98eb00';
                                                  sheet
                                                      .getRangeByName(
                                                          'D${i + 6}')
                                                      .setText('Present');
                                                } else {
                                                  sheet
                                                      .getRangeByName(
                                                          'D${i + 6}')
                                                      .cellStyle
                                                      .backColor = '#ff4f58';
                                                  sheet
                                                      .getRangeByName(
                                                          'D${i + 6}')
                                                      .setText('Absent');
                                                }
                                                rows++;
                                              }
                                            });
                                            sheet.autoFitColumn(3);
                                            sheet.autoFitColumn(2);
                                            sheet.autoFitColumn(4);
                                            int count = 5;

                                            for (int i = 1;
                                                i < snapshots.docs.length;
                                                i++) {
                                              sheet
                                                  .getRangeByIndex(5, i + 4)
                                                  .cellStyle
                                                  .backColor = '#b7b5b5';
                                              sheet
                                                  .getRangeByIndex(5, i + 4)
                                                  .setText(DateFormat(
                                                          'd MMM yyyy , h:mm a')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              snapshots.docs[i]
                                                                      .data()[
                                                                  'timestamp'])));
                                              await Docref.doc(snapshots.docs[i]
                                                      .data()['id'])
                                                  .collection('Lists')
                                                  .get()
                                                  .then((element) {
                                                for (int j = 0;
                                                    j < element.docs.length;
                                                    j++) {
                                                  var data =
                                                      element.docs[j].data();
                                                  if (data['Present']) {
                                                    sheet
                                                        .getRangeByIndex(
                                                            j + 6, i + 4)
                                                        .cellStyle
                                                        .backColor = '#98eb00';
                                                    sheet
                                                        .getRangeByIndex(
                                                            j + 6, i + 4)
                                                        .setText('Present');
                                                  } else {
                                                    sheet
                                                        .getRangeByIndex(
                                                            j + 6, i + 4)
                                                        .cellStyle
                                                        .backColor = '#ff4f58';
                                                    sheet
                                                        .getRangeByIndex(
                                                            j + 6, i + 4)
                                                        .setText('Absent');
                                                  }
                                                }
                                                count++;
                                              });
                                              sheet.autoFitColumn(i + 4);
                                            }

                                            sheet
                                                .getRangeByIndex(5, count)
                                                .cellStyle
                                                .backColor = '#b7b5b5';
                                            sheet
                                                    .getRangeByIndex(5, count)
                                                    .cellStyle
                                                    .hAlign =
                                                excel.HAlignType.center;
                                            sheet
                                                .getRangeByIndex(5, count)
                                                .setText('Total Present');
                                            sheet
                                                .getRangeByIndex(5, count + 1)
                                                .cellStyle
                                                .backColor = '#b7b5b5';
                                            sheet
                                                .getRangeByIndex(5, count + 1)
                                                .cellStyle
                                                .hAlign = excel.HAlignType.center;
                                            sheet
                                                .getRangeByIndex(5, count + 1)
                                                .setText('Total Absent');
                                            sheet
                                                .getRangeByIndex(5, count + 2)
                                                .cellStyle
                                                .backColor = '#b7b5b5';
                                            sheet
                                                .getRangeByIndex(5, count + 2)
                                                .cellStyle
                                                .hAlign = excel.HAlignType.center;
                                            sheet
                                                .getRangeByIndex(5, count + 2)
                                                .setText('Total Lectures');
                                            sheet
                                                .getRangeByIndex(5, count + 3)
                                                .cellStyle
                                                .backColor = '#b7b5b5';
                                            sheet
                                                .getRangeByIndex(5, count + 3)
                                                .cellStyle
                                                .hAlign = excel.HAlignType.center;
                                            sheet
                                                .getRangeByIndex(5, count + 3)
                                                .setText('Defaulters');
                                            for (int i = 6; i < rows; i++) {
                                              int presentCount = 0;
                                              int absentCount = 0;
                                              for (int j = 4; j < count; j++) {
                                                if (sheet
                                                        .getRangeByIndex(i, j)
                                                        .displayText ==
                                                    'Present') {
                                                  presentCount++;
                                                } else {
                                                  absentCount++;
                                                }
                                              }

                                              sheet
                                                      .getRangeByIndex(i, count)
                                                      .cellStyle
                                                      .hAlign =
                                                  excel.HAlignType.center;
                                              sheet
                                                  .getRangeByIndex(i, count)
                                                  .setValue(presentCount);
                                              sheet
                                                  .getRangeByIndex(i, count + 1)
                                                  .cellStyle
                                                  .hAlign = excel.HAlignType.center;
                                              sheet
                                                  .getRangeByIndex(i, count + 1)
                                                  .setValue(absentCount);
                                              sheet
                                                  .getRangeByIndex(i, count + 2)
                                                  .cellStyle
                                                  .hAlign = excel.HAlignType.center;
                                              sheet
                                                  .getRangeByIndex(i, count + 2)
                                                  .setValue(presentCount +
                                                      absentCount);
                                              sheet
                                                  .getRangeByIndex(i, count + 3)
                                                  .cellStyle
                                                  .hAlign = excel.HAlignType.center;
                                              sheet
                                                  .getRangeByIndex(i, count + 3)
                                                  .setValue(((presentCount /
                                                                  (presentCount +
                                                                      absentCount)) *
                                                              100)
                                                          .toString() +
                                                      ' %');
                                            }
                                            sheet.autoFitColumn(count);
                                            sheet.autoFitColumn(count + 1);
                                            sheet.autoFitColumn(count + 2);
                                            sheet.autoFitColumn(count + 3);

                                            final List<int> bytes =
                                                workbook.saveSync();
                                            workbook.dispose();

                                            await Permission.storage.request();
                                            PermissionStatus status =
                                                await Permission.storage.status;
                                            if (status ==
                                                PermissionStatus.granted) {
                                              print(status);
                                            } else {
                                              await Permission.storage
                                                  .request();
                                            }

                                            final directory =
                                                await getExternalStorageDirectory();
                                            final path = directory?.path;
                                            print(path);
                                            final String fileName =
                                                '${path}/${subject}-${DateFormat('d MMM yyyy-h:mm a').format(DateTime.now())}.xlsx';
                                            final File file = File(fileName);
                                            await file.writeAsBytes(bytes,
                                                flush: true);
                                            OpenAppFile.open(fileName);
                                            setState(() {
                                              isClicked = false;
                                            });
                                          } else {
                                            setState(() {
                                              isClicked = false;
                                            });
                                            snackbarKey.currentState!
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'No Attendance Record found for given parameters')));
                                          }
                                        }
                                      },
                                child: (isClicked)
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Text('Get Attendance Data')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 16.0, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                        child: Text(
                      'Daily Attendance Data',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    )),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 32.0, right: 32.0),
                      child: Text(
                        'Select Subject',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Form(
                      key: FormKey1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: DropdownButtonFormField(
                          validator: (value) =>
                              (value == null) ? 'Please Select Subject' : null,
                          hint: const Text('Select Subjects'),
                          isExpanded: true,
                          value: subject,
                          items: subLists1
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              subject = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 8.0),
                      child: Text(
                        'Select Date and Time',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: firstDate,
                              initialDatePickerMode: DatePickerMode.day,
                              firstDate: firstDate,
                              lastDate: lastDate);
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: SelectedTime,
                          );
                          if (picked != null && pickedTime != null) {
                            setState(() {
                              SelectedDate = picked;
                              SelectedTime = pickedTime;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(
                                  0.0,
                                  2.0,
                                ),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month),
                                Text(
                                  '    ${DateFormat('d / MMM / yyyy').format(SelectedDate)}   -   ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  '${SelectedTime.format(context)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: () async{
                            var attend_id = (DateTime(SelectedDate.year,SelectedDate.month,SelectedDate.day,SelectedTime.hour,SelectedTime.minute).millisecondsSinceEpoch / 10).toInt();
                            var attend_data = await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').doc(attend_id.toString()).get();
                            if(attend_data.exists) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowAttendance(attend_data: attend_data.data(), classModel: classModel)));
                            }else{
                              snackbarKey.currentState!.showSnackBar(const SnackBar(content: Text('Attendance Record Not Found')));
                            }
                          }, child: const Text('Get Attendance Data'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDates() async {
    var stream = await FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Attendance')
        .orderBy('timestamp')
        .snapshots()
        .first;
    setState(() {
      firstDate = DateTime.fromMillisecondsSinceEpoch(
          stream.docs[0].data()['timestamp']);
      lastDate = DateTime.fromMillisecondsSinceEpoch(
          stream.docs[stream.docs.length - 1].data()['timestamp']);
    });
  }
}
