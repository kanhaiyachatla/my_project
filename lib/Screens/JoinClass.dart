import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class JoinClass extends StatefulWidget {
  var usermodel;
  JoinClass({Key? key,required this.usermodel}) : super(key: key);

  @override
  State<JoinClass> createState() => _JoinClassState(usermodel);
}

var cuser = FirebaseAuth.instance.currentUser!;
final FormKey = GlobalKey<FormState>();
final _code = TextEditingController();

class _JoinClassState extends State<JoinClass> {
  var usermodel;
  _JoinClassState(this.usermodel);

  @override
  void dispose() {
    _code.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Class'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.07,
              ),
              const Text(
                'Get a Class Code from your Teacher and  Enter it here. ',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              Form(
                key: FormKey,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  controller: _code,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value!.isEmpty || value.length < 13)
                      ? 'Enter Valid Code'
                      : null,
                ),
              ),
              SizedBox(
                height: size.height * 0.08,
              ),
              const Text(
                'To sign in with Class code : ',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(' • Use an authorised account'),
              const SizedBox(
                height: 10,
              ),
              const Text(' • The Class code should be atleast 13 numeric digits'),
              SizedBox(
                height: size.height * 0.1,
              ),
              Center(
                child: Container(
                  width: size.width * 0.80,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (FormKey.currentState!.validate()) {
                        JoinClass1(_code.text.trim());
                      }

                    },
                    child: const Text('Join Class'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future JoinClass1(String code) async {
    showDialog(
        context: NavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    var classRef = FirebaseFirestore.instance.collection('Classes').doc(code);
    var classSnap =
        await FirebaseFirestore.instance.collection('Classes').doc(code).get();
    if (classSnap.exists) {
      var userSnap = await classRef.collection('members').doc(cuser.uid).get();
      if (userSnap.exists) {
        snackbarKey.currentState!.showSnackBar(
            const SnackBar(content: Text('You are already a member of this class')));
        Navigator.of(context).pop();
      } else {
        var map = await FirebaseFirestore.instance
            .collection('Users')
            .doc(cuser.uid)
            .get();
        if(usermodel.role == 'teacher'){
          await classRef.collection('members').doc(cuser.uid).set(map.data()!);
        }else{
          var prevAttendRef = await classRef.collection('Attendance').get();
          if(prevAttendRef.docs.isEmpty) {
            await classRef.collection('members').doc(cuser.uid).set(map.data()!);
          }else{
            for(int i=0;i < prevAttendRef.docs.length;i++) {
              var attend_map = {
                'Present' : false,
                'email' : usermodel.email,
                'id' : userSnap.id,
                'name' : usermodel.name,
                'photourl' : usermodel.photourl
              };
              await classRef.collection('Attendance').doc(prevAttendRef.docs[i].id).collection('Lists').doc(cuser.uid).set(attend_map);
            }
            await classRef.collection('members').doc(cuser.uid).set(map.data()!);
          }
        }
        try {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(cuser.uid).update({'inGroup' : FieldValue.arrayUnion([classSnap.data()!['id'].toString()])});
        } on FirebaseException catch (e) {
          snackbarKey.currentState!
              .showSnackBar(SnackBar(content: Text(e.message!)));
        }
        snackbarKey.currentState!
            .showSnackBar(const SnackBar(content: Text('Class Joined Successfully')));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } else {
      snackbarKey.currentState!.showSnackBar(const SnackBar(
          content:
              Text("Class Doesn't Exists. Check the code and try again. ")));
      Navigator.of(context).pop();
    }
  }
}
