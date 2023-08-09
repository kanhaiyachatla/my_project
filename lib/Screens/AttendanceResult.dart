import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class AttendanceResult extends StatefulWidget {
  var attend_data;
  var classModel;
  AttendanceResult(
      {Key? key, required this.attend_data, required this.classModel})
      : super(key: key);

  @override
  State<AttendanceResult> createState() =>
      _AttendanceResultState(attend_data, classModel);
}

class _AttendanceResultState extends State<AttendanceResult> {
  var attend_data, classModel;
  _AttendanceResultState(this.attend_data, this.classModel);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Data'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .doc(classModel['id'])
              .collection('Attendance')
              .doc(attend_data['id'])
              .collection('Lists')
              .snapshots(),
          builder: (context, snapshots) {
            return snapshots.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      const ListTile(
                        title: Text('Name of Student'),
                        trailing: Text('Present'),
                        titleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16),
                        leadingAndTrailingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.6),
                      ),
                      SizedBox(
                        height: size.height * 0.75,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              var data = snapshots.data!.docs[index].data()
                                  as Map<String, dynamic>;

                              return InkWell(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Classes')
                                      .doc(classModel['id'])
                                      .collection('Attendance')
                                      .doc(attend_data['id'])
                                      .collection('Lists')
                                      .doc(data['id'])
                                      .update({
                                    'Present': !data['Present'],
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    data['name'],
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(data['email']),
                                  trailing: Checkbox(
                                    value: data['Present'],
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                    onChanged: (bool? value) async {
                                      await FirebaseFirestore.instance
                                          .collection('Classes')
                                          .doc(classModel['id'])
                                          .collection('Attendance')
                                          .doc(attend_data['id'])
                                          .collection('Lists')
                                          .doc(data['id'])
                                          .update({
                                        'Present': !data['Present'],
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(),
                            itemCount: snapshots.data!.docs.length),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  margin: const EdgeInsets.only(left: 20, right: 20),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        createExcel();
                                      },
                                      // onPressed: () async {
                                      //   var metadata = await FirebaseFirestore
                                      //       .instance
                                      //       .collection('Classes')
                                      //       .doc(classModel['id'])
                                      //       .collection('Attendance')
                                      //       .doc(attend_data['id'])
                                      //       .get();
                                      //   var datetime =
                                      //       DateTime.fromMillisecondsSinceEpoch(
                                      //           metadata['timestamp']);
                                      //   List<List<String>> res_data = [
                                      //     [],
                                      //     ['Subject', '${metadata['subject']}'],
                                      //     [
                                      //       'Date',
                                      //       '${DateFormat.yMd().format(datetime)}'
                                      //     ],
                                      //     [
                                      //       'Time',
                                      //       '${DateFormat.jm().format(datetime)}'
                                      //     ],
                                      //     [],
                                      //     [],
                                      //     [
                                      //       'Sr. No.',
                                      //       'Name',
                                      //       'Email',
                                      //       'Attendance'
                                      //     ]
                                      //   ];
                                      //   var count = 1;
                                      //   for (int i = 0;
                                      //       i < snapshots.data!.docs.length;
                                      //       i++) {
                                      //     var data = snapshots.data!.docs[i]
                                      //         .data() as Map<String, dynamic>;
                                      //
                                      //     if (data['Present']) {
                                      //       List<String> list = [
                                      //         count.toString(),
                                      //         data['name'],
                                      //         data['email'],
                                      //         'Present'
                                      //       ];
                                      //       res_data.add(list);
                                      //       count++;
                                      //     } else {
                                      //       List<String> list = [
                                      //         count.toString(),
                                      //         data['name'],
                                      //         data['email'],
                                      //         'Absent'
                                      //       ];
                                      //       res_data.add(list);
                                      //       count++;
                                      //     }
                                      //   }
                                      //   String filename =
                                      //       'Attendance_Data_${metadata['subject']}_${DateFormat.yMd().format(datetime)}_${DateFormat.jm().format(datetime)}';
                                      //   List<String> header = [
                                      //     'Sr. No.',
                                      //     'Name',
                                      //     'Email',
                                      //     'Attendance'
                                      //   ];
                                      //   exportCSV.myCSV(header, res_data);
                                      //   // exportCSV.myCSV(header, res_data,'Attendance_Data_${metadata['subject']}_${DateFormat.yMd().format(datetime)}_${DateFormat.jm().format(datetime)}');
                                      // },
                                      child: const Text('Download CSV')))),
                        ],
                      )
                    ],
                  );
          }),
    );
  }
  createExcel() async {
    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];



    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes,flush: true);
    OpenAppFile.open(fileName);
  }
}
