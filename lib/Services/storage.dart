import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Storage {
  Future<UploadTask?> uploadPictureWithFile(String uid, File file) async {
    try {
      final String path = "profiles/$uid/picture.${extension(file.path)}";
      final ref = FirebaseStorage.instance.ref().child(path);
      return ref.putFile(file);

      /// final snapshot = await task.whenComplete(() {});

      /// return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  UploadTask? uploadPictureWithByte(String uid, List data) {
    try {
      final String path = "profiles/$uid/picture.${data[1]}";
      final ref = FirebaseStorage.instance.ref().child(path);
      return ref.putData(data[0]);

      /// final snapshot = await task.whenComplete(() {});

      /// return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickImagePlatform(ImageSource source) async {
    XFile? file = await ImagePicker()
        .pickImage(source: source, maxHeight: 1800, maxWidth: 1800);
    if (file != null) {
      return File(file.path);
    } else {
      return null;
    }
  }

  Future<List?> pickImageWeb() async {
    XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1800, maxWidth: 1800);
    if (file != null) {
      var bytes = await file.readAsBytes();
      return [bytes, file.mimeType!.split("/")[1]];
    } else {
      return null;
    }
  }
}
