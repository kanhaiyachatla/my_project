import 'dart:io';


import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import 'ShowPDF.dart';




class ViewNotesScreen extends StatefulWidget {
  var classModel;
  var userModel;
  var notesData;
  ViewNotesScreen(
      {super.key,
      required this.classModel,
      required this.userModel,
      required this.notesData});

  @override
  State<ViewNotesScreen> createState() =>
      _ViewNotesScreenState(classModel, userModel, notesData);
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  var classModel;
  var userModel;
  var notesData;
  final dio = Dio();
  bool isLoading= false;

  _ViewNotesScreenState(this.classModel, this.userModel, this.notesData);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notesData['title']),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 22, right: 22, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                    'Date : ${DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(notesData['date']))}')
              ],
            ),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              '${notesData['description']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              'Attached Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Divider(
              thickness: 2,
            ),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                crossAxisCount: 2,
              ),
              itemCount: notesData['file_link'].length,
              itemBuilder: (_, index) {
                return buildFile(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFile(int index) {
    final kb = notesData['file_size'][index] / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final extension = notesData['file_exts'][index] ?? 'none';
    final color = getColor(extension);

    // TWO OPTION AVAILABLE TO VIEW FILES

    // return InkWell(
    //   onTap: () => OpenAppFile.open(file1.path!),
    //   child: Container(
    //     padding: EdgeInsets.all(8),
    //     child: Column(
    //       children: [
    //         Expanded(child: Container(
    //           alignment: Alignment.center,
    //           width: 140,
    //           decoration: BoxDecoration(
    //             color: color,
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //           child: Text('${extension}',style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,color: Colors.white),),
    //         ),
    //         ),
    //         const SizedBox(height: 8,),
    //         Text(file1.name,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
    //         Text(fileSize,style: TextStyle(fontSize: 10),)
    //       ],
    //     ),
    //   ),
    // );

    return InkWell(
      onTap: () async {
        if (notesData['file_exts'][index] == 'pdf') {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => ShowPDF(filename: notesData['file_name'][index],fileURL: notesData['file_link'][index],)));
        }else{
          PermissionStatus status = await Permission.manageExternalStorage.request();

          print(status);

          if(status.isGranted) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(),
                ));
            var dir = '/storage/emulated/0/Download/${notesData['file_name'][index]}';

            Response response = await dio.download(notesData['file_link'][index], dir);

            Navigator.of(context).pop();

            if(response.statusMessage == 'OK'){
              OpenAppFile.open(dir);
            }else{
              Navigator.of(context).pop();
            }
          }else{
              snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Please Enable Storage Permissions')));
          }

        }
      },
      child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(notesData['file_name'][index]),
            subtitle: Text(fileSize),
            trailing: Icon(Icons.open_in_new,size: 20,),
          ),
          child: Container(
            height: 100,
            color: color,
            child: Center(
              child: Text(
                extension,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )),
    );
  }

  getColor(String extension) {
    switch (extension) {
      case 'jpg':
        {
          return Colors.blueGrey.shade400;
        }
        break;
      case 'pdf':
        {
          return Colors.red.shade400;
        }
      case 'docx':
        {
          return Colors.blueAccent.shade700;
        }
      case 'xlsx':
        {
          return Colors.green.shade300;
        }
      case 'csv':
        {
          return Colors.green.shade300;
        }
      default:
        {
          return Colors.indigo.shade300;
        }
    }
  }
}
