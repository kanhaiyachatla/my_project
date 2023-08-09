import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../methods/CLassModel.dart';

class ClassParticipantsScreen extends StatefulWidget {
  var classModel;

  ClassParticipantsScreen({Key? key, required this.classModel})
      : super(key: key);

  @override
  State<ClassParticipantsScreen> createState() =>
      _ClassParticipantsScreenState(classModel);
}

class _ClassParticipantsScreenState extends State<ClassParticipantsScreen> {
  var classModel;

  _ClassParticipantsScreenState(this.classModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participants'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .doc(classModel['id'])
              .collection('members')
              .snapshots(),
          builder: (context,snapshots) {
            if(snapshots.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            }else{
              var Tlist = [],Slist = [];
              snapshots.data!.docs.forEach((element) { 
                if(element.data()['role'] == 'teacher'){
                  Tlist.add(element.data());
                }else{
                  Slist.add(element.data());
                }
              });
              return Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0,left: 12,bottom: 8),
                        child: Text('Teachers',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      ),
                       Divider(thickness: 2,),
                       ListView.builder(physics: NeverScrollableScrollPhysics(),shrinkWrap: true,itemCount: Tlist.length,itemBuilder: (context, index) {

                          return Container(
                            child: ListTile(
                              title: Text(Tlist[index]['name']),
                              subtitle: Text(Tlist[index]['email']),
                              leading: Tlist[index]['photourl'] == ''
                                  ? CircleAvatar(
                                backgroundColor: Colors.grey.withOpacity(0.5),
                                child: Icon(
                                  Icons.group,
                                  color: Colors.grey.shade700,
                                ),
                              )
                                  : CircleAvatar(
                                backgroundImage: NetworkImage(Tlist[index]['photourl']),
                              ),
                            ),
                          );
                        }),
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0,left: 12,bottom: 8),
                        child: Text('Students',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      ),
                      Divider(thickness: 2,),
                      ListView.builder(physics: NeverScrollableScrollPhysics(),shrinkWrap: true,itemCount: Slist.length,itemBuilder: (context, index) {

                        return ListTile(
                          title: Text(Slist[index]['name']),
                          subtitle: Text(Slist[index]['email']),
                          leading: Slist[index]['photourl'] == ''
                              ? CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            child: Icon(
                              Icons.group,
                              color: Colors.grey.shade700,
                            ),
                          )
                              : CircleAvatar(
                            backgroundImage: NetworkImage(Slist[index]['photourl']),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
