
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../methods/UserModel.dart';
import '../NotesScreen/ClassNotesScreen.dart';
import 'BodyClassHomeScreen.dart';
import 'ClassAssignmentScreen.dart';
import 'ClassParticipantScreen.dart';
import 'ClassSettingsScreen.dart';

class ClassHomeScreen extends StatefulWidget {
  var classData;
  UserModel userModel;


  ClassHomeScreen({Key? key, required this.classData, required this.userModel})
      : super(key: key);

  @override
  State<ClassHomeScreen> createState() =>
      _ClassHomeScreenState(classData, userModel);
}

class _ClassHomeScreenState extends State<ClassHomeScreen> {
  var classData;
  var userModel;
  int currentindex = 0;

  _ClassHomeScreenState(this.classData, this.userModel);

  var cUser = FirebaseAuth.instance.currentUser!;

  late List<Widget> _pages = [
    BodyClassHomeScreen(classModel: classData,userModel: userModel),
    ClassAssignmentScreen(classModel: classData, userModel: userModel),
    ClassNotesScreen(classModel: classData,userModel: userModel,),
  ];

  @override
  void initState() {
    // _pages = [
    //   BodyClassHomeScreen(classModel: classData),
    //   ClassAssignmentScreen(classModel: classData, userModel: userModel),
    //   ClassParticipantsScreen(classModel: classData)
    // ];
  }

  @override
  Widget build(BuildContext context) {
    // return SafeArea(
    //   child: Scaffold(
    //     body: NestedScrollView(
    //       headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    //         return [
    //           SliverAppBar(
    //             title: Text(classData['name']),
    //             actions: [
    //               IconButton(
    //                   onPressed: () {
    //                     Navigator.of(context).push(MaterialPageRoute(
    //                         builder: (context) => GroupChatScreen(
    //                               classModel: classData,
    //                               userModel: userModel,
    //                             )));
    //                   },
    //                   icon: Icon(Icons.messenger_rounded)),
    //               (userModel.role == 'teacher')
    //                   ? IconButton(
    //                       onPressed: () {
    //                         Navigator.of(context)
    //                             .pushReplacement(MaterialPageRoute(
    //                                 builder: (context) => ClassSettingsScreen(
    //                                       classData: classData,
    //                                       userModel: userModel,
    //                                     )));
    //                       },
    //                       icon: Icon(Icons.settings))
    //                   : Container()
    //             ],
    //             elevation: 20.0,
    //             expandedHeight: 50,
    //           )
    //         ];
    //       },
    //       body: getPage(currentindex)!,
    //     ),
    //     bottomNavigationBar:
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text(classData['name']),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ClassParticipantsScreen(classModel: classData)));
              },
              icon: Icon(Icons.person)),
          (userModel.role == 'teacher')
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ClassSettingsScreen(
                              classData: classData,
                              userModel: userModel,
                            )));
                  },
                  icon: Icon(Icons.settings))
              : Container()
        ],
      ),
      body: IndexedStack(
        children: _pages,
        index: currentindex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        selectedIconTheme: IconThemeData(size: 30),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Notes',
          ),
        ],
        currentIndex: currentindex,
        onTap: (int index) {
          setState(() {
            currentindex = index;
          });
        },
      ),
    );
  }

  Widget? getPage(int index) {
    switch (index) {
      case 0:
        {
          setState(() {});
          return BodyClassHomeScreen(
            classModel: classData,
            userModel: userModel,
          );
        }
        break;

      case 1:
        {
          setState(() {});
          return ClassAssignmentScreen(
            classModel: classData,
            userModel: userModel,
          );
        }
        break;
      case 2:
        {
          setState(() {});
          return ClassNotesScreen(classModel: classData,userModel: userModel,);
        }

        break;
    }
  }
}
