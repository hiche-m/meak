import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:meak/Services/firestore.dart';
import 'package:meak/Services/storage.dart';
import 'package:meak/TextFormulations.dart';
import 'package:path_provider/path_provider.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<String?> get userId {
    return _auth.authStateChanges().map((User? user) => (user?.uid));
  }

  Future<String?> signInWithEmail(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String?> signUpWithEmail(
      {required String email,
      required String password,
      required String firstName,
      required String lastName}) async {
    try {
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      String? firestoreException = await Firestore().updateAccountData(
        uid: credentials.user!.uid,
        accountData: {
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "provider": "Email",
        },
        newUser: true,
      );
      firestoreException =
          await updateDisplayNameData(firstName: firstName, lastName: lastName);
      return firestoreException;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String?> signInWithFacebook() async {
    try {
      final _instance = FacebookAuth.instance;
      final result = await _instance.login(permissions: ['email']);
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final a = await _auth.signInWithCredential(credential);
        Map<String, dynamic> data = {};
        await _instance.getUserData().then((userData) async {
          await _auth.currentUser!.updateEmail(userData['email']);
          data = userData;
          data["uid"] = a.user!.uid;
          print(userData);
        });
        DateTime? lastSignInTime = a.user!.metadata.lastSignInTime;
        DateTime? creationTime = a.user!.metadata.creationTime;
        bool newUser = false;
        String? firestoreException;
        if (lastSignInTime!.difference(creationTime!).inMilliseconds <= 1000) {
          newUser = true;
          File? file;
          if (!kIsWeb) {
            final http.Response responseData =
                await http.get(data["picture"]["data"]["url"]);
            Uint8List uint8list = responseData.bodyBytes;
            var buffer = uint8list.buffer;
            ByteData byteData = ByteData.view(buffer);
            var tempDir = await getTemporaryDirectory();
            file = await File('${tempDir.path}/img').writeAsBytes(buffer
                .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          }
          String? storageUrl;
          if (file != null) {
            final snapshot = await Storage()
                .uploadPictureWithFile(data["uid"], file)
                .whenComplete(() {});
            storageUrl = await snapshot!.snapshot.ref.getDownloadURL();
          }

          firestoreException = await Firestore().updateAccountData(
            uid: data["uid"] ?? "",
            accountData: {
              "email": data["email"] ?? "",
              "firstName": data["name"] != null
                  ? nWordWithNoSpaces(data["name"], 0)
                  : "",
              "lastName": data["name"] != null
                  ? nWordWithNoSpaces(data["name"], 1)
                  : "",
              "imgURL": storageUrl ?? data["picture"]["data"]["url"],
              "provider": "Facebook",
            },
            newUser: newUser,
          );

          data['name'] != null
              ? await updateDisplayNameData(
                  firstName: nWordWithNoSpaces(data["name"], 0),
                  lastName: nWordWithNoSpaces(data["name"], 1))
              : null;
        }

        return firestoreException;
      } else if (result.status == LoginStatus.cancelled) {
        return 'Login cancelled';
      } else {
        return 'Error';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> confirmWithFacebook(String email) async {
    try {
      final _instance = FacebookAuth.instance;
      final result = await _instance.login(permissions: ['email']);
      if (result.status != LoginStatus.success) {
        return false;
      }
      if (_auth.currentUser!.email != null) {
        await _auth.currentUser!.reauthenticateWithCredential(
            FacebookAuthProvider.credential(result.accessToken!.token));
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);

    try {
      GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth =
          await _googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: _googleAuth.idToken,
        accessToken: _googleAuth.accessToken,
      );
      var a = await _auth.signInWithCredential(credential);
      var data = a.additionalUserInfo!.profile;
      data!["uid"] = a.user!.uid;
      DateTime? lastSignInTime = a.user!.metadata.lastSignInTime;
      DateTime? creationTime = a.user!.metadata.creationTime;
      bool newUser = false;
      if (lastSignInTime!.difference(creationTime!).inMilliseconds <= 1000) {
        newUser = true;
        File? file;
        if (!kIsWeb) {
          final http.Response responseData =
              await http.get(data["picture"]["data"]["url"]);
          Uint8List uint8list = responseData.bodyBytes;
          var buffer = uint8list.buffer;
          ByteData byteData = ByteData.view(buffer);
          var tempDir = await getTemporaryDirectory();
          file = await File('${tempDir.path}/img').writeAsBytes(buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        }
        String? storageUrl;
        if (file != null) {
          final snapshot = await Storage()
              .uploadPictureWithFile(data["uid"], file)
              .whenComplete(() {});
          storageUrl = await snapshot!.snapshot.ref.getDownloadURL();
        }
        await Firestore().updateAccountData(
          uid: data["uid"] ?? "",
          accountData: {
            "email": data["email"] ?? "",
            "firstName": data["given_name"] ?? "",
            "lastName": data["family_name"] ?? "",
            "imgURL": storageUrl ?? data["picture"],
            "provider": "Google",
          },
          newUser: newUser,
        );
        data['given_name'] != null && data['family_name'] != null
            ? await updateDisplayNameData(
                firstName: data['given_name'], lastName: data['family_name'])
            : null;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> confirmWithGoogle(String email) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);
    try {
      GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth =
          await _googleUser!.authentication;
      if (_auth.currentUser!.email != null) {
        await _auth.currentUser!
            .reauthenticateWithCredential(GoogleAuthProvider.credential(
          idToken: _googleAuth.idToken,
          accessToken: _googleAuth.accessToken,
        ));
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      return false;
    }

    /// Future<bool> confirmWithGoogle(String email) async {
    /// GoogleSignIn _googleSignIn = GoogleSignIn(
    ///     scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);

    /// try {
    ///   GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
    ///   String _googleAuthEmail = await _googleUser!.email;
    ///   if (_googleAuthEmail != email) {
    ///     return false;
    ///   }
    ///   return true;
    /// } catch (e) {
    ///   print(e);
    ///   return false;
    /// }
  }

  Future<void> logOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> updateEmailData(String email) async {
    String? response;
    try {
      await _auth.currentUser!.verifyBeforeUpdateEmail(email);
    } on FirebaseAuthException catch (e) {
      response = e.code;
    }
    return response;
  }

  Future<String?> updateDisplayNameData(
      {required String firstName, required String lastName}) async {
    String? response;
    try {
      await _auth.currentUser!.updateDisplayName(firstName + lastName);
    } on FirebaseAuthException catch (e) {
      response = e.code;
    }
    return response;
  }

  Future<String?> updatePassword(String newPassword) async {
    String? response;
    try {
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      response = e.code;
    }
    return response;
  }

  Future<bool?> passwordIsCorrect(String password) async {
    try {
      if (_auth.currentUser!.email != null) {
        await _auth.currentUser!.reauthenticateWithCredential(
            EmailAuthProvider.credential(
                email: _auth.currentUser!.email!, password: password));
        return true;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      return e.code != "wrong-password" ? false : null;
    }
  }

  String? emailIsChanged(String email) {
    bool changed = _auth.currentUser!.email != email;
    return changed ? _auth.currentUser!.email : null;
  }
}

class Resource {
  final Status status;
  Resource({required this.status});
}

enum Status { Success, Error, Cancelled }
