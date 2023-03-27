import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meak/Models/member.dart';
import 'package:meak/Models/profile.dart';
import 'package:meak/View/home.dart';
import 'package:meak/View/security_settings.dart';
import 'package:meak/Utils/Services/auth.dart';
import 'package:meak/Utils/Services/firestore.dart';
import 'package:meak/Utils/Services/storage.dart';
import 'package:meak/main.dart';
import 'package:meak/Utils/themes.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key, required this.account, this.uid});
  final String? uid;
  Profile account;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

late Profile argAccount;

enum NameOrder { lastNameFirst, firstNameFirst }

class _SettingsScreenState extends State<SettingsScreen> {
  int selectedTheme = 0;
  int selectedThemebak = 0;
  int selectionIndex = 0;

  bool appNots = true;
  bool msgNots = true;
  bool unchanged = false;
  bool appNotsbak = true;
  bool msgNotsbak = true;

  bool circleAvatarHighlighted = false;
  bool selectionActive = false;
  bool? showMiddleName = true;
  bool? firstNameFirst = true;
  bool? showMiddleNamebak = true;

  late String selectedLangBak;

  List<String> languages = ["English", "Français"];
  List<Member> membersList = members;
  List<bool> selection = [];

  Map<String, String> languageLocales = {
    "English": 'en_US',
    "Français": 'fr_FR'
  };

  Map<String, String> abvLocales = {"EN": 'en_US', "FR": 'fr_FR'};

  NameOrder? _nameOrderValue;
  NameOrder? _nameOrderValuebak;

  late String langValue;

  late double height;
  late double width;

  late SharedPreferences prefs;

  @override
  void initState() {
    init();
    argAccount = widget.account;
    selectedLangBak = selectedLang;
    super.initState();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    selectedTheme = prefs.getInt("selectedTheme") ?? defaultTheme;
    selectedThemebak = selectedTheme;
    appNots = prefs.getBool("App_Not") ?? defaultNots["App_Not"]!;
    appNotsbak = appNots;
    msgNots = prefs.getBool("Chat_Not") ?? defaultNots["Chat_Not"]!;
    msgNotsbak = msgNots;
    showMiddleName =
        prefs.getBool("showMiddleName") ?? widget.account.showMiddleName;
    showMiddleNamebak = showMiddleName;
    firstNameFirst =
        prefs.getBool("firstNameFirst") ?? widget.account.firstNameFirst;
    _nameOrderValue =
        firstNameFirst! ? NameOrder.firstNameFirst : NameOrder.lastNameFirst;
    _nameOrderValuebak = _nameOrderValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Locale? appLocale = Get.locale;
    languageLocales.forEach((key, value) {
      if (appLocale != null) {
        if (value == appLocale.toString()) {
          langValue = key;
        }
      }
    });
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: Container(
        color: swatchList[selectedTheme][2],
        height: height,
        width: width,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Back button
              Expanded(
                  child: FractionallySizedBox(
                heightFactor: 0.5,
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomLeft,
                  child: InkWell(
                    onTap: () {
                      unchanged = appNots == appNotsbak &&
                          msgNots == msgNotsbak &&
                          selectedTheme == selectedThemebak &&
                          showMiddleName == showMiddleNamebak &&
                          _nameOrderValue == _nameOrderValuebak &&
                          selectedLangBak == selectedLang;
                      !unchanged
                          ? _showConfirmDialog(widget.uid!)
                          : Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: swatchList[selectedTheme][0],
                      child: Icon(Icons.arrow_back_ios_rounded,
                          color: swatchList[selectedTheme][2]),
                    ),
                  ),
                ),
              )),
              //Settings heading
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.55,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "settings".tr,
                      style: TextStyle(
                        color: swatchList[selectedTheme][0],
                        fontWeight: FontWeight.w700,
                        fontSize: 2.0 * (height * 0.01),
                      ),
                    ),
                  ),
                ),
              ),
              //Account Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Title
                    Expanded(
                      flex: 5,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_person_outlined,
                                color: swatchList[selectedTheme][0],
                              ),
                              Text(
                                " ${"account".tr}",
                                style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    //1st Option
                    Expanded(
                      flex: 4,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: InkWell(
                          onTap: () {
                            showProfileSettings(context, widget.uid!);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "edt_profile".tr,
                                  style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.navigate_next_rounded,
                                  color: swatchList[selectedTheme][4],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //2nd Option
                    Expanded(
                      flex: 4,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Security(
                                    uid: widget.uid!,
                                    account: widget.account)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "account_settings".tr,
                                  style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.navigate_next_rounded,
                                  color: swatchList[selectedTheme][4],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //3rd Option
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: () {
                          showFamilySettings();
                        },
                        child: FractionallySizedBox(
                          heightFactor: 0.85,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "family".tr,
                                  style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.navigate_next_rounded,
                                  color: swatchList[selectedTheme][4],
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
              SizedBox(height: (height * 8) / 171),
              //Notifications Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Title
                    Expanded(
                      flex: 5,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_notifications_outlined,
                                color: swatchList[selectedTheme][0],
                              ),
                              Text(
                                " ${"notifications".tr}",
                                style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    //1st Option
                    Expanded(
                      flex: 4,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                "app_notifications".tr,
                                style: TextStyle(
                                  color: swatchList[selectedTheme][4],
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Transform.scale(
                                scale: 1.75,
                                child: Switch.adaptive(
                                    activeColor: swatchList[selectedTheme][0],
                                    value: appNots,
                                    onChanged: (editValue) => setState(() {
                                          if (editValue != appNots) {
                                            appNots = editValue;
                                          }
                                        })),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //2nd Option
                    Expanded(
                      flex: 4,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                "chat_notifications".tr,
                                style: TextStyle(
                                  color: swatchList[selectedTheme][4],
                                ),
                              ),
                            ),
                            FittedBox(
                                fit: BoxFit.contain,
                                child: Transform.scale(
                                  scale: 1.75,
                                  child: Switch.adaptive(
                                      value: msgNots,
                                      activeColor: swatchList[selectedTheme][0],
                                      onChanged: (editValue) => setState(() {
                                            if (editValue != msgNots) {
                                              msgNots = editValue;
                                            }
                                          })),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(flex: 4, child: SizedBox())
                  ],
                ),
              ),
              //More Settings Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Title
                    Expanded(
                      flex: 5,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_home_outlined,
                                color: swatchList[selectedTheme][0],
                              ),
                              Text(
                                " ${"more".tr}",
                                style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    //1st Option
                    Expanded(
                      flex: 4,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                "${"language".tr}:",
                                style: TextStyle(
                                  color: swatchList[selectedTheme][4],
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  icon: const SizedBox.shrink(),
                                  dropdownColor: swatchList[selectedTheme][0],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          (height / 12) * 0.75 * 0.5)),
                                  items: languages
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          color: swatchList[selectedTheme][2],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  selectedItemBuilder: (_) {
                                    return languages
                                        .map((e) => Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [4],
                                                ),
                                              ),
                                            ))
                                        .toList();
                                  },
                                  value: langValue,
                                  onChanged: (value) async {
                                    if (value != langValue) {
                                      bool? save = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                swatchList[selectedTheme][2],
                                            title: Text(
                                              "change_lang".tr,
                                              style: TextStyle(
                                                color: swatchList[selectedTheme]
                                                    [4],
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    "this_lang".tr,
                                                    style: TextStyle(
                                                      color: swatchList[
                                                          selectedTheme][6],
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
                                                    color: swatchList[
                                                        selectedTheme][5],
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                              ),
                                              TextButton(
                                                style: const ButtonStyle(
                                                  splashFactory:
                                                      NoSplash.splashFactory,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: swatchList[
                                                          selectedTheme][0],
                                                      border: Border.all(
                                                          color: Colors
                                                              .transparent),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  (height / 8) *
                                                                      0.9 *
                                                                      0.5 /
                                                                      3))),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        (height / 8) *
                                                            0.9 *
                                                            0.5 /
                                                            3),
                                                    child: Text(
                                                      "save_option".tr,
                                                      style: TextStyle(
                                                        color: swatchList[
                                                            selectedTheme][2],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (save != null) {
                                        if (save) {
                                          var locale =
                                              Locale(languageLocales[value]!);
                                          Get.updateLocale(locale);
                                          selectedLang = value!
                                              .substring(0, 2)
                                              .toUpperCase();
                                        }
                                      }
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //2nd Option
                    Expanded(
                      flex: 8,
                      child: FractionallySizedBox(
                        heightFactor: 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FractionallySizedBox(
                              heightFactor: 0.4,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "${"theme".tr}: ",
                                  style: TextStyle(
                                    color: swatchList[selectedTheme][4],
                                  ),
                                ),
                              ),
                            ),
                            //Theme options
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return FittedBox(
                                    fit: BoxFit.contain,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: selectedTheme == index
                                              ? swatchList[selectedTheme][5]
                                                  .withOpacity(0.2)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular((height / 8) *
                                                  0.9 *
                                                  0.5 /
                                                  3))),
                                      child: InkWell(
                                        onTap: () async {
                                          prefs = await SharedPreferences
                                              .getInstance();
                                          setState(() {
                                            if (selectedTheme != index) {
                                              selectedTheme = index;
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Tooltip(
                                            message: namedThemes.keys
                                                .elementAt(index),
                                            child: SizedBox(
                                              width: width / 5,
                                              height: height / 12,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: height / 12 / 5,
                                                    width: width / 5 / 3,
                                                    color: swatchList[index][2],
                                                  ),
                                                  Container(
                                                    height: height / 12 / 5,
                                                    width: width / 5 / 3,
                                                    color: swatchList[index][0],
                                                  ),
                                                  Container(
                                                    height: height / 12 / 5,
                                                    width: width / 5 / 3,
                                                    color: swatchList[index][1],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: namedThemes.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const Expanded(flex: 4, child: SizedBox())
                  ],
                ),
              ),
              //Log out button
              Expanded(
                child: InkWell(
                  onTap: () async {
                    bool? abort = await _showConfirmDialog(widget.uid!);
                    if (abort == null || !abort) {
                      await Auth().logOut();
                      logInSignUpMenuInstance.clearInputs();
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    }
                  },
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.exit_to_app_rounded,
                            color: Colors.red,
                          ),
                          Text(
                            " ${"log_Out".tr}",
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String uid) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: swatchList[selectedTheme][2],
          title: Text(
            "leave".tr,
            style: TextStyle(
              color: swatchList[selectedTheme][4],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "made_changes".tr,
                  style: TextStyle(
                    color: swatchList[selectedTheme][6],
                  ),
                ),
                Text(
                  "save_title".tr,
                  style: TextStyle(
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
                  color: swatchList[selectedTheme][0],
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
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
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
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
                      color: swatchList[selectedTheme][2],
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                prefs.setBool("App_Not", appNots);
                prefs.setBool("Chat_Not", msgNots);
                prefs.setInt("selectedTheme", selectedTheme);
                prefs.setBool(
                    "firstNameFirst",
                    _nameOrderValue! == NameOrder.firstNameFirst
                        ? true
                        : false);
                prefs.setBool("showMiddleName", showMiddleName!);
                String? output = await Firestore().updateUserPreferences(
                  uid: uid,
                  appNots: appNots,
                  msgNots: msgNots,
                  selectedTheme: selectedTheme,
                  firstNameFirst: _nameOrderValue! == NameOrder.firstNameFirst
                      ? true
                      : false,
                  showMiddleName: showMiddleName,
                  lang: abvLocales[selectedLang],
                );
                output != null
                    ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("error_unknown".tr),
                      ))
                    : null;
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
              },
            ),
          ],
        );
      },
    );
  }

  showProfileSettings(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular((height / 8) / 3),
      )),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              maxChildSize: 1,
              minChildSize: 0.3,
              builder: ((context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  primary: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Leading Icon
                      Container(
                        width: width / 6,
                        height: height * 0.015,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.all(
                              Radius.circular((height / 8) / 3)),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      //Bottom Sheet Content
                      Container(
                        height: height * 0.9 - (height * 0.015 + height * 0.03),
                        width: width,
                        decoration: BoxDecoration(
                          color: swatchList[selectedTheme][2],
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(height / 8) * 0.5),
                        ),
                        //Content
                        child: Column(
                          children: [
                            //Title
                            Expanded(
                              flex: 3,
                              child: FractionallySizedBox(
                                heightFactor: 0.3,
                                widthFactor: 0.8,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "profile_settings".tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: swatchList[selectedTheme][4],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Profile Picture
                            Expanded(
                                flex: 4,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 20,
                                              color: Colors.black12,
                                              spreadRadius: 7.5)
                                        ],
                                      ),
                                      child: FractionallySizedBox(
                                        heightFactor: 1,
                                        widthFactor: 1,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                swatchList[selectedTheme][1],
                                            backgroundImage: widget
                                                            .account.pic !=
                                                        null &&
                                                    widget
                                                        .account.pic!.isNotEmpty
                                                ? NetworkImage(
                                                    widget.account.pic!)
                                                : const AssetImage(
                                                        "assets/default.png")
                                                    as ImageProvider,
                                          ),
                                        ),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      heightFactor: 1,
                                      widthFactor: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                              circleAvatarHighlighted
                                                  ? 0.3
                                                  : 0.0),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      heightFactor: 1,
                                      widthFactor: 1,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: CircularProgressIndicator(
                                            backgroundColor:
                                                swatchList[selectedTheme][3],
                                            color: swatchList[selectedTheme][0],
                                            strokeWidth: 1.0,
                                            value: progress),
                                      ),
                                    ),
                                    circleAvatarHighlighted
                                        ? const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          )
                                        : const SizedBox(),
                                    MouseRegion(
                                      onEnter: ((event) {
                                        setState(() {
                                          circleAvatarHighlighted = true;
                                        });
                                      }),
                                      onExit: ((event) {
                                        setState(() {
                                          circleAvatarHighlighted = false;
                                        });
                                      }),
                                      child: GestureDetector(
                                        onTap: () =>
                                            showPickImageSheet(setState),
                                        onTapDown: ((details) {
                                          setState(() {
                                            circleAvatarHighlighted = true;
                                          });
                                        }),
                                        onTapUp: ((details) {
                                          setState(() {
                                            circleAvatarHighlighted = false;
                                          });
                                        }),
                                        child: FractionallySizedBox(
                                          heightFactor: 1,
                                          widthFactor: 1,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            //Note
                            Expanded(
                              child: FractionallySizedBox(
                                heightFactor: 0.5,
                                alignment: Alignment.bottomCenter,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "tap_remove".tr,
                                    style: TextStyle(
                                      color: swatchList[selectedTheme][5],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Full Name
                            Expanded(
                              flex: 3,
                              child: FractionallySizedBox(
                                heightFactor: 0.9,
                                widthFactor: 0.8,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    widget.account.middleName != null
                                        ? "${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.firstName : widget.account.lastName} ${showMiddleName! ? widget.account.middleName : ""} ${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.lastName : widget.account.firstName}"
                                        : "${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.firstName : widget.account.lastName} ${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.lastName : widget.account.firstName}",
                                    style: TextStyle(
                                      color: swatchList[selectedTheme][4],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            //Name Order
                            Expanded(
                              flex: 2,
                              child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "${"name_order".tr}: ",
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        value: NameOrder.firstNameFirst,
                                        groupValue: _nameOrderValue,
                                        title: Text(
                                          "${widget.account.firstName} ${widget.account.lastName}",
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                        activeColor: swatchList[selectedTheme]
                                            [0],
                                        onChanged: ((value) {
                                          setState(() {
                                            if (_nameOrderValue != value) {
                                              _nameOrderValue = value;
                                            }
                                          });
                                        }),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        value: NameOrder.lastNameFirst,
                                        groupValue: _nameOrderValue,
                                        title: Text(
                                          "${widget.account.lastName} ${widget.account.firstName}",
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                        activeColor: swatchList[selectedTheme]
                                            [0],
                                        onChanged: ((value) {
                                          setState(() {
                                            if (_nameOrderValue != value) {
                                              _nameOrderValue = value;
                                            }
                                          });
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //Show middle name
                            Expanded(
                              flex: 2,
                              child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "${"middle_name".tr}: ",
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        value: true,
                                        groupValue: showMiddleName,
                                        title: Text(
                                          "show".tr,
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                        activeColor: swatchList[selectedTheme]
                                            [0],
                                        onChanged: ((value) {
                                          setState(() {
                                            if (showMiddleName != value) {
                                              showMiddleName = value;
                                            }
                                          });
                                        }),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        value: false,
                                        groupValue: showMiddleName,
                                        title: Text(
                                          "!show".tr,
                                          style: TextStyle(
                                            color: swatchList[selectedTheme][4],
                                          ),
                                        ),
                                        activeColor: swatchList[selectedTheme]
                                            [0],
                                        onChanged: ((value) {
                                          setState(() {
                                            if (showMiddleName != value) {
                                              showMiddleName = value;
                                            }
                                          });
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }));
        });
      },
    );
  }

  UploadTask? uploading;
  double progress = 0;

  showPickImageSheet(void Function(void Function()) setState) {
    setState(() {
      progress = 0;
    });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: height / 4,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //New picture option
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("${"saving".tr}..."),
                      ));
                      if (kIsWeb) {
                        var data = await Storage().pickImageWeb();
                        if (data != null) {
                          try {
                            uploading = Storage().uploadPictureWithByte(
                                widget.account.uid, data);
                            uploading!.asStream().listen((snapshot) {
                              setState(() {
                                progress = snapshot.bytesTransferred /
                                    snapshot.totalBytes;
                              });
                            }).onDone(() async {
                              Map<String, dynamic> accountData =
                                  widget.account.toMap();
                              accountData["imgURL"] = await Storage()
                                  .getPicUrl(widget.account.uid, data);
                              Firestore().updateAccountData(
                                  uid: widget.account.uid,
                                  accountData: accountData,
                                  newUser: false);
                            });

                            /// final snapshot = uploading!.asStream()

                            /// final downloadUrl =
                            ///     await snapshot.ref.getDownloadURL();
                          } catch (e) {
                            print("Error: $e");
                          }
                        }
                      } else {
                        var file = await Storage()
                            .pickImagePlatform(ImageSource.gallery);
                        if (file != null) {
                          uploading = await Storage()
                              .uploadPictureWithFile(widget.account.uid, file);

                          uploading!.asStream().listen((snapshot) {
                            setState(() {
                              progress = snapshot.bytesTransferred /
                                  snapshot.totalBytes;
                            });
                          }).onDone(() async {
                            Map<String, dynamic> accountData =
                                widget.account.toMap();
                            accountData["imgURL"] = await Storage()
                                .getPicUrl(widget.account.uid, file);
                            Firestore().updateAccountData(
                                uid: widget.account.uid,
                                accountData: accountData,
                                newUser: false);
                          });
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.edit,
                                    color: Colors.transparent))),
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.edit))),
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.edit,
                                    color: Colors.transparent))),
                        FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text("choose_pic".tr))),
                      ],
                    ),
                  ),
                ),
                //Remove option
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      print("Remove Pic");
                      String? result = await Firestore().updateAccountData(
                          uid: widget.account.uid,
                          accountData: {
                            "lang": languageLocales[langValue],
                            "middleName": widget.account.middleName,
                            "selectedTheme": selectedTheme,
                            "App_Not": appNots,
                            "Chat_Not": msgNots,
                            "showMiddleName": widget.account.showMiddleName,
                            "firstNameFirst": widget.account.firstNameFirst,
                            "imgURL": "",
                          });
                      if (result == null) {
                        setState(() {
                          widget.account.pic = null;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${"saving".tr}..."),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("next_load".tr),
                        ));
                      } else {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result.tr),
                        ));
                      }
                    },
                    child: Row(
                      children: [
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.close,
                                    color: Colors.transparent))),
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.close))),
                        const FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Icon(Icons.close,
                                    color: Colors.transparent))),
                        FractionallySizedBox(
                            heightFactor: 0.35,
                            child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text("remove_pic".tr))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  showFamilySettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              height: height / 2,
              width: width * 0.9,
              decoration: BoxDecoration(
                color: swatchList[selectedTheme][3],
                borderRadius: BorderRadius.all(
                    Radius.circular((height / 12) * 0.75 * 0.5)),
                border: Border.all(color: Colors.transparent),
              ),
              child: Column(
                children: [
                  //Title
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FractionallySizedBox(
                          heightFactor: 0.5,
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              "${"family_settings".tr} ",
                              style: TextStyle(
                                  color: swatchList[selectedTheme][4],
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: "delete_info".tr,
                          child: FractionallySizedBox(
                            heightFactor: 0.4,
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: CircleAvatar(
                                backgroundColor: swatchList[selectedTheme][2],
                                child: Icon(
                                  Icons.question_mark_rounded,
                                  color: swatchList[selectedTheme][3],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Family Members
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: swatchList[selectedTheme][2],
                        borderRadius: BorderRadius.all(
                            Radius.circular((height / 12) * 0.75 * 0.5)),
                        border: Border.all(
                            color: swatchList[selectedTheme][5], width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                            Radius.circular((height / 12) * 0.75 * 0.5)),
                        child: Stack(
                          children: [
                            ListView.separated(
                              itemBuilder: (context, index) {
                                selection.add(false);
                                if (index == 0) {
                                  return SizedBox(
                                    height: ((6 / 7) * height / 2 - 4) / 4,
                                    child: familyMemberTile(
                                        true,
                                        widget.account.middleName != null
                                            ? "${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.firstName : widget.account.lastName} ${showMiddleName! ? widget.account.middleName : ""} ${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.lastName : widget.account.firstName}"
                                            : "${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.firstName : widget.account.lastName} ${_nameOrderValue == NameOrder.firstNameFirst ? widget.account.lastName : widget.account.firstName}",
                                        widget.account.pic,
                                        index,
                                        widget.account.isOwner,
                                        setDialogState),
                                  );
                                }
                                if (index == membersList.length + 1) {
                                  return SizedBox(
                                    height: ((6 / 7) * height / 2 - 4) / 4,
                                  );
                                }

                                if (membersList[index - 1].uid ==
                                    widget.account.uid) {
                                  return const SizedBox();
                                }

                                return SizedBox(
                                  height: ((6 / 7) * height / 2 - 4) / 4,
                                  child: familyMemberTile(
                                      false,
                                      membersList[index - 1].name,
                                      membersList[index - 1].pic,
                                      index,
                                      membersList[index - 1].isOwner,
                                      setDialogState),
                                );
                              },
                              itemCount: membersList.length + 2,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                if (index == 0) {
                                  return Divider(
                                      height: 1,
                                      color: swatchList[selectedTheme][5]);
                                }
                                if (membersList[index - 1].uid ==
                                        widget.account.uid ||
                                    index == membersList.length + 1) {
                                  return const SizedBox();
                                }
                                return Divider(
                                    height: 1,
                                    color: swatchList[selectedTheme][5]);
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: ((6 / 7) * height / 2 - 4) / 4,
                                  width: width * 0.9 - 4,
                                  decoration: BoxDecoration(
                                      color: selectionActive
                                          ? swatchList[selectedTheme][0]
                                          : Colors.red,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(
                                              (height / 8) * 0.9 * 0.5 / 3))),
                                  child: FractionallySizedBox(
                                    heightFactor: 0.35,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        selectionActive
                                            ? "remove".tr
                                            : "leave_button".tr,
                                        style: TextStyle(
                                            color: selectionActive
                                                ? swatchList[selectedTheme][2]
                                                : Colors.white,
                                            fontWeight: FontWeight.w500),
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
                ],
              ),
            ),
          );
        });
      },
    );
  }

  familyMemberTile(bool you, String name, String? pic, int index, bool isOwner,
      void Function(void Function()) setState) {
    return GestureDetector(
      onLongPress: isOwner
          ? null
          : () {
              if (!selectionActive) {
                setState(() {
                  selection[index] = true;
                  selectionActive = true;
                  selectionIndex = 1;
                });
              }
            },
      onTap: isOwner
          ? null
          : () {
              if (selectionActive && selectionIndex > 0) {
                setState(() {
                  selection[index] = !selection[index];
                  selection[index] ? selectionIndex += 1 : selectionIndex -= 1;
                });
              }
              if (selectionIndex == 0 && selectionActive && !selection[index]) {
                setState(() {
                  selection[index] = false;
                  selectionActive = false;
                  selectionIndex = 0;
                });
              }
            },
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  widthFactor: 0.8,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CircleAvatar(
                      backgroundImage: pic != null
                          ? NetworkImage(pic)
                          : const AssetImage("assets/default.png")
                              as ImageProvider,
                      backgroundColor: swatchList[selectedTheme][5],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: isOwner
                          ? FractionallySizedBox(
                              heightFactor: 0.9,
                              alignment: Alignment.bottomLeft,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  " ${"owner".tr}",
                                  style: TextStyle(
                                    color: swatchList[selectedTheme][0],
                                  ),
                                ),
                              ),
                            )
                          : you
                              ? FractionallySizedBox(
                                  heightFactor: 0.9,
                                  alignment: Alignment.bottomLeft,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      " ${"you".tr}",
                                      style: TextStyle(
                                        color: swatchList[selectedTheme][0],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                    ),
                    Expanded(
                      flex: 2,
                      child: FractionallySizedBox(
                        heightFactor: 0.75,
                        widthFactor: 0.6,
                        alignment: Alignment.topLeft,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.topLeft,
                          child: Text(
                            " $name",
                            style: TextStyle(
                              color: swatchList[selectedTheme][4],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: ((6 / 7) * height / 2 - 4) / 4,
              width: ((6 / 7) * height / 2 - 4) / 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: selectionActive
                      ? Alignment.center
                      : Alignment.centerRight,
                  end:
                      selectionActive ? Alignment.centerLeft : Alignment.center,
                  colors: [
                    swatchList[selectedTheme][2],
                    swatchList[selectedTheme][2].withOpacity(0.0),
                  ],
                ),
              ),
              child: selectionActive && !isOwner
                  ? Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: FractionallySizedBox(
                        heightFactor: 0.5,
                        widthFactor: 0.5,
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                              selection[index]
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: swatchList[selectedTheme][1]),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
