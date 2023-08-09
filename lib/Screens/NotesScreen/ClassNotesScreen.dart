import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'UploadNotesScreen.dart';
import 'ViewNotesScreen.dart';

class ClassNotesScreen extends StatefulWidget {
  var classModel;
  var userModel;
  ClassNotesScreen({Key? key, required this.classModel,required this.userModel}) : super(key: key);

  @override
  State<ClassNotesScreen> createState() => _ClassNotesScreenState(classModel,userModel);
}

class _ClassNotesScreenState extends State<ClassNotesScreen> {
  var classModel;
  var userModel;

  _ClassNotesScreenState(this.classModel,this.userModel);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .doc(classModel['id'])
              .collection('Notes')
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData) {
              return snapshots.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : (snapshots.data!.docs.isEmpty)
                      ? const Center(
                          child: Text('No Notes Added'),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var data = snapshots.data!.docs[index].data()
                                    as Map<String, dynamic>;

                                return ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewNotesScreen(classModel: classModel, userModel: userModel,notesData: data,)));
                                  },
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.book),
                                  ),
                                  title: Text(data['title']),
                                  subtitle: Text('Posted on : ${DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(data['date']))}'),
                                );
                              },
                              itemCount: snapshots.data!.docs.length, separatorBuilder: (BuildContext context, int index) {
                                return const Divider();
                          },),
                        );
            } else {
              return const Center(
                child: Text('Error has occured'),
              );
            }
          }),
      floatingActionButton: (userModel.role == 'teacher') ?FloatingActionButton.extended(
        heroTag: 'ClassNotesScreenButton',
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UploadNotesScreen(
                    classModel: classModel,
                  )));
        },
        tooltip: 'Pick File',
        label: const Text('Share Notes'),
        icon: const Icon(Icons.add),
      ) : null,
    );
  }

  getNotes() {
    return FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Assignments')
        .snapshots();
  }
}
