import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'authservices.dart';

class Realtime_DataBase {
  Auth _auth = Auth();
  final ref = FirebaseDatabase.instance.reference();

  void saveMessage({
    @required var userinfo,
    @required String message,
    @required int time,
    @required String role,
    @required String photourl,
    @required String attachmenturl,
    @required String attachmentname,
    @required String videourl,
  }) async {
    try {
      if (message != null ||
          photourl != null ||
          attachmenturl != null ||
          videourl != null) {
        var uid = _auth.getuid();
        var data;

        data = await ref.child('EC').once().then((value) => value.value);
        String nextObjectname = data.length.toString();
        await ref.child(userinfo['role']).child(nextObjectname).set({
          'username': userinfo['username'],
          'message': message,
          'time': time,
          'uid': uid,
          'photourl': photourl,
          'attachment': {
            'attachmenturl': attachmenturl,
            'attachmentname': attachmentname,
          },
          'videourl': videourl
        });
      }
    } catch (e) {
      return e.messages;
    }
  }
}
