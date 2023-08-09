
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';

import '../../methods/firebase_api.dart';

class NewAssignment extends StatefulWidget {
  var classModel, userModel;
  NewAssignment({Key? key, required this.userModel, required this.classModel})
      : super(key: key);

  @override
  State<NewAssignment> createState() =>
      _NewAssignmentState(userModel, classModel);
}

class _NewAssignmentState extends State<NewAssignment> {
  var userModel, classModel;
  _NewAssignmentState(this.userModel, this.classModel);

  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();

  final Formkey = GlobalKey<FormState>();

  List<PlatformFile> file = [];
  DateTime Date = DateTime.now();
  UploadTask? task;
  var user = FirebaseAuth.instance.currentUser!.uid;
  List filename = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SingleChildScrollView(
          child: Form(
              key: Formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Enter Title'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Title';
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Enter Description'),
                    ),
                    minLines: 3,
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Deadline Date : ${Date.day}/${Date.month}/${Date.year}',
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
                  new Divider(
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Upload Files',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  file == null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No file Selected'),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8),
                              itemCount: file.length,
                              itemBuilder: (context, index) {
                                final files = file[index];

                                return buildFile(files);
                              })),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    selectFiles();
                                  },
                                  child: Text('Select Files')))),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  task != null ? buildUploadStatus(task!) : Container(),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          child: ElevatedButton(
                              onPressed: () async {
                                if (Formkey.currentState!.validate()) {
                                  if (Date.isAfter(DateTime.now())) {

                                    int date = DateTime(Date.year,Date.month,Date.day).millisecondsSinceEpoch;
                                    var id =
                                        DateTime.now().millisecondsSinceEpoch;
                                    var FileUrls = await Future.wait(file.map((e) => uploadFile(e,id.toString())));
                                    var map = {
                                      'title': _title.text.toString(),
                                      'description':
                                          _description.text.toString(),
                                      'end_date': date,
                                      'file_link': FileUrls,
                                      'file_name': filename.toSet().toList(),
                                      'id': id.toString()
                                    };

                                    var ref = FirebaseFirestore.instance
                                        .collection('Classes')
                                        .doc(classModel['id'])
                                        .collection('Assignments')
                                        .doc(id.toString());

                                    await ref.set(map).then((value) {
                                      snackbarKey.currentState!.showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Assignment posted')));
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    snackbarKey.currentState!.showSnackBar(SnackBar(
                                        content: Text(
                                            'Please select a valid Deadline')));
                                  }
                                }
                              },
                              child: Text('Post Assigment')),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }

  Future<void> openFile(PlatformFile file) async {
    // .open(file.path!);
    OpenAppFile.open(file.path!);
  }

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;
    setState(() {
      file = result.files;
    });
  }



  Future uploadFile(PlatformFile _file,String id) async {
    if (_file == null) return;

    final destination = 'files/assignments/${id}/${user}/${_file.name}';


    setState(() {
      filename.add(_file.name);
    });

    task = FirebaseApi.uploadFile(destination, File(_file.path!));
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Widget buildUploadStatus(UploadTask uploadTask) =>
      StreamBuilder<TaskSnapshot>(
        stream: task?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percent = (progress * 100).toStringAsFixed(2);

            return Center(
                child: Text(
              '${percent} %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ));
          } else {
            return Container();
          }
        },
      );

  Widget buildFile(PlatformFile file1) {
    final kb = file1.size / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final extension = file1.extension ?? 'none';
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
      onTap: () => OpenAppFile.open(file1.path!),
      child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(file1.name),
            subtitle: Text(fileSize),
            trailing: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  file.remove(file1);
                });
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
          )),
    );
  }

  getColor(String extension) {
    switch(extension) {
      case 'jpg': {
        return Colors.blueGrey.shade400;
      }
      break;
      case 'pdf' : {
        return Colors.red.shade800;
      }
      case 'docx' : {
        return Colors.blueAccent.shade700;
      }
      case 'xlsx' : {
        return Colors.green.shade300;
      }
      case 'csv' : {
        return Colors.green.shade300;
      }
      default : {
        return Colors.indigo.shade300;
      }
    }
  }
}
