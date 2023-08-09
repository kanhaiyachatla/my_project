import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';

import '../main.dart';
import '../methods/firebase_api.dart';
import 'PDFViewer.dart';

class SubmitAssignment extends StatefulWidget {
  var assign_data;
  var userModel;
  var ClassModel;
  SubmitAssignment(
      {Key? key,
      required this.assign_data,
      required this.userModel,
      required this.ClassModel})
      : super(key: key);

  @override
  State<SubmitAssignment> createState() =>
      _SubmitAssignmentState(assign_data, userModel, ClassModel);
}

class _SubmitAssignmentState extends State<SubmitAssignment> {
  var assign_data;
  var userModel;
  var ClassModel;
  var user = FirebaseAuth.instance.currentUser!.uid;


  _SubmitAssignmentState(this.assign_data, this.userModel, this.ClassModel);

  File? file;
  UploadTask? task;
  double downloadprog = 0.0;
  String filename = 'File not Selected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(assign_data['title']),
        ),
        body: FutureBuilder(
            future: isDocumentExists(),
            builder: (context, snap) {
              if (snap.hasData) {
                var data = snap.data!.data();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          (assign_data['description'] == '')
                              ? Container()
                              : Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8,
                                            left: 16,
                                            right: 16),
                                        child: Text(assign_data['description']),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),

                              Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'Attached Files:',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => PDFViewer(submission_data: data,assign_id: assign_data['id'],class_id: ClassModel['id'],)));

                                            // FileDownloader.downloadFile(
                                            //     url: data['url'],
                                            //     name: data['file_name'],
                                            //   onDownloadCompleted: (String path) {
                                            //     snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('FILE DOWNLOADED TO PATH: $path')));
                                            //     OpenAppFile.open(path);
                                            //   },
                                            //     onProgress: (String? filename,
                                            //         double? progress) {
                                            //       setState(() {
                                            //         downloadprog = progress!;
                                            //       });
                                            //     },);
                                          },
                                          leading: Icon(Icons.picture_as_pdf),
                                          title: Text(data['file_name']),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: ElevatedButton(
                                          onPressed: task != null
                                              ? null
                                              : () async {
                                            await FirebaseStorage.instance.refFromURL(data['url']).delete();
                                                  var ref = FirebaseFirestore
                                                      .instance
                                                      .collection('Classes')
                                                      .doc(ClassModel['id'])
                                                      .collection('Assignments')
                                                      .doc(assign_data['id']
                                                          .toString())
                                                      .collection('Submission')
                                                      .doc(user);

                                                  ref.delete().then((value) {

                                                    snackbarKey.currentState!
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Assignment withdrawn')));
                                                    Navigator.pop(context);
                                                  });
                                                },
                                          child: Text('UnSubmit Assignment')))),
                            ],
                          ),
                          (downloadprog == 0.0)
                              ? Container()
                              : Container(
                                  child: LinearProgressIndicator(
                                    value: downloadprog,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                );
              }else{
              return SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          (assign_data['description'] == '')
                              ? Container()
                              : Container(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Description',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8,
                                            left: 16,
                                            right: 16),
                                        child: Text(assign_data['description']),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                          assign_data['file_name'].length == 0
                              ? Container()
                               : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('Attachments',style: TextStyle(
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold),),
                                   Divider(),
                                   Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: GridView.builder(
                                           physics: NeverScrollableScrollPhysics(),
                                           shrinkWrap: true,
                                           gridDelegate:
                                           SliverGridDelegateWithFixedCrossAxisCount(
                                               crossAxisCount: 2,
                                               mainAxisSpacing: 8,
                                               crossAxisSpacing: 8),
                                           itemCount: assign_data['file_name'].length,
                                           itemBuilder: (context, index) {
                                             final filename = assign_data['file_name'][index];
                                             final fileurl = assign_data['file_link'][index];

                                             return buildFile(filename,fileurl);
                                           })),
                                 ],
                               ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Your Work',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        'End Date :  ' + DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(assign_data['end_date'])).toString()),
                                  ],
                                ),
                                new Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                file == null
                                    ? Container(
                                        child: Text('No Attached Files'),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            border:
                                                Border.all(color: Colors.black)),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.book_rounded),
                                          ),
                                          title: Text(filename),
                                          trailing: InkWell(onTap: () {
                                            setState(() {
                                              file = null;
                                            });
                                          },child: Icon(Icons.cancel)),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Visibility(
                            visible: file == null ? true : false,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        child: ElevatedButton(
                                            onPressed: file == null
                                                ? () {
                                                    selectFiles();
                                                  }
                                                : null,
                                            child: Text('Attach PDF')))),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: ElevatedButton(
                                          onPressed: task != null
                                              ? null
                                              : () {
                                            var date = DateTime.now().millisecondsSinceEpoch;
                                                  uploadFile().then((value) {
                                                    var map = {
                                                      'name': userModel.name,
                                                      'email': userModel.email,
                                                      'id': user,
                                                      'url': value,
                                                      'submit_date' : date,
                                                      'file_name': filename
                                                    };
                                                    var ref = FirebaseFirestore
                                                        .instance
                                                        .collection('Classes')
                                                        .doc(ClassModel['id'])
                                                        .collection('Assignments')
                                                        .doc(assign_data['id']
                                                            .toString())
                                                        .collection('Submission')
                                                        .doc(user);

                                                    ref.set(map).then((value) {
                                                      snackbarKey.currentState!
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Assignment submitted')));
                                                      Navigator.pop(context);
                                                    });
                                                  });
                                                },
                                          child: Text('Submit Assignment')))),
                            ],
                          ),
                          task != null ? buildUploadStatus(task!) : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            }));
  }
  Widget buildFile(String filename,String fileurl) {
    final extension = filename.substring(filename.length - 3);
    final color = Colors.blueGrey;
    var download_prog;

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


    return GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(filename),
            // subtitle: (download_prog == 0.0) ? Text('') :Text(download_prog.toString()),
            trailing: IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                //TODO Implement Flutter download manager
                // FileDownloader.downloadFile(url: fileurl,name: filename,onDownloadCompleted: (String path) {
                //   OpenAppFile.open(path);
                // });
              },
            ),
          ),
          child: Container(
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
          ),
    );
  }

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false,allowedExtensions: ['pdf'],type: FileType.custom,);

    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      filename = result.files.single.name;
    });
  }

  Future uploadFile() async {
    if (file == null) return;

    final destination = 'files/assignments/${assign_data['id']}/Submissions/${user}/${filename}';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    String urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }

  Widget buildUploadStatus(UploadTask uploadTask) =>
      StreamBuilder<TaskSnapshot>(
        stream: task?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;

            return Center(
                child: LinearProgressIndicator(
              value: progress,
            ));
          } else {
            return Container();
          }
        },
      );

  Future isDocumentExists() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('Classes')
        .doc(ClassModel['id'])
        .collection('Assignments')
        .doc(assign_data['id'].toString())
        .collection('Submission')
        .doc(user)
        .get();

    if (doc.exists) {
      return doc;
    } else {
      return null;
    }
  }
}
