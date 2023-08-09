import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final ImagePicker imagePicker = ImagePicker();
  XFile? ImageFile;
  var cuser = FirebaseAuth.instance.currentUser!;
  final FormKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _subject = TextEditingController();

  var subjects = [];
  var no_sub = 0;

  var Urldownload;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Class',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Center(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      getImagefromGallery();
                    },
                    child: CircleAvatar(
                      radius: size.width * 0.20,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: ImageFile == null
                          ? null
                          : FileImage(File(ImageFile!.path)),
                      child: ImageFile == null
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              size: size.width * 0.18,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: FormKey,
              child: Container(
                margin: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _name,
                      validator: (value) =>
                          _name.text.isEmpty ? 'Enter Class Name' : null,
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).colorScheme.primary,
                        hintStyle: const TextStyle(fontSize: 12),
                        border: const OutlineInputBorder(),
                        labelText: 'Class Name',
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _description,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).colorScheme.primary,
                        hintStyle: const TextStyle(fontSize: 12),
                        border: const OutlineInputBorder(),
                        labelText: 'Description (optional)',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _subject,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              if(_subject.text.isEmpty){
                                snackbarKey.currentState!.showSnackBar(const SnackBar(content: Text('Subject name cannot be empty')));
                              }else{
                                if(no_sub > 9){
                                 snackbarKey.currentState!.showSnackBar(const SnackBar(content: Text('Max no of Subjects reached')));
                                }else {
                                  setState(() {
                                    subjects.add(_subject.text.trim());
                                    no_sub = no_sub + 1;
                                  });
                                  _subject.clear();
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                          focusColor: Theme.of(context).colorScheme.primary,
                          border: const OutlineInputBorder(),
                          labelText: 'Enter subjects(only distinct values)'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Subjects for your class',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Container(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Text((index+1).toString()),
                              title: Text(subjects[index]),
                              trailing: IconButton(onPressed: () {
                                setState(() {
                                  subjects.removeAt(index);
                                  no_sub -= 1;
                                });
                              }, icon: const Icon(Icons.cancel)),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemCount: subjects.length,),
                    ),
                    const Divider(),
                    SizedBox(
                        width: size.width,
                        child: ElevatedButton(
                            onPressed: () {
                              if (FormKey.currentState!.validate() && subjects.isNotEmpty) {
                                createClass(_name.text.trim(),
                                    _description.text.trim());
                              }else{
                                snackbarKey.currentState!.showSnackBar(const SnackBar(content: Text('Select Subjects for your Class')));
                              }
                            },
                            child: const Text(
                              'Create Class',
                            )))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getImagefromGallery() async {
    ImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      ImageFile;
    });
  }

  createClass(String name, String description) async {


    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final docRef = FirebaseFirestore.instance.collection('Classes').doc(id);
    await uploadFile(id);
    docRef.set({
      'id': id,
      'photourl': Urldownload,
      'name': name,
      'description': description,
      'subjects' : subjects.toSet().toList()
    }).then((value) async {
      var snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(cuser.uid)
          .get();
      var map = snap.data()!;

      try {
        await FirebaseFirestore.instance
            .collection('Classes')
            .doc(id)
            .collection('members')
            .doc(cuser.uid)
            .set(map);
        var classSnap = await docRef.get();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(cuser.uid).update({'inGroup' : FieldValue.arrayUnion([id.toString()])});
        snackbarKey.currentState!
            .showSnackBar(const SnackBar(content: Text('Group Created')));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } on Exception catch (e) {
        snackbarKey.currentState!
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }


      // Navigator.of(context).pop();
      // Navigator.of(context).pop();
    });
  }

  uploadFile(String id) async {
    showDialog(
        context: NavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    if (ImageFile == null) {
      Urldownload = '';
    } else {
      final path = 'groupImages/${id}/grp_image.png';
      final file = File(ImageFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);

      UploadTask? uploadtask = ref.putFile(file);
      final snapshot = await uploadtask.whenComplete(() => {});

      Urldownload = await snapshot.ref.getDownloadURL();
    }
  }
}
