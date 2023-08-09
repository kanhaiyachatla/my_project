import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';

import '../../main.dart';
import '../../methods/firebase_api.dart';

class UploadNotesScreen extends StatefulWidget {
  var classModel;
  UploadNotesScreen({Key? key, required this.classModel}) : super(key: key);

  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState(classModel);
}

class _UploadNotesScreenState extends State<UploadNotesScreen> {
  var classModel;
  var initialvalue;

  final FormKey = GlobalKey<FormState>();
  final subLists = [];
  List filename = [];
  List fileexts = [];
  List filesize = [];
  UploadTask? task;

  List<PlatformFile> files = [];

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  _UploadNotesScreenState(this.classModel);

  @override
  void initState() {
    for (int i = 0; i < classModel['subjects'].length; i++) {
      subLists.add(classModel['subjects'][i]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Notes'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 32),
          child: Column(
            children: [
              Form(
                key: FormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Title',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: _title,
                      validator: (value) =>
                          (value!.isEmpty) ? 'Please Enter Title' : null,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Enter Description',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 3,
                      decoration: InputDecoration(
                          hintText: '(optional)', border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Select Subject',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      validator: (value) =>
                          (value == null) ? 'Please Select Subject' : null,
                      hint: Text('Select Subject'),
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
                    SizedBox(
                      height: 26,
                    ),
                    Text(
                      'Attach Notes',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    new Divider(
                      thickness: 2,
                    ),
                  ],
                ),
              ),
              if (files.isEmpty) Container(
                      margin: EdgeInsets.all(53),
                      child: InkWell(
                        onTap: _pickFile,
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 100,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Upload Files',
                              style: TextStyle(
                                  fontSize: 22, color: Colors.grey.shade600),
                            )
                          ],
                        ),
                      ),
                    ) else Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              crossAxisCount: 2,
                            ),
                            itemCount: files.length,
                            itemBuilder: (_, index) {
                              final item = files[index];
                              return buildFile(item);
                            },
                          ),
                          SizedBox(height: 16,),
                          TextButton.icon(
                            onPressed: _pickFile,
                            icon: Icon(Icons.upload_file),
                            label: Text('Add more Files'),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: task != null ? buildUploadStatus(task!) : Padding(
          padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 8),
          child: ElevatedButton(onPressed: () {
            if(FormKey.currentState!.validate()) {
              _createNotes();
              print('ALL OK');
            }
          }, child: Text('Upload Notes')),
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true,type: FileType.custom,allowedExtensions: ['pdf','xlsx','doc','pptx','csv','docx'],);
    if(files.isEmpty) {
      if (result == null) return;
      setState(() {
        files = result.files;
      });
    }else{
      if(result == null) return;
      setState(() {
        files.addAll(result.files);
      });
    }

  }

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
                  files.remove(file1);
                });
              },
            ),
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

  Future uploadFile(PlatformFile _file,String id) async {
    if (_file == null) return;
    final destination = 'Notes/${classModel['id']}/${initialvalue}/${id}/${_file.name}';


    setState(() {
      filename.add(_file.name);
      fileexts.add(_file.extension);
      filesize.add(_file.size);
    });

    task = FirebaseApi.uploadFile(destination, File(_file.path!));
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

_createNotes() async {
  if(files.isNotEmpty) {
    var date = DateTime.now().millisecondsSinceEpoch;
    var id =
        DateTime.now().millisecondsSinceEpoch;
    var FileUrls = await Future.wait(files.map((e) => uploadFile(e,id.toString())));
    var map = {
      'title': _title.text.toString(),
      'description':
      _description.text.toString(),
      'subject' : initialvalue,
      'date' : date,
      'file_link': FileUrls,
      'file_name': filename.toSet().toList(),
      'file_exts' : fileexts.toSet().toList(),
      'file_size' : filesize.toSet().toList(),
      'id': id.toString()
    };

    var ref = FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Notes')
        .doc(id.toString());

    await ref.set(map).then((value) {
      snackbarKey.currentState!.showSnackBar(
          SnackBar(
              content:
              Text('Assignment posted')));
      Navigator.pop(context);
    });

  }else{
    snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Please Select Files ')));
  }
  }

  Widget buildUploadStatus(UploadTask uploadTask) =>
      StreamBuilder<TaskSnapshot>(
        stream: task?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percent = (progress * 100).toStringAsFixed(2);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 30,),
                Text(
                  '${percent} %',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      );

}
