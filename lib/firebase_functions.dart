import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<void> pushFirebaseStorage(int id, PlatformFile? pickedFile, int userId)async {
  File file;
  if (pickedFile != null){
    file = File(pickedFile.path!);
    FirebaseStorage.instance.ref().child('files/${id}').putFile(file);
    FirebaseFirestore data = FirebaseFirestore.instance;
    data.collection('ticket_data').doc('$id').set({'firePath': 'files/${id}', 'user_id':userId});
  }
}

Future<void> pushAvatarFirebaseStorage(PlatformFile? pickedFile, int userId)async {
  File file;
  if (pickedFile != null){
    file = File(pickedFile.path!);
    FirebaseStorage.instance.ref().child('avatars/${userId}').putFile(file);
    FirebaseFirestore data = FirebaseFirestore.instance;
    data.collection('user_data').doc('$userId').set({'firePath': 'avatars/${userId}', 'user_id':userId});
  }
}