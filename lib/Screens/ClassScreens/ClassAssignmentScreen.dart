import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NewAssignment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../methods/CLassModel.dart';
import '../CheckAssignment.dart';
import '../SubmitAssignment.dart';

class ClassAssignmentScreen extends StatefulWidget {
  var classModel;
  var userModel;

  ClassAssignmentScreen(
      {Key? key, required this.classModel, required this.userModel})
      : super(key: key);

  @override
  State<ClassAssignmentScreen> createState() =>
      _ClassAssignmentScreenState(classModel, userModel);
}

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  var classModel, userModel;

  _ClassAssignmentScreenState(this.classModel, this.userModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(builder: (context, snapshots) {
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Classes')
                .doc(classModel['id'])
                .collection('Assignments')
                .snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                return snapshots.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : (snapshots.data!.docs.length == 0)
                        ? Center(
                            child: Text('No Assignments Added'),
                          )
                        : Container(
                  color: Colors.grey.shade200,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var data = snapshots.data!.docs[index].data()
                                    as Map<String, dynamic>;

                                return Card(
                                  child: OpenContainer(
                                    transitionDuration: Duration(milliseconds: 300),
                                    openBuilder: (BuildContext context, void Function({Object? returnValue}) openAction) => (userModel.role == 'teacher') ? CheckAssignment(userModel: userModel, classModel: classModel, assign_data: data): SubmitAssignment(assign_data: data, userModel: userModel, ClassModel: classModel),
                                    closedBuilder: (BuildContext context, void Function() openAction) => ExpansionTile(
                                      title: Text(data['title'],),
                                      leading: Icon(Icons.book),
                                      subtitle: Text("End date : "+DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(data['end_date'])).toString()),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 8.0),
                                          child: ListTile(
                                            title: Text(
                                              'Description',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(data['description']),
                                          ),
                                        ),
                                        Container(width: double.infinity,margin: EdgeInsets.symmetric(horizontal: 8,vertical: 4),child: ElevatedButton(onPressed: openAction, child: Text('View Assignment'),))
                                      ],
                                    ),
                                  ),

                                );

                                // return ListTile(
                                //   onTap: () => !
                                //   (userModel.role == 'teacher') ? Navigator.of(context).push(
                                //       MaterialPageRoute(builder: (context) =>
                                //           SubmitAssignment(assign_data: data,
                                //               userModel: userModel,
                                //               ClassModel: classModel))) : Navigator.of(context).push(
                                //       MaterialPageRoute(builder: (context) =>
                                //           CheckAssignment(assign_data: data,
                                //               userModel: userModel,
                                //              classModel: classModel,))),
                                //   leading: CircleAvatar(
                                //     child: Icon(Icons.book),
                                //   ),
                                //   title: Text(data['title']),
                                //   subtitle: Text("End Date : "+data['end_date']),
                                // );
                              },
                              itemCount: snapshots.data!.docs.length),
                        );
              } else {
                return Center(
                  child: Text('Error has occured'),
                );
              }
            });
      }),
      floatingActionButton: userModel.role == 'teacher'
          ? FloatingActionButton(
        heroTag: 'ClassAssignmentButton',
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewAssignment(
                              userModel: userModel,
                              classModel: classModel,
                            )));
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
