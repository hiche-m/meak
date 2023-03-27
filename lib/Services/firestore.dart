import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  final CollectionReference _accounts =
      FirebaseFirestore.instance.collection("accounts");
  Future<String?> updateAccountData({
    required String uid,
    required Map<String, dynamic> accountData,
    bool newUser = false,
  }) async {
    Map<String, dynamic> options = {};
    bool proceed = false;
    Map<String, dynamic> defaults = {
      "lang": "en_US",
      "middleName": "",
      "selectedTheme": 0,
      "appNots": true,
      "msgNots": true,
      "showMiddleName": true,
      "firstNameFirst": true,
    };
    accountData.forEach((key, value) {
      value != null ? [options[key] = value, proceed = true] : null;
    });
    newUser
        ? defaults.forEach((key, value) {
            options[key] == null ? options[key] = value : null;
          })
        : null;
    try {
      proceed
          ? await _accounts.doc(uid).set(options, SetOptions(merge: true))
          : null;
      return null;
    } on FirebaseException catch (e) {
      return e.code;
    }
  }

  Future<String?> updateUserPreferences({
    required String uid,
    int? selectedTheme,
    bool? appNots,
    bool? msgNots,
    bool? showMiddleName,
    bool? firstNameFirst,
    String? lang,
  }) async {
    String? output;
    try {
      if (selectedTheme != null ||
          appNots != null ||
          msgNots != null ||
          showMiddleName != null ||
          firstNameFirst != null) {
        Map<String, dynamic> options = {};
        appNots != null ? options.addAll({"App_Not": appNots}) : null;
        msgNots != null ? options.addAll({"Chat_Not": msgNots}) : null;
        showMiddleName != null
            ? options.addAll({"showMiddleName": showMiddleName})
            : null;
        firstNameFirst != null
            ? options.addAll({"firstNameFirst": firstNameFirst})
            : null;
        selectedTheme != null
            ? options.addAll({"selectedTheme": selectedTheme})
            : null;
        lang != null ? options.addAll({"lang": lang}) : null;

        await _accounts.doc(uid).set(options, SetOptions(merge: true));
      } else {
        output = "no_options";
      }
      return output;
    } on FirebaseException catch (e) {
      return e.code;
    }
  }
}
