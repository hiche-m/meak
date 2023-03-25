import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meak/Classes/profile.dart';
import 'package:meak/Services/auth.dart';
import 'package:meak/Services/firestore.dart';
import 'package:meak/TextFormulations.dart';
import 'package:email_validator/email_validator.dart';
import 'package:meak/main.dart';
import 'package:meak/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meak/Screens/settings.dart' as settings;

class Security extends StatefulWidget {
  Security({Key? key, required this.account, required this.uid})
      : super(key: key);

  final String uid;
  Profile account;

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  late double scale;
  late double width;
  late double height;

  int selectedTheme = 0;

  final _settingsFormKey = GlobalKey<FormState>();

  var firstNameController =
      TextEditingController(text: settings.argAccount.firstName);
  var lastNameController =
      TextEditingController(text: settings.argAccount.lastName);
  var middleNameController =
      TextEditingController(text: settings.argAccount.middleName);
  var emailController = TextEditingController(text: settings.argAccount.email);
  var passwordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var newRePasswordController = TextEditingController();

  bool firstNameEmpty = false;
  bool lastNameEmpty = false;
  bool middleNameEmpty = false;
  bool emailEmpty = false;
  bool passwordEmpty = true;
  bool newPasswordEmpty = true;
  bool newRePasswordEmpty = true;

  bool firstNameChanged = false;
  bool lastNameChanged = false;
  bool middleNameChanged = false;
  bool emailChanged = false;
  bool passwordChanged = false;
  bool newPasswordChanged = false;
  bool newRePasswordChanged = false;

  bool checkingPassState = false;

  Map<String, bool> criticalValids = {
    "password": false,
    "email": true,
    "newPassword": true,
    "newRePassword": true,
  };

  String? firstName;
  String? lastName;
  String? middleName;
  String? email;
  String? newPassword;
  String? newRePassword;

  late SharedPreferences prefs;

  late ScrollController scrollBarController;

  @override
  void dispose() {
    super.dispose();
    scrollBarController.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
    scrollBarController = ScrollController(initialScrollOffset: 50.0);
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    selectedTheme = prefs.getInt("selectedTheme") ?? defaultTheme;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    scale = MediaQuery.of(context).textScaleFactor;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    init();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: swatchList[selectedTheme][2],
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            if (changesMade()) {
              _showConfirmDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: swatchList[selectedTheme][0],
          ),
          splashRadius: 25.0,
        ),
        title: Text("account_settings".tr,
            style: TextStyle(
              fontSize: (height / 8) * 0.75 / 3,
              fontWeight: FontWeight.w600,
              color: swatchList[selectedTheme][0],
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: scrollBarController,
        child: Container(
          height: height,
          width: width,
          color: swatchList[selectedTheme][2],
          child: Form(
            key: _settingsFormKey,
            //The column of columns
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  //General settings
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(" ${"general_settings".tr}:",
                                style: TextStyle(
                                  fontSize: (height / 8) * 0.6 / 3,
                                  color: swatchList[selectedTheme][5],
                                )),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: swatchList[selectedTheme][3],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    (height / 8) * 0.75 * 0.35)),
                                border: Border.all(
                                  width: 2.0,
                                  color: swatchList[selectedTheme][3],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12.0, 4.0, 12.0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //First Name
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  "${"first_name".tr}:",
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (height / 8) * 0.75 / 3,
                                                    fontWeight: FontWeight.w600,
                                                    color: swatchList[
                                                        selectedTheme][4],
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Tooltip(
                                              message: "field_modified".tr,
                                              child: SizedBox(
                                                width: 10.0,
                                                child: firstNameChanged
                                                    ? const Text(
                                                        "!",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[a-z A-Z]")),
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller: firstNameController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "enter_fn".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !firstNameEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            firstNameController
                                                                .clear();
                                                            firstNameEmpty =
                                                                true;
                                                            firstNameChanged =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  firstName = capFix(value);
                                                } else {
                                                  firstName = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                String account = settings
                                                    .argAccount.firstName;
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    firstNameChanged = false;
                                                    firstNameEmpty = true;
                                                  });
                                                } else if (value != account &&
                                                    !firstNameChanged) {
                                                  setState(() {
                                                    firstNameChanged = true;
                                                    firstNameEmpty = false;
                                                  });
                                                } else if (value == account &&
                                                    firstNameChanged) {
                                                  setState(() {
                                                    firstNameChanged = false;
                                                    firstNameEmpty = false;
                                                  });
                                                } else if (firstNameEmpty) {
                                                  setState(() {
                                                    firstNameEmpty = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Last Name
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  "${"last_name".tr}:",
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (height / 8) * 0.75 / 3,
                                                    fontWeight: FontWeight.w600,
                                                    color: swatchList[
                                                        selectedTheme][4],
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Tooltip(
                                              message: "field_modified".tr,
                                              child: SizedBox(
                                                width: 10.0,
                                                child: lastNameChanged
                                                    ? const Text(
                                                        "!",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[a-zA-Z]")),
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller: lastNameController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "enter_ln".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !lastNameEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            lastNameController
                                                                .clear();
                                                            lastNameEmpty =
                                                                true;
                                                            lastNameChanged =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  lastName = capFix(value);
                                                } else {
                                                  lastName = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                String account = settings
                                                    .argAccount.lastName;
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    lastNameChanged = false;
                                                    lastNameEmpty = true;
                                                  });
                                                } else if (value != account &&
                                                    !lastNameChanged) {
                                                  setState(() {
                                                    lastNameChanged = true;
                                                    lastNameEmpty = false;
                                                  });
                                                } else if (value == account &&
                                                    lastNameChanged) {
                                                  setState(() {
                                                    lastNameChanged = false;
                                                    lastNameEmpty = false;
                                                  });
                                                } else if (lastNameEmpty) {
                                                  setState(() {
                                                    lastNameEmpty = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Middle Name
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 5,
                                              child: Text(
                                                "${"middle_name".tr}:",
                                                softWrap: false,
                                                style: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [4],
                                                ),
                                              )),
                                          Tooltip(
                                            message: "field_modified".tr,
                                            child: SizedBox(
                                              width: 10.0,
                                              child: middleNameChanged
                                                  ? const Text(
                                                      "!",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 7,
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller: middleNameController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "enter_mn".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !middleNameEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            middleNameController
                                                                .clear();
                                                            middleNameEmpty =
                                                                true;
                                                            middleNameChanged =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  middleName = capFix(value);
                                                } else {
                                                  middleName = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                String? account = settings
                                                    .argAccount.middleName;
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    middleNameChanged = false;
                                                    middleNameEmpty = true;
                                                  });
                                                } else if (value != account &&
                                                    !middleNameChanged) {
                                                  setState(() {
                                                    middleNameChanged = true;
                                                    middleNameEmpty = false;
                                                  });
                                                } else if (value == account &&
                                                    middleNameChanged) {
                                                  setState(() {
                                                    middleNameChanged = false;
                                                    middleNameEmpty = false;
                                                  });
                                                } else if (middleNameEmpty) {
                                                  setState(() {
                                                    middleNameEmpty = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Security settings
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(" ${"sec_settings".tr}:",
                                style: TextStyle(
                                  fontSize: (height / 8) * 0.6 / 3,
                                  color: swatchList[selectedTheme][5],
                                )),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: swatchList[selectedTheme][3],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    (height / 8) * 0.75 * 0.35)),
                                border: Border.all(
                                  width: 2.0,
                                  color: swatchList[selectedTheme][3],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12.0, 4.0, 12.0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Email
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  "${"email".tr}:",
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (height / 8) * 0.75 / 3,
                                                    fontWeight: FontWeight.w600,
                                                    color: criticalValids[
                                                                'email'] ==
                                                            true
                                                        ? swatchList[
                                                            selectedTheme][4]
                                                        : Colors.red,
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Tooltip(
                                              message: "field_modified".tr,
                                              child: SizedBox(
                                                width: 10.0,
                                                child: emailChanged
                                                    ? const Text(
                                                        "!",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: (value) {
                                                value != null &&
                                                        value.isNotEmpty
                                                    ? !EmailValidator.validate(
                                                            value)
                                                        ? setState(() {
                                                            criticalValids[
                                                                    'email'] =
                                                                false;
                                                          })
                                                        : setState(() {
                                                            criticalValids[
                                                                'email'] = true;
                                                          })
                                                    : setState(() {
                                                        criticalValids[
                                                            'email'] = true;
                                                      });
                                                return value != null &&
                                                        value.isNotEmpty
                                                    ? !EmailValidator.validate(
                                                            value)
                                                        ? '      Please enter a valid email.'
                                                        : null
                                                    : null;
                                              },
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                errorStyle: const TextStyle(
                                                    fontSize: 0.01),
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "enter_em".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !emailEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            emailChanged =
                                                                false;
                                                            emailController
                                                                .clear();
                                                            emailEmpty = true;
                                                            criticalValids[
                                                                'email'] = true;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  email = value;
                                                } else {
                                                  email = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                String account =
                                                    settings.argAccount.email;
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    emailChanged = false;
                                                    emailEmpty = true;
                                                  });
                                                } else if (value != account &&
                                                    !emailChanged) {
                                                  setState(() {
                                                    emailChanged = true;
                                                    emailEmpty = false;
                                                  });
                                                } else if (value == account &&
                                                    emailChanged) {
                                                  setState(() {
                                                    emailChanged = false;
                                                    emailEmpty = false;
                                                  });
                                                } else if (emailEmpty) {
                                                  setState(() {
                                                    emailEmpty = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //New Password
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 5,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  "${"new_pass".tr}:",
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (height / 8) * 0.75 / 3,
                                                    fontWeight: FontWeight.w600,
                                                    color: criticalValids[
                                                            'newPassword']!
                                                        ? swatchList[
                                                            selectedTheme][4]
                                                        : Colors.red,
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Tooltip(
                                              message: "field_modified".tr,
                                              child: SizedBox(
                                                width: 10.0,
                                                child: newPasswordChanged
                                                    ? const Text(
                                                        "!",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 7,
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller: newPasswordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                errorStyle: const TextStyle(
                                                    fontSize: 0.01),
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "create_np".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !newPasswordEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            newPasswordController
                                                                .clear();
                                                            newPasswordEmpty =
                                                                true;
                                                            criticalValids[
                                                                    'newPassword'] =
                                                                true;
                                                            newPasswordChanged =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              validator: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  if (value.length < 8) {
                                                    setState(() {
                                                      criticalValids[
                                                              'newPassword'] =
                                                          false;
                                                    });
                                                    return "Invalid Password!";
                                                  } else {
                                                    setState(() {
                                                      criticalValids[
                                                          'newPassword'] = true;
                                                    });
                                                    return null;
                                                  }
                                                } else {
                                                  setState(() {
                                                    criticalValids[
                                                        'newPassword'] = true;
                                                  });
                                                  return null;
                                                }
                                              },
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  newPassword = value;
                                                } else {
                                                  newPassword = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    newPasswordEmpty = true;
                                                    newPasswordChanged = false;
                                                  });
                                                } else if (newPasswordEmpty &&
                                                    value.isNotEmpty) {
                                                  setState(() {
                                                    newPasswordEmpty = false;
                                                    newPasswordChanged = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    newPasswordChanged = true;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Repeat Password
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              flex: 6,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  "${"repeat_np".tr}:",
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (height / 8) * 0.75 / 3,
                                                    fontWeight: FontWeight.w600,
                                                    color: criticalValids[
                                                            'newRePassword']!
                                                        ? swatchList[
                                                            selectedTheme][4]
                                                        : Colors.red,
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Tooltip(
                                              message: "field_modified".tr,
                                              child: SizedBox(
                                                width: 10.0,
                                                child: newRePasswordChanged
                                                    ? const Text(
                                                        "!",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 7,
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: TextStyle(
                                                fontSize:
                                                    (height / 8) * 0.75 / 3,
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                              controller:
                                                  newRePasswordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                errorStyle: const TextStyle(
                                                    fontSize: 0.01),
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: "re_pass".tr,
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      (height / 8) * 0.75 / 3,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [5],
                                                ),
                                                suffixIcon: !newRePasswordEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            newRePasswordController
                                                                .clear();
                                                            newRePasswordEmpty =
                                                                true;
                                                            newRePasswordChanged =
                                                                false;
                                                            criticalValids[
                                                                    'newRePassword'] =
                                                                true;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .close_rounded),
                                                      )
                                                    : null,
                                              ),
                                              validator: (value) {
                                                if (newPasswordController
                                                        .text ==
                                                    value) {
                                                  setState(() {
                                                    criticalValids[
                                                        'newRePassword'] = true;
                                                  });
                                                  return null;
                                                } else {
                                                  setState(() {
                                                    criticalValids[
                                                            'newRePassword'] =
                                                        false;
                                                  });
                                                  return "Passwords do not match!";
                                                }
                                              },
                                              onSaved: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  newRePassword = value;
                                                } else {
                                                  newRePassword = null;
                                                }
                                              },
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    newRePasswordEmpty = true;
                                                    newRePasswordChanged =
                                                        false;
                                                  });
                                                } else if (newRePasswordEmpty &&
                                                    value.isNotEmpty) {
                                                  setState(() {
                                                    newRePasswordEmpty = false;
                                                    newRePasswordChanged = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    newRePasswordChanged = true;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Current Password
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 18.0, 8.0, 8.0),
                      child: confirmIdentity(widget.account.provider),
                    ),
                  ),
                  //Save button
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 25.0, right: 25.0),
                      child: TextButton(
                        onPressed: () async {
                          if (_settingsFormKey.currentState!.validate()) {
                            widget.account.provider == "Email"
                                ? await checkPassword(passwordController.text)
                                : null;
                            if (correctPass) {
                              _settingsFormKey.currentState!.save();
                              bool success = await Firestore()
                                      .updateAccountData(
                                          uid: widget.uid,
                                          newUser: false,
                                          accountData: {
                                        "firstName": firstName,
                                        "middleName": middleName,
                                        "lastName": lastName
                                      }) ==
                                  null;
                              bool emailSuccess = true;
                              bool newPasswordSuccess = true;
                              String? emailReturn;
                              String? newPasswordReturn;
                              if (newPasswordChanged) {
                                newPasswordReturn =
                                    await Auth().updatePassword(newPassword!);
                                newPasswordSuccess = newPasswordReturn == null;
                                success = success & newPasswordSuccess;
                              }

                              if (emailChanged) {
                                emailReturn =
                                    await Auth().updateEmailData(email!);
                                emailSuccess = emailReturn == null;
                                success = success & emailSuccess;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: const Duration(seconds: 10),
                                        content: Text('${"email_sent".tr}...')),
                                  );
                                }
                              }
                              if (success) {
                                print(
                                    "$firstName $middleName $lastName $email $newPassword $newRePassword");
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${"saving".tr}...')),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('${"next_load".tr}...')),
                                );
                              } else if (!newPasswordSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('${newPasswordReturn!.tr}...')),
                                );
                              }
                            } else {
                              setState(() {
                                criticalValids["password"] = false;
                              });
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            checkingPassState
                                ? swatchList[selectedTheme][3]
                                : swatchList[selectedTheme][0],
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  (height / 8) * 0.75 * 0.35),
                              //side: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: height / 16 > 55 ? height / 16 : 55,
                          child: Center(
                            child: Text(
                              checkingPassState
                                  ? "${"checking_pass".tr}..."
                                  : "save_option".tr,
                              style: TextStyle(
                                fontSize: (height / 8) * 0.75 / 3,
                                color: swatchList[selectedTheme][2],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Delete Account
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => swatchList[selectedTheme][1]
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            "delete_acc".tr,
                            style: TextStyle(
                              fontSize: (height / 8) * 0.75 / 3,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool changesMade() {
    if (firstNameChanged == false &&
        lastNameChanged == false &&
        middleNameChanged == false &&
        emailChanged == false &&
        newPasswordChanged == false &&
        newRePasswordChanged == false) {
      return false;
    }
    return true;
  }

  _showConfirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: swatchList[selectedTheme][2],
          title: Text(
            "leave".tr,
            style: TextStyle(
              fontSize: (height / 8) * 0.75 / 3,
              color: swatchList[selectedTheme][4],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "made_changes".tr,
                  style: TextStyle(
                    fontSize: (height / 8) * 0.75 / 3,
                    color: swatchList[selectedTheme][6],
                  ),
                ),
                Text(
                  "save_title".tr,
                  style: TextStyle(
                    fontSize: (height / 8) * 0.75 / 3,
                    color: swatchList[selectedTheme][6],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "cancel_option".tr,
                style: TextStyle(
                  fontSize: (height / 8) * 0.75 / 3,
                  color: swatchList[selectedTheme][0],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "unsave_option".tr,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName("/"));
              },
            ),
            TextButton(
              style: const ButtonStyle(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: swatchList[selectedTheme][0],
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                        Radius.circular((height / 8) * 0.9 * 0.5 / 3))),
                child: Padding(
                  padding: EdgeInsets.all((height / 8) * 0.9 * 0.5 / 3),
                  child: Text(
                    "save_option".tr,
                    style: TextStyle(
                      fontSize: (height / 8) * 0.75 / 3,
                      color: swatchList[selectedTheme][2],
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                if (_settingsFormKey.currentState!.validate()) {
                  widget.account.provider == "Email"
                      ? await checkPassword(passwordController.text)
                      : null;
                  if (correctPass) {
                    _settingsFormKey.currentState!.save();
                    bool success = await Firestore().updateAccountData(
                            uid: widget.uid,
                            newUser: false,
                            accountData: {
                              "firstName": firstName,
                              "middleName": middleName,
                              "lastName": lastName
                            }) ==
                        null;
                    bool emailSuccess = true;
                    bool newPasswordSuccess = true;
                    String? emailReturn;
                    String? newPasswordReturn;
                    if (newPasswordChanged) {
                      newPasswordReturn =
                          await Auth().updatePassword(newPassword!);
                      newPasswordSuccess = newPasswordReturn == null;
                      success = success & newPasswordSuccess;
                    }

                    if (emailChanged) {
                      emailReturn = await Auth().updateEmailData(email!);
                      emailSuccess = emailReturn == null;
                      success = success & emailSuccess;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${"email_sent".tr}...')),
                        );
                      }
                    }
                    if (success) {
                      print(
                          "$firstName $middleName $lastName $email $newPassword $newRePassword");
                      Navigator.of(context).popUntil(ModalRoute.withName("/"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${"saving".tr}...')),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${"next_load".tr}...')),
                      );
                    } else if (!newPasswordSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${newPasswordReturn!.tr}...')),
                      );
                    }
                  } else {
                    setState(() {
                      criticalValids["password"] = false;
                    });
                    Navigator.of(context).pop();
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool correctPass = false;
  Future<void> checkPassword(String value) async {
    setState(() {
      checkingPassState = true;
    });
    correctPass = await Auth().passwordIsCorrect(value) ?? false;
    setState(() {
      checkingPassState = false;
    });
  }

  confirmIdentity(String provider) {
    switch (provider) {
      case "Google":
        {
          return GestureDetector(
            onTap: () async {
              setState(() {
                checkingPassState = true;
              });
              bool authenticated =
                  await Auth().confirmWithGoogle(widget.account.email);
              setState(() {
                checkingPassState = false;
                correctPass = authenticated;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: correctPass ? Colors.blue : Colors.red,
                      width: 2.5),
                  borderRadius:
                      BorderRadius.circular((height / 12) * 0.75 * 0.35),
                ),
                child: Row(
                  children: [
                    //Icon
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.45,
                        widthFactor: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            backgroundImage: Image.asset("google.png").image,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    //Text
                    Expanded(
                      flex: 5,
                      child: FractionallySizedBox(
                        heightFactor: 0.35,
                        widthFactor: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: RichText(
                            text: TextSpan(
                              text: "${"confirm_changes".tr} ${"with".tr} ",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      case "Facebook":
        {
          return GestureDetector(
            onTap: () async {
              setState(() {
                checkingPassState = true;
              });
              bool authenticated =
                  await Auth().confirmWithFacebook(widget.account.email);
              setState(() {
                checkingPassState = false;
                correctPass = authenticated;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 66, 103, 178),
                  border: Border.all(
                      width: 2.0,
                      color: correctPass ? Colors.transparent : Colors.red),
                  borderRadius:
                      BorderRadius.circular((height / 12) * 0.75 * 0.35),
                ),
                child: Row(
                  children: [
                    //Icon
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.45,
                        widthFactor: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            backgroundImage: Image.asset("facebook.png").image,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    //Text
                    Expanded(
                      flex: 5,
                      child: FractionallySizedBox(
                        heightFactor: 0.35,
                        widthFactor: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: RichText(
                            text: TextSpan(
                              text: "${"confirm_changes".tr} ${"with".tr} ",
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Facebook",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      default:
        {
          return Container(
            decoration: BoxDecoration(
              color: swatchList[selectedTheme][3],
              borderRadius:
                  BorderRadius.all(Radius.circular((height / 8) * 0.75 * 0.35)),
              border: Border.all(
                width: 2.0,
                color: swatchList[selectedTheme][3],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "${"your_pass".tr}:",
                          softWrap: false,
                          style: TextStyle(
                            fontSize: (height / 8) * 0.75 / 3,
                            fontWeight: FontWeight.w600,
                            color: criticalValids["password"] == true
                                ? swatchList[selectedTheme][4]
                                : Colors.red,
                          ),
                        ),
                      )),
                  const SizedBox(width: 10.0),
                  Flexible(
                    flex: 7,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: (height / 8) * 0.75 / 3,
                        color: swatchList[selectedTheme][4],
                      ),
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(fontSize: 0.01),
                        border: InputBorder.none,
                        isDense: true,
                        hintText: "enter_yp".tr,
                        hintStyle: TextStyle(
                          fontSize: (height / 8) * 0.75 / 3,
                          color: swatchList[selectedTheme][5],
                        ),
                        suffixIcon: !passwordEmpty
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    passwordController.clear();
                                    passwordEmpty = true;
                                    criticalValids["password"] = false;
                                  });
                                },
                                child: const Icon(Icons.close_rounded),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 8) {
                            return "Invalid password!";
                          } else {
                            return null;
                          }
                        }
                        return "Enter your account's password first!";
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            passwordEmpty = false;
                          });
                          if (value.toString().length >= 8) {
                            setState(() {
                              criticalValids["password"] = true;
                            });
                          } else {
                            setState(() {
                              criticalValids["password"] = false;
                            });
                          }
                        } else {
                          setState(() {
                            passwordEmpty = true;
                            criticalValids["password"] = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    }
  }
}
