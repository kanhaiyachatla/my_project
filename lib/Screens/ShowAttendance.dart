import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class ShowAttendance extends StatefulWidget {
  var attend_data;
  var classModel;
  ShowAttendance({Key? key, required this.attend_data, required this.classModel}) : super(key: key);

  @override
  State<ShowAttendance> createState() => _ShowAttendanceState(attend_data,classModel);
}

class _ShowAttendanceState extends State<ShowAttendance> {
  var attend_data;
  var classModel;
  _ShowAttendanceState(this.attend_data, this.classModel);

  late List<AttData> attendanceData;
  late TooltipBehavior _tooltipBehavior;

  bool isLoading = true;
  int totalCount = 0;
  int presentPercent = 0;
  int absentPercent = 0;

  @override
  void initState() {
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
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          );
        });
    super.initState();
  }

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
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            SfCircularChart(
                              legend: Legend(isVisible: true),
                              title: ChartTitle(
                                  text: 'Subject : ${attend_data['subject']}\n ${DateFormat('d MMM yyyy, h.mm a').format(DateTime.fromMillisecondsSinceEpoch(attend_data['timestamp']))}',
                                  textStyle:  const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              tooltipBehavior: _tooltipBehavior,
                              palette: const [Colors.green,Colors.red],
                              series: <CircularSeries>[
                                PieSeries<AttData, String>(
                                  dataSource: attendanceData,
                                  xValueMapper: (AttData data, _) => data.status,
                                  yValueMapper: (AttData data,_) => data.count,
                                  dataLabelMapper:
                                      (AttData data, _) =>
                                  '${data.count}%',
                                  dataLabelSettings:
                                   const DataLabelSettings(
                                      isVisible: true,
                                      showZeroValue: false,
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                  enableTooltip: true,
                                )
                              ],
                            ),
                            Padding(
                              padding:  const EdgeInsets.only(bottom: 20.0),
                              child: Text('Total Students : ${totalCount}',style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),),
                            )

                          ],
                        ),
                      ),
                      Card(
                        child: Column(
              children: [

                        const ListTile(
                          title: Text('Name of Student', style: TextStyle(
                            fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18),
                          ),

                          trailing: Text('Present', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18),
                          ),


                        ),
                        Divider(color: Colors.black.withOpacity(0.6),),
                        Container(
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var data = snapshots.data!.docs[index].data()
                                as Map<String, dynamic>;



                                return ListTile(
                                  title: Text(
                                    data['name'],
                                    style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(data['email']),
                                  trailing: (data['Present']) ? const Icon(Icons.check_circle_outline_outlined, color: Colors.green,): const Icon(Icons.cancel_outlined, color: Colors.red,),
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
                                        onPressed: () async {
                                          var metadata = await FirebaseFirestore
                                              .instance
                                              .collection('Classes')
                                              .doc(classModel['id'])
                                              .collection('Attendance')
                                              .doc(attend_data['id'])
                                              .get();
                                          var datetime = DateTime.fromMillisecondsSinceEpoch(metadata['timestamp']);
                                          final excel.Workbook workbook = excel.Workbook();
                                          final excel.Worksheet sheet = workbook.worksheets[0];

                                          final excel.Range range = sheet.getRangeByName('A5:D5');
                                          range.cellStyle.backColor = '#b7b5b5';

                                          sheet.getRangeByName('C1').setText('Subject : ');
                                          sheet.getRangeByName('D1').setText('${metadata['subject']}');
                                          sheet.getRangeByName('C2').setText('Date : ');
                                          sheet.getRangeByName('D2').setText('${DateFormat.yMd().format(datetime)}');
                                          sheet.getRangeByName('C3').setText('Time : ');
                                          sheet.getRangeByName('D3').setText('${DateFormat.jm().format(datetime)}');
                                          sheet.getRangeByName('A5').setText('Sr.No');
                                          sheet.getRangeByName('B5').setText('Student Name');
                                          sheet.getRangeByName('C5').setText('Email');
                                          sheet.getRangeByName('D5').setText('Attendance');

                                          for (int i = 0; i < snapshots.data!.docs.length; i++) {
                                            var data = snapshots.data!.docs[i]
                                                .data() as Map<String, dynamic>;

                                            if (data['Present']) {
                                              sheet.getRangeByName('A${i+6}').setNumber(i+1);
                                              sheet.getRangeByName('B${i+6}').setText(data['name']);
                                              sheet.getRangeByName('C${i+6}').setText(data['email']);
                                              sheet.getRangeByName('D${i+6}').cellStyle.backColor = '#98eb00';
                                              sheet.getRangeByName('D${i+6}').setText('Present');
                                            } else {
                                              sheet.getRangeByName('A${i+6}').setNumber(i+1);
                                              sheet.getRangeByName('B${i+6}').setText(data['name']);
                                              sheet.getRangeByName('C${i+6}').setText(data['email']);
                                              sheet.getRangeByName('D${i+6}').cellStyle.backColor = '#ff4f58';
                                              sheet.getRangeByName('D${i+6}').setText('Absent');
                                            }
                                          }
                                          sheet.autoFitColumn(3);
                                          sheet.autoFitColumn(2);
                                          sheet.autoFitColumn(4);


                                          final List<int> bytes = workbook.saveSync();
                                          workbook.dispose();

                                          await Permission.storage.request();
                                          PermissionStatus status = await Permission.storage.status;
                                          if(status == PermissionStatus.granted) {
                                            print(status);
                                          }else{
                                            await Permission.storage.request();
                                          }

                                          final directory = await getExternalStorageDirectory();
                                          final path = directory?.path;
                                          print(path);
                                          final String fileName = '${path}/${metadata['subject']}-${DateFormat('d MMM yyyy-h:mm a').format(DateTime.fromMillisecondsSinceEpoch(metadata['timestamp']))}.xlsx';
                                          final File file = File(fileName);
                                          await file.writeAsBytes(bytes,flush: true);
                                          OpenAppFile.open(fileName);


                                        },
                                        child: const Text('Download CSV')))),
                          ],
                        )
              ],
            ),
                      ),
                    ],
                  ),
                );
          }),
    );
  }
  Future<void> getData() async {
    int presentCount = 0;
    int absentCount = 0;
    await FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Attendance').doc(attend_data['id']).collection('Lists')
        .snapshots()
        .forEach((element) async {
        for (int i = 0; i < element.size; i++) {
          print(element.docs[i]['Present']);
          if (element.docs[i]['Present']) {
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


      setState(() {
        isLoading = false;
      });
    });
  }
}






List<AttData> getChartData(final presentval,final absentval,int presentCount,int absentCount) {
  final List<AttData> chartData = [
    AttData('Present', presentval, 'Present Students : ${presentCount}'),
    AttData('Absent', absentval, 'Absent Lectures : ${absentCount}')
  ];
  return chartData;
}

class AttData {
  AttData(this.status, this.count, this.Label);
  final String status;
  final int count;
  final String Label;
}
