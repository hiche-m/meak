import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meak/Models/item.dart';
import 'package:meak/Models/member.dart';
import 'package:meak/Models/profile.dart';
import 'package:meak/View/chat.dart';
import 'package:meak/View/search.dart';
import 'package:meak/View/settings.dart';
import 'package:meak/Utils/Services/auth.dart';
import 'package:meak/Utils/Services/firestore.dart' as fst;
import 'package:meak/Components/build_add_member.dart';
import 'package:meak/Components/build_login_signup.dart';
import 'package:meak/Utils/lang/dates.dart';
import 'package:meak/main.dart';
import 'package:meak/Utils/themes.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

final _addFormKey = GlobalKey<FormState>();
final _editFormKey = GlobalKey<FormState>();
final _listKey = GlobalKey<AnimatedListState>();

int selectedTheme = 0;
late AddMemberMenu addMenuInstance;
late LogInSignUpMenu logInSignUpMenuInstance;

class _HomeState extends State<Home> {
  //bool userLoggedIn = widget.userLoggedIn;
  String dropDownValue = "Number";
  String editDropDownValue = "Number";
  String? profilePictureUrl;
  String? _itemLabel;
  String? _editItemLabel;
  String? _itemPrefix = "";
  String? _editItemPrefix = "";

  List<Member> membersList = members;
  List<Item> itemsList = [
    Item(
        name: 'Hlib',
        quantity: 1,
        addDate: DateTime.parse("20221107T164023"),
        senderId: "0",
        type: 2,
        extension: "l"),
    Item(
        name: 'Bayd',
        addDate: DateTime.parse("20221108T122301"),
        senderId: "1",
        quantity: 6),
    Item(
        name: 'Dhan',
        addDate: DateTime.parse("20221107T200559"),
        senderId: "2",
        quantity: 500,
        type: 1,
        extension: "g"),
  ];
  List<String> itemTypeList = ["Number", "Weight", "Volume", "Container"];

  Map<String, dynamic> userPreferences = {};

  bool selectionActive = false;
  bool allSelected = false;
  bool addMenuExtra = false;
  bool editAddMenuExtra = false;
  bool addMenuActive = false;
  bool loading = false;
  bool authMenuOpen = false;
  bool offline = false;
  bool? showMiddleName = true;
  bool? firstNameFirst = true;
  late bool userLoggedIn;

  int addButtonSizeFactor = 1;
  int addMenuTextColorFactor = 0;
  int? _itemPPB = 1;
  int? _editItemPPB = 1;

  double? _itemQuantity = 1;
  double? _editItemQuantity = 1;

  final CollectionReference _accounts =
      FirebaseFirestore.instance.collection("accounts");

  Profile? account;

  SharedPreferences? prefs;

  Color? addItemColor;
  Color? editItemColor;
  late Color addIconColorFactor = swatchList[selectedTheme][2];

  final _quantityController = TextEditingController(text: "1");
  final _editQuantityController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    selectedLang = Get.locale!.languageCode.toUpperCase();
    itemsList.sort(((a, b) => a.addDate.compareTo(b.addDate)));
    addMenuInstance = AddMemberMenu();
    logInSignUpMenuInstance = LogInSignUpMenu();
    init();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      selectedTheme = prefs!.getInt("selectedTheme") ?? defaultTheme;
      showMiddleName = prefs!.getBool("showMiddleName") ?? false;
      firstNameFirst = prefs!.getBool("firstNameFirst") ?? true;
    }
    setState(() {
      addMenuInstance.selectedTheme = selectedTheme;
      logInSignUpMenuInstance.selectedTheme = selectedTheme;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
    fetchUserData(Provider.of<String?>(context, listen: true));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _editQuantityController.dispose();
    logInSignUpMenuInstance.lastNameController.dispose();
    logInSignUpMenuInstance.firstNameController.dispose();
    logInSignUpMenuInstance.newPasswordController.dispose();
    logInSignUpMenuInstance.repeatPasswordController.dispose();
    logInSignUpMenuInstance.signupEmailController.dispose();
    logInSignUpMenuInstance.loginEmailController.dispose();
    logInSignUpMenuInstance.passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? uid = Provider.of<String?>(context, listen: false);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    int c = 0;
    for (var item in itemsList) {
      item.active ? c++ : null;
    }
    c == itemsList.length && itemsList.isNotEmpty
        ? [allSelected = true, selectionActive = true]
        : allSelected = false;
    init();
    return Scaffold(
      backgroundColor: swatchList[selectedTheme][2],
      body: StatefulBuilder(builder: (context, setState) {
        return Stack(
          children: [
            GestureDetector(
              onTap: (() => setState(() {
                    if (addMenuActive) {
                      addIconColorFactor = swatchList[selectedTheme][2];
                      addMenuActive = false;
                      addButtonSizeFactor = 1;
                      addMenuTextColorFactor = 0;
                    }
                  })),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: offline ? height / 15 : 0,
                      width: width,
                      color: Colors.red,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: offline ? 1 : 0,
                        child: FractionallySizedBox(
                            heightFactor: 0.5,
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: offline
                                    ? Text(
                                        "offline_mode".tr,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : SizedBox())),
                      ),
                    ),
                    //Top Section
                    SizedBox(
                      height: height / 4,
                      width: width,
                      child: Row(
                        children: [
                          //Heading
                          Expanded(
                            flex: 3,
                            child: FractionallySizedBox(
                              heightFactor: 0.7,
                              widthFactor: 0.7,
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.75,
                                      widthFactor: 0.75,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "my_tasks".tr,
                                          style: TextStyle(
                                              color: darken(
                                                  swatchList[selectedTheme][0],
                                                  .12),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.75,
                                      widthFactor: 0.75,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          itemsList.isNotEmpty
                                              ? "${itemsList.length} ${"remaining".tr}"
                                              : "no_remaining".tr,
                                          style: TextStyle(
                                            color: darken(
                                                swatchList[selectedTheme][0],
                                                .12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Profile Button
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: userLoggedIn
                                ? AspectRatio(
                                    aspectRatio: 1,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.5,
                                      widthFactor: 0.5,
                                      //Profile Picture
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SettingsScreen(
                                                        uid: uid,
                                                        account: account!,
                                                      )));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    (height / 8) * 0.3)),
                                            image: profilePictureUrl != null &&
                                                    profilePictureUrl!
                                                        .isNotEmpty
                                                ? DecorationImage(
                                                    fit: BoxFit.contain,
                                                    image: Image.network(
                                                            profilePictureUrl!)
                                                        .image,
                                                  )
                                                : const DecorationImage(
                                                    image: AssetImage(
                                                        "assets/default.png"),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : loading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.grey.shade600,
                                        ),
                                      )
                                    : FractionallySizedBox(
                                        heightFactor: 0.75,
                                        widthFactor: 0.8,
                                        alignment: Alignment.bottomLeft,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: RichText(
                                              textAlign: TextAlign.end,
                                              text: TextSpan(
                                                  text:
                                                      '${"not_connected".tr}\n',
                                                  style: TextStyle(
                                                    color: swatchList[
                                                        selectedTheme][4],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: "log-in".tr,
                                                        style: TextStyle(
                                                          color: swatchList[
                                                              selectedTheme][0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  () async {
                                                                setState(() {
                                                                  authMenuOpen =
                                                                      true;
                                                                });
                                                                await showAuthMethode(
                                                                  context,
                                                                  height,
                                                                  width,
                                                                  true,
                                                                );
                                                                setState(() {
                                                                  authMenuOpen =
                                                                      false;
                                                                });
                                                              }),
                                                    TextSpan(
                                                      text: ' ${"or".tr} '
                                                          .toLowerCase(),
                                                      style: TextStyle(
                                                        color: swatchList[
                                                            selectedTheme][5],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                        text: "sign-up".tr,
                                                        style: TextStyle(
                                                          color: swatchList[
                                                              selectedTheme][0],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  () async {
                                                                setState(() {
                                                                  authMenuOpen =
                                                                      true;
                                                                });
                                                                await showAuthMethode(
                                                                  context,
                                                                  height,
                                                                  width,
                                                                  false,
                                                                );
                                                                setState(() {
                                                                  authMenuOpen =
                                                                      false;
                                                                });
                                                              }),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                    //Members Section
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: height / 4.5,
                        width: width,
                        decoration: BoxDecoration(
                          color: swatchList[selectedTheme][1],
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.all(
                              Radius.circular((height / 8) * 0.40)),
                        ),
                        //Elements
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40)),
                              child: CustomPaint(
                                size: Size(
                                    width,
                                    (width * 0.5)
                                        .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                                painter: RPSCustomPainter(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Heading
                                  Expanded(
                                    child: FractionallySizedBox(
                                      heightFactor: 0.75,
                                      alignment: Alignment.bottomRight,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "family".tr,
                                          style: TextStyle(
                                              color: darken(
                                                  swatchList[selectedTheme][0],
                                                  .12),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //Members count
                                  Expanded(
                                    child: FractionallySizedBox(
                                      heightFactor: 0.75,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: swatchList[selectedTheme][2],
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    (height / 8) * 0.40)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "${!userLoggedIn ? "1" : membersList.length} ${"member".tr}${!userLoggedIn || membersList.length == 1 ? "" : "s"}",
                                              style: TextStyle(
                                                color: swatchList[selectedTheme]
                                                    [0],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                  //Bottom section
                                  Expanded(
                                    child: Row(
                                      children: [
                                        //Members
                                        Expanded(
                                          flex: 3,
                                          child: ListView.builder(
                                            itemBuilder: (context, index) {
                                              if (!userLoggedIn) {
                                                if (index == 0) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 2.0),
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Tooltip(
                                                        message: "guest".tr,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              const AssetImage(
                                                                  "assets/default.png"),
                                                          backgroundColor:
                                                              swatchList[
                                                                  selectedTheme][5],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return Tooltip(
                                                  message: "join_family".tr,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        authMenuOpen = true;
                                                      });
                                                      await showAuthMethode(
                                                          context,
                                                          height,
                                                          width,
                                                          true);
                                                      setState(() {
                                                        authMenuOpen = false;
                                                      });
                                                    },
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: CircleAvatar(
                                                        backgroundColor: swatchList[
                                                                selectedTheme][4]
                                                            .withOpacity(0.75),
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          color: swatchList[
                                                              selectedTheme][2],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (index ==
                                                  membersList.length + 1) {
                                                return Tooltip(
                                                  message: "add_member".tr,
                                                  child: InkWell(
                                                    onTap: () {
                                                      addMenuInstance
                                                          .buildAddMember(
                                                              context,
                                                              height,
                                                              width);
                                                    },
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: CircleAvatar(
                                                        backgroundColor: swatchList[
                                                                selectedTheme][4]
                                                            .withOpacity(0.75),
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          color: swatchList[
                                                              selectedTheme][2],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else if (index == 0) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Tooltip(
                                                      message: account!
                                                                  .middleName !=
                                                              null
                                                          ? "${firstNameFirst! ? account!.firstName : account!.lastName} ${showMiddleName! ? account!.middleName : ""} ${firstNameFirst! ? account!.lastName : account!.firstName}"
                                                          : "${firstNameFirst! ? account!.firstName : account!.lastName} ${firstNameFirst! ? account!.lastName : account!.firstName}",
                                                      child: CircleAvatar(
                                                        backgroundImage: account!
                                                                    .pic !=
                                                                null
                                                            ? NetworkImage(
                                                                account!.pic!)
                                                            : const AssetImage(
                                                                    "assets/default.png")
                                                                as ImageProvider,
                                                        backgroundColor:
                                                            swatchList[
                                                                selectedTheme][5],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else if (membersList[index - 1]
                                                      .uid !=
                                                  account!.uid) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Tooltip(
                                                      message:
                                                          membersList[index - 1]
                                                              .name,
                                                      child: CircleAvatar(
                                                        backgroundImage: membersList[
                                                                        index -
                                                                            1]
                                                                    .pic !=
                                                                null
                                                            ? NetworkImage(
                                                                membersList[
                                                                        index -
                                                                            1]
                                                                    .pic!)
                                                            : const AssetImage(
                                                                    "assets/default.png")
                                                                as ImageProvider,
                                                        backgroundColor:
                                                            swatchList[
                                                                selectedTheme][5],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                            itemCount: userLoggedIn
                                                ? 2 + membersList.length
                                                : 2,
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                          ),
                                        ),
                                        //Date
                                        Expanded(
                                          flex: 1,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  color: darken(
                                                      swatchList[selectedTheme]
                                                          [0],
                                                      .11),
                                                ),
                                                Text(
                                                  "  ${DateTime.now().day} ${monthList[selectedLang]![DateTime.now().month]}",
                                                  style: TextStyle(
                                                    color: darken(
                                                        swatchList[
                                                            selectedTheme][0],
                                                        .11),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Items List
                    itemsList.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(
                                width / 8,
                                0,
                                width / 8,
                                height >= 35 ? (height / 8 + 5) * 2 : 35 * 2),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (allSelected) {
                                          for (var item in itemsList) {
                                            item.active = false;
                                          }
                                          selectionActive = false;
                                        } else {
                                          for (var item in itemsList) {
                                            item.active = true;
                                          }
                                          selectionActive = true;
                                        }
                                      });
                                    },
                                    child: Text(
                                      !allSelected
                                          ? "select_all".tr
                                          : "deselect_all".tr,
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: swatchList[selectedTheme][0],
                                        fontSize: (height / 8) * 0.9 * 0.5 / 3,
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedList(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  initialItemCount: itemsList.length,
                                  primary: false,
                                  key: _listKey,
                                  itemBuilder: ((context, index, animation) {
                                    return Column(
                                      children: [
                                        _buildItem(width, height, index,
                                            itemsList[index], animation),
                                        index + 1 < itemsList.length
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: (width -
                                                            (width / 8) * 2) /
                                                        4),
                                                child: const Divider(),
                                              )
                                            : const SizedBox(),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              emptyStateWidget(height, width),
                              Text(
                                "no_items".tr,
                                style: TextStyle(
                                  color: swatchList[selectedTheme][0],
                                  fontWeight: FontWeight.w900,
                                  fontSize: (height / 8) * 0.75 / 3,
                                ),
                              ),
                              Text(
                                "plus_to_add".tr,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  color: swatchList[selectedTheme][5],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: height / 6),
                            ],
                          )
                  ],
                ),
              ),
            ),
            //Bottom Bar
            GestureDetector(
              onTap: (() => setState(() {
                    if (addMenuActive) {
                      addIconColorFactor = swatchList[selectedTheme][2];
                      addMenuActive = false;
                      addButtonSizeFactor = 1;
                      addMenuTextColorFactor = 0;
                    }
                  })),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0, width / 6, 15.0),
                  child: Container(
                    width: width,
                    height: height / 8,
                    decoration: BoxDecoration(
                      color: swatchList[selectedTheme][3],
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                          Radius.circular((height / 8) * 0.40)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          15.0, 15.0, 15.0 + (height / 8) * 0.75 / 2, 15.0),
                      //Actions
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: FractionallySizedBox(
                              heightFactor: 0.6,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                //Action one
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.other_houses_rounded,
                                      color: darken(
                                          swatchList[selectedTheme][0], .12),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      "home".tr,
                                      style: TextStyle(
                                        color: darken(
                                            swatchList[selectedTheme][0], .12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //Action 2
                          Expanded(
                            flex: 1,
                            child: FractionallySizedBox(
                              heightFactor: 0.5,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SearchScreen()));
                                  },
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: swatchList[selectedTheme][4],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //Action 3
                          Expanded(
                            flex: 1,
                            child: FractionallySizedBox(
                              heightFactor: 0.5,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: InkWell(
                                  onTap: () async {
                                    userLoggedIn
                                        ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ChatScreen()))
                                        : [
                                            setState(() {
                                              authMenuOpen = true;
                                            }),
                                            await showAuthMethode(
                                                context, height, width, true),
                                            setState(() {
                                              authMenuOpen = false;
                                            })
                                          ];
                                  },
                                  child: Icon(
                                    Icons.question_answer_outlined,
                                    color: swatchList[selectedTheme][4],
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
            ),
            //Action Button
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 0, width / 6 - 0.75 * (height / 16), 15.0),
                child: GestureDetector(
                  onTap: selectionActive
                      ? () {
                          for (int index = 0;
                              index < itemsList.length;
                              index++) {
                            if (itemsList[index].active) {
                              Item removedItem = itemsList.removeAt(index);
                              AnimatedListRemovedItemBuilder builder =
                                  ((context, animation) {
                                return _buildItem(width, height, index,
                                    removedItem, animation);
                              });
                              _listKey.currentState?.removeItem(index, builder,
                                  duration: const Duration(milliseconds: 100));
                              index--;
                            }
                          }
                          setState(() {
                            selectionActive = false;
                          });
                        }
                      : () {
                          setState(() {
                            if (!addMenuActive) {
                              addIconColorFactor = Colors.transparent;
                              addMenuActive = true;
                              addButtonSizeFactor = 4;
                              addMenuTextColorFactor = 1;
                            }
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    height: height * addButtonSizeFactor / 8,
                    width: height * addButtonSizeFactor / 8,
                    child: FractionallySizedBox(
                      heightFactor: 0.75,
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: darken(swatchList[selectedTheme][0], .12),
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.all(
                              Radius.circular((height / 8) * 0.75 * 0.35)),
                        ),
                        child: !addMenuActive
                            ? FractionallySizedBox(
                                heightFactor: 0.5,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Center(
                                    child: Icon(
                                      !selectionActive || itemsList.isEmpty
                                          ? Icons.add_rounded
                                          : Icons.remove_rounded,
                                      color: addIconColorFactor,
                                    ),
                                  ),
                                ),
                              )
                            : Opacity(
                                opacity: 1.0 * addMenuTextColorFactor,
                                child: FractionallySizedBox(
                                  widthFactor: 0.9,
                                  heightFactor: 0.9,
                                  //Add Item Menu
                                  child: Form(
                                    key: _addFormKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        //First Line
                                        Expanded(
                                          flex: 6,
                                          child: FractionallySizedBox(
                                            heightFactor: 0.8,
                                            child: Row(
                                              children: [
                                                //Label
                                                Expanded(
                                                  flex: 1,
                                                  child: FractionallySizedBox(
                                                    heightFactor: 0.35,
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "${"label".tr}: ",
                                                        style: TextStyle(
                                                          color: swatchList[
                                                              selectedTheme][2],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                //Label Input
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: lighten(
                                                          swatchList[
                                                              selectedTheme][0],
                                                          .01),
                                                      border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  (height / 8) *
                                                                      0.75 *
                                                                      0.35)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2.0),
                                                      child:
                                                          FractionallySizedBox(
                                                        heightFactor: 0.9,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: TextFormField(
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .bottom,
                                                          initialValue:
                                                              _itemLabel,
                                                          autofocus: true,
                                                          maxLines: 1,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    "[0-9a-zA-Z ]"))
                                                          ],
                                                          decoration:
                                                              InputDecoration(
                                                                  errorStyle:
                                                                      const TextStyle(
                                                                          height:
                                                                              0.001),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Colors.red),
                                                                    borderRadius: BorderRadius.all(Radius.circular((height /
                                                                            12) *
                                                                        0.75 *
                                                                        0.35)),
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  prefixText:
                                                                      "  ",
                                                                  hintText:
                                                                      "item_name"
                                                                          .tr,
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: darken(
                                                                        swatchList[selectedTheme]
                                                                            [0],
                                                                        .15),
                                                                  )),
                                                          cursorColor: swatchList[
                                                              selectedTheme][2],
                                                          cursorWidth: 1.5,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            color: swatchList[
                                                                selectedTheme][5],
                                                          ),
                                                          onChanged: (value) {
                                                            _itemLabel = value;
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "";
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //Secound Line
                                        Expanded(
                                          flex: 6,
                                          child: FractionallySizedBox(
                                            heightFactor: 0.8,
                                            child: Row(
                                              children: [
                                                //Quantity
                                                Expanded(
                                                  flex: 2,
                                                  child: FractionallySizedBox(
                                                    heightFactor: 0.35,
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "${"quantity".tr}:  ",
                                                        style: TextStyle(
                                                          color: swatchList[
                                                              selectedTheme][2],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                //Quantity Input
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: lighten(
                                                          swatchList[
                                                              selectedTheme][0],
                                                          .01),
                                                      border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  (height / 8) *
                                                                      0.75 *
                                                                      0.35)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2.0),
                                                      child:
                                                          FractionallySizedBox(
                                                        heightFactor: 0.9,
                                                        child: TextFormField(
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .bottom,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          autofocus: true,
                                                          maxLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                            errorStyle:
                                                                const TextStyle(
                                                                    height:
                                                                        0.001),
                                                            errorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .red),
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(
                                                                      (height /
                                                                              12) *
                                                                          0.75 *
                                                                          0.35)),
                                                            ),
                                                            border: InputBorder
                                                                .none,
                                                            hintText: "ex: 5",
                                                            hintStyle:
                                                                TextStyle(
                                                              color: darken(
                                                                  swatchList[
                                                                      selectedTheme][0],
                                                                  .15),
                                                            ),
                                                          ),
                                                          cursorColor: swatchList[
                                                              selectedTheme][2],
                                                          cursorWidth: 1.5,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: swatchList[
                                                                selectedTheme][5],
                                                          ),
                                                          controller:
                                                              _quantityController,
                                                          onChanged: (value) {
                                                            if (value != "") {
                                                              _itemQuantity =
                                                                  double.parse(
                                                                      value);
                                                            }
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "";
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                //Right Section
                                                Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const SizedBox(
                                                          width: 2.0),
                                                      //Quantity Control buttons
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          //Increment quantity button
                                                          Expanded(
                                                              flex: 1,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  if (_itemQuantity !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      _itemQuantity =
                                                                          _itemQuantity! +
                                                                              1;
                                                                      _quantityController
                                                                              .text =
                                                                          _itemQuantity
                                                                              .toString();
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _itemQuantity =
                                                                          1;
                                                                      _quantityController
                                                                              .text =
                                                                          _itemQuantity
                                                                              .toString();
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    FractionallySizedBox(
                                                                  heightFactor:
                                                                      0.9,
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_circle_up_rounded,
                                                                      color: swatchList[
                                                                          selectedTheme][2],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                          //Decrement quantity button
                                                          Expanded(
                                                            flex: 1,
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (_itemQuantity !=
                                                                    null) {
                                                                  if (_itemQuantity! >
                                                                      1) {
                                                                    setState(
                                                                        () {
                                                                      _itemQuantity =
                                                                          _itemQuantity! -
                                                                              1;
                                                                      _quantityController
                                                                              .text =
                                                                          _itemQuantity
                                                                              .toString();
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _itemQuantity =
                                                                          1;
                                                                      _quantityController
                                                                              .text =
                                                                          "1";
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              child:
                                                                  FractionallySizedBox(
                                                                heightFactor:
                                                                    0.9,
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  child: Icon(
                                                                    Icons
                                                                        .arrow_circle_down_rounded,
                                                                    color: swatchList[
                                                                        selectedTheme][2],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      //Item Type Menu
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: lighten(
                                                                  swatchList[
                                                                      selectedTheme][0],
                                                                  .01),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 2.0),
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(
                                                                      (height /
                                                                              8) *
                                                                          0.75 *
                                                                          0.35)),
                                                            ),
                                                            child:
                                                                FractionallySizedBox(
                                                              heightFactor: 0.9,
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          6.0),
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton<
                                                                            String>(
                                                                        borderRadius: BorderRadius.all(Radius.circular((height /
                                                                                12) *
                                                                            0.75 *
                                                                            0.35)),
                                                                        dropdownColor: swatchList[selectedTheme]
                                                                            [0],
                                                                        items: itemTypeList.map<DropdownMenuItem<String>>((String
                                                                            value) {
                                                                          return DropdownMenuItem(
                                                                              value: value,
                                                                              child: Text(
                                                                                value.toLowerCase().tr,
                                                                                maxLines: 1,
                                                                                softWrap: false,
                                                                                overflow: TextOverflow.fade,
                                                                                style: TextStyle(
                                                                                  color: swatchList[selectedTheme][2],
                                                                                ),
                                                                              ));
                                                                        }).toList(),
                                                                        value:
                                                                            dropDownValue,
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                              () {
                                                                            dropDownValue =
                                                                                value!;
                                                                            if (value !=
                                                                                itemTypeList[0]) {
                                                                              addMenuExtra = true;
                                                                            } else {
                                                                              addMenuExtra = false;
                                                                            }
                                                                          });
                                                                        }),
                                                                  ),
                                                                ),
                                                              ),
                                                            )),
                                                      )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //Third Line
                                        Expanded(
                                          flex: 5,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: addMenuExtra
                                                    //Extra Input
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                              child:
                                                                  FractionallySizedBox(
                                                            widthFactor: 0.8,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .contain,
                                                              child: Stack(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            4.0,
                                                                        bottom:
                                                                            4.0),
                                                                    child: Text(
                                                                      dropDownValue !=
                                                                              itemTypeList[3]
                                                                          ? "${"suffix".tr}: "
                                                                          : "Pcs: ",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .fade,
                                                                      maxLines:
                                                                          1,
                                                                      softWrap:
                                                                          false,
                                                                      style:
                                                                          TextStyle(
                                                                        color: swatchList[selectedTheme]
                                                                            [2],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  dropDownValue ==
                                                                          itemTypeList[
                                                                              3]
                                                                      ? Positioned(
                                                                          left:
                                                                              25,
                                                                          top:
                                                                              12.5,
                                                                          child:
                                                                              Tooltip(
                                                                            message:
                                                                                "ex_container".tr,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 7.0,
                                                                              width: 7.0,
                                                                              child: FittedBox(
                                                                                fit: BoxFit.contain,
                                                                                child: CircleAvatar(
                                                                                  backgroundColor: swatchList[selectedTheme][2],
                                                                                  child: Icon(
                                                                                    Icons.question_mark_rounded,
                                                                                    color: swatchList[selectedTheme][0],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                          Expanded(
                                                            child:
                                                                FractionallySizedBox(
                                                              heightFactor:
                                                                  0.75,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: lighten(
                                                                      swatchList[
                                                                          selectedTheme][0],
                                                                      .01),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          2.0),
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular((height /
                                                                              8) *
                                                                          0.75 *
                                                                          0.35)),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          2.0),
                                                                  child:
                                                                      FractionallySizedBox(
                                                                    heightFactor:
                                                                        0.9,
                                                                    child:
                                                                        TextFormField(
                                                                      autofocus:
                                                                          true,
                                                                      maxLines:
                                                                          1,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        errorStyle:
                                                                            const TextStyle(height: 0.001),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              const BorderSide(color: Colors.red),
                                                                          borderRadius: BorderRadius.all(Radius.circular((height / 12) *
                                                                              0.75 *
                                                                              0.35)),
                                                                        ),
                                                                        border:
                                                                            InputBorder.none,
                                                                        hintText: dropDownValue !=
                                                                                itemTypeList[3]
                                                                            ? "ex: Kg"
                                                                            : "ex: 15",
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: darken(
                                                                              swatchList[selectedTheme][0],
                                                                              .15),
                                                                        ),
                                                                      ),
                                                                      cursorColor:
                                                                          swatchList[selectedTheme]
                                                                              [
                                                                              2],
                                                                      cursorWidth:
                                                                          1.5,
                                                                      textInputAction:
                                                                          TextInputAction
                                                                              .next,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      inputFormatters: dropDownValue ==
                                                                              itemTypeList[
                                                                                  3]
                                                                          ? <TextInputFormatter>[
                                                                              FilteringTextInputFormatter.digitsOnly
                                                                            ]
                                                                          : null,
                                                                      initialValue:
                                                                          _itemPrefix,
                                                                      style:
                                                                          TextStyle(
                                                                        color: swatchList[selectedTheme]
                                                                            [2],
                                                                      ),
                                                                      onChanged:
                                                                          (value) {
                                                                        if (dropDownValue == itemTypeList[3] &&
                                                                            value !=
                                                                                "") {
                                                                          _itemPPB =
                                                                              int.parse(value);
                                                                        } else if (value !=
                                                                            "") {
                                                                          _itemPrefix =
                                                                              value;
                                                                        }
                                                                      },
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return "";
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                              ),
                                              //Color
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          FractionallySizedBox(
                                                        widthFactor: 0.8,
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            "${"color".tr}: ",
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            maxLines: 1,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                color: swatchList[
                                                                        selectedTheme]
                                                                    [2]),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    //Color picker button
                                                    Expanded(
                                                        child: InkWell(
                                                      onTap: () {
                                                        openColorDialog(height,
                                                            width, false);
                                                      },
                                                      child:
                                                          FractionallySizedBox(
                                                        widthFactor: 0.7,
                                                        child: FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                addItemColor !=
                                                                        null
                                                                    ? darken(
                                                                        addItemColor!,
                                                                        .2)
                                                                    : Colors
                                                                        .grey
                                                                        .shade400,
                                                            child: addItemColor !=
                                                                    null
                                                                ? FractionallySizedBox(
                                                                    heightFactor:
                                                                        0.9,
                                                                    child: FittedBox(
                                                                        fit: BoxFit.contain,
                                                                        child: CircleAvatar(
                                                                          backgroundColor:
                                                                              addItemColor,
                                                                        )),
                                                                  )
                                                                : Builder(builder:
                                                                    (context) {
                                                                    double
                                                                        width =
                                                                        ((height / 2) *
                                                                                0.75 *
                                                                                0.9) *
                                                                            0.7 *
                                                                            0.9;
                                                                    return CustomPaint(
                                                                      size: Size(
                                                                          (width / 1.2) /
                                                                              4,
                                                                          ((width / 1.2) / 4 * 0.5)
                                                                              .toDouble()),
                                                                      painter:
                                                                          DiagonalLine(),
                                                                    );
                                                                  }),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Add menu action buttons
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        addIconColorFactor =
                                                            swatchList[
                                                                selectedTheme][2];
                                                        addMenuActive = false;
                                                        addButtonSizeFactor = 1;
                                                        addMenuTextColorFactor =
                                                            0;
                                                      });
                                                    },
                                                    child: FractionallySizedBox(
                                                      widthFactor: 0.275,
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: FittedBox(
                                                        fit: BoxFit.cover,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            clearAddMenu();
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              color: swatchList[
                                                                      selectedTheme]
                                                                  [2]),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (_addFormKey
                                                              .currentState !=
                                                          null) {
                                                        if (_addFormKey
                                                            .currentState!
                                                            .validate()) {
                                                          var item = Item(
                                                            name: _itemLabel!,
                                                            quantity:
                                                                _itemQuantity,
                                                            addDate:
                                                                DateTime.now(),
                                                            senderId:
                                                                userLoggedIn
                                                                    ? account!
                                                                        .uid
                                                                    : "0",
                                                            type: itemTypeList
                                                                .indexOf(
                                                                    dropDownValue),
                                                            extension:
                                                                _itemPrefix,
                                                            pcs: _itemPPB,
                                                            color: addItemColor,
                                                          );
                                                          setState(() {
                                                            itemsList.add(item);
                                                            _listKey.currentState?.insertItem(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            100),
                                                                itemsList
                                                                        .length -
                                                                    1);
                                                          });
                                                          clearAddMenu();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'item_added'
                                                                        .tr)),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: FractionallySizedBox(
                                                      widthFactor: 0.275,
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: FittedBox(
                                                        fit: BoxFit.cover,
                                                        child: Icon(
                                                            Icons.add_rounded,
                                                            color: swatchList[
                                                                    selectedTheme]
                                                                [2]),
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
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> showAuthMethode(
      BuildContext context, double height, double width, bool exist) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: swatchList[selectedTheme][2],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((height / 12) * 0.75 * 0.35),
          ),
          child: SizedBox(
            height: height / 2,
            width: width / 1.2,
            child: FractionallySizedBox(
              heightFactor: 0.95,
              widthFactor: 0.95,
              child: Column(
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: 0.65,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          exist ? "log-in".tr : "sign-up".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: swatchList[selectedTheme][6],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        //Email Auth
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              logInSignUpMenuInstance.clearErrors();
                              logInSignUpMenuInstance.showLogInOrSignUpMenu(
                                  context, exist, height, width);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: swatchList[selectedTheme][0],
                                  borderRadius: BorderRadius.circular(
                                      (height / 12) * 0.75 * 0.35),
                                ),
                                child: Row(
                                  children: [
                                    //Icon
                                    const Expanded(
                                      child: FractionallySizedBox(
                                        heightFactor: 0.45,
                                        widthFactor: 1,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          alignment: Alignment.centerRight,
                                          child: Image(
                                            image: AssetImage("email.png"),
                                            color: Colors.white,
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
                                          alignment: Alignment.center,
                                          child: RichText(
                                            text: TextSpan(
                                              text: "${"with".tr} ",
                                              style: TextStyle(
                                                color: swatchList[selectedTheme]
                                                    [2],
                                              ),
                                              children: const [
                                                TextSpan(
                                                  text: "Email",
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
                          ),
                        ),
                        //Or
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      thickness: 2.0,
                                      color: swatchList[selectedTheme][5])),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 0.5,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      "or".tr,
                                      style: TextStyle(
                                        color: swatchList[selectedTheme][5],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      thickness: 2.0,
                                      color: swatchList[selectedTheme][5])),
                            ],
                          ),
                        ),
                        //Social Auth
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              //Auth Google
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Auth().signInWithGoogle();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.blue, width: 2.5),
                                        borderRadius: BorderRadius.circular(
                                            (height / 12) * 0.75 * 0.35),
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
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      Image.asset("google.png")
                                                          .image,
                                                  backgroundColor:
                                                      Colors.transparent,
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
                                                    text: "${"with".tr} ",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    children: const [
                                                      TextSpan(
                                                        text: "Google",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
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
                                ),
                              ),
                              //Auth Facebook
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Auth().signInWithFacebook();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 66, 103, 178),
                                        borderRadius: BorderRadius.circular(
                                            (height / 12) * 0.75 * 0.35),
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
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CircleAvatar(
                                                  backgroundImage: Image.asset(
                                                          "facebook.png")
                                                      .image,
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
                                                    text: "${"with".tr} ",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    children: const [
                                                      TextSpan(
                                                        text: "Facebook",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  fetchUserData(String? uid) async {
    Map<String, dynamic> userPreferencesTemp = {};
    if (uid != null) {
      DocumentSnapshot snapshot = await _accounts.doc(uid).get();
      print("Fetching...");
      userLoggedIn = !snapshot.metadata.isFromCache;
      DocumentSnapshot? data = snapshot;
      bool imgExist = false;
      String? authMail = Auth().emailIsChanged(data["email"]);
      if (authMail != null) {
        fst.Firestore().updateAccountData(
            uid: uid, newUser: false, accountData: {"email": authMail});
      }
      try {
        setState(() {
          String irl = data["imgURL"];
          imgExist = irl.isNotEmpty;
        });
      } catch (e) {
        setState(() {
          imgExist = false;
        });
      }
      setState(() {
        profilePictureUrl = imgExist ? data["imgURL"] : null;
      });
      try {
        setState(() {
          imgExist ? Image.network(profilePictureUrl!) : null;
        });
      } catch (e) {
        setState(() {
          profilePictureUrl = null;
        });
      }
      try {
        setState(() {
          userPreferencesTemp = {
            "App_Not": data["App_Not"],
            "Chat_Not": data["Chat_Not"],
            "showMiddleName": data["showMiddleName"],
            "firstNameFirst": data["firstNameFirst"],
            "selectedTheme": data["selectedTheme"],
          };
          if (offline) {
            offline = false;
          }
        });
      } catch (e) {
        setState(() {
          loading = true;
        });
      }

      var locale = Locale(data["lang"]);
      Get.updateLocale(locale);
      selectedLang = data["lang"].substring(0, 2).toUpperCase();
      userPreferencesTemp.forEach((key, value) {
        if (value != null) {
          setState(() {
            if (key == "selectedTheme") {
              defaultTheme = value;
              selectedTheme = value;
            } else {
              prefs != null ? prefs!.setBool(key, value) : null;
            }
          });
        }
      });
      setState(() {
        account = userLoggedIn
            ? Profile(
                uid: uid,
                email: data["email"],
                middleName:
                    data["middleName"] != "" ? data["middleName"] : null,
                provider: data["provider"],
                firstName: data["firstName"],
                lastName: data["lastName"],
                pic: profilePictureUrl,
                firstNameFirst: userPreferencesTemp["firstNameFirst"],
                showMiddleName: userPreferencesTemp["showMiddleName"],
              )
            : null;
      });
      if (userLoggedIn && !snapshot.metadata.isFromCache) {
        setState(() {
          loading = true;
        });
      } else {
        setState(() {
          if (authMenuOpen) {
            authMenuOpen = false;
          }
          if (loading) {
            loading = false;
          }
        });
      }
    } else {
      setState(() {
        loading = false;
        offline = true;
        userLoggedIn = false;
      });
    }
    prefs != null ? prefs!.setInt("selectedTheme", selectedTheme) : null;
    setState(() {
      userPreferences = userPreferencesTemp;
    });
  }

  Widget _buildItem(
      double x, double y, int index, Item item, Animation<double> animation) {
    Member sender =
        membersList.where((element) => element.uid == item.senderId).first;
    return ScaleTransition(
      scale: animation,
      child: GestureDetector(
        onTap: () {
          setState(() {
            item.active = !item.active;

            for (var item in itemsList) {
              if (item.active) {
                selectionActive = true;
                break;
              } else {
                selectionActive = false;
              }
            }
          });
        },
        child: SizedBox(
          height: y >= 35 ? y / 12 : 35,
          width: x,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Center(
                  child: CircleAvatar(
                    radius: (y >= 35 ? y / 12 : 35) * 0.35,
                    backgroundColor: darken(swatchList[selectedTheme][0], .12),
                    child: CircleAvatar(
                      radius: (y >= 35 ? y / 12 : 35) * 0.305,
                      backgroundColor: !item.active
                          ? swatchList[selectedTheme][2]
                          : darken(swatchList[selectedTheme][0], .12),
                      child: FractionallySizedBox(
                          heightFactor: 0.75,
                          child: FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.check_rounded,
                                color: swatchList[selectedTheme][2],
                              ))),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    heightFactor: 0.4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FractionallySizedBox(
                          heightFactor: 0.7,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: item.type != 3
                                ? Text(
                                    item.type == 0
                                        ? "X${item.quantity}"
                                        : "${item.quantity}${item.extension}",
                                    style: TextStyle(
                                      color: swatchList[selectedTheme][4],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        "${item.pcs}",
                                        style: TextStyle(
                                          color: lighten(
                                              swatchList[selectedTheme][4], .2),
                                        ),
                                      ),
                                      Text(
                                        "X${item.quantity}",
                                        style: TextStyle(
                                          color: swatchList[selectedTheme][4],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.name,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color:
                                    darken(swatchList[selectedTheme][0], .12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  color: item.color ??
                                      swatchList[selectedTheme][2],
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    editObject(context, y, x, index);
                                  },
                                  child: FractionallySizedBox(
                                    heightFactor: 0.75,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Tooltip(
                                        message:
                                            "${"added_by".tr} ${sender.name}\n${"date".tr}: ${DateFormat('dd/MM/yyyy HH:mm').format(item.addDate)}",
                                        child: CircleAvatar(
                                          backgroundColor:
                                              swatchList[selectedTheme][0],
                                          child: Icon(
                                            Icons.priority_high_rounded,
                                            color: swatchList[selectedTheme][2],
                                          ),
                                        ),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearAddMenu() {
    setState(() {
      selectionActive = false;
      addButtonSizeFactor = 1;
      addIconColorFactor = swatchList[selectedTheme][2];
      addMenuTextColorFactor = 0;
      addMenuActive = false;

      _itemLabel = null;
      _itemQuantity = 1;
      dropDownValue = itemTypeList[0];
      _quantityController.text = "1";
      addItemColor = null;

      addMenuExtra = false;
      _itemPrefix = null;
    });
  }

  openColorDialog(double height, double width, bool edit) {
    return showDialog<Color>(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: swatchList[selectedTheme][2],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((height / 12) * 0.75 * 0.35),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: height / 10,
                  width: width / 2,
                  child: FractionallySizedBox(
                    heightFactor: 0.7,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "${"pick_color".tr}:",
                        style: TextStyle(
                          color: swatchList[selectedTheme][6],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      itemCount: itemColorList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1, crossAxisCount: 4),
                      itemBuilder: ((context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: () =>
                                Navigator.pop(context, itemColorList[index]),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: (width / 1.2) / 4,
                                height: (height / 2.5) / 3,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25.0),
                                    )),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  child: CustomPaint(
                                    size: Size(
                                        (width / 1.2) / 4,
                                        ((width / 1.2) / 4 * 0.5)
                                            .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                                    painter: DiagonalLine(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return InkWell(
                          onTap: () =>
                              Navigator.pop(context, itemColorList[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Container(
                                width: (width / 1.2) / 4,
                                height: (height / 2.5) / 3,
                                decoration: BoxDecoration(
                                    color: itemColorList[index],
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25.0),
                                    )),
                              ),
                            ),
                          ),
                        );
                      })),
                ),
              ],
            ),
          );
        }).then((Color? color) {
      if (color == null) {
        setState(() {
          edit ? editItemColor = null : addItemColor = null;
        });
        return;
      }

      setState(() {
        edit ? editItemColor = color : addItemColor = color;
      });
    });
  }

  void editObject(
      BuildContext context, double height, double width, int index) {
    Item item = itemsList[index];
    setState(() {
      _editItemLabel = item.name;
      _editItemQuantity = item.quantity;
      _editQuantityController.text = item.quantity.toString();
      _editItemPrefix = item.extension;
      _editItemPPB = item.pcs;
      editDropDownValue = itemTypeList[item.type];
      item.type > 0 ? editAddMenuExtra = true : editAddMenuExtra = false;
      editItemColor = item.color;
    });
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular((height / 8) * 0.75 * 0.35)),
            ),
            child: Container(
              height: height * 0.5,
              width: width * 0.8,
              decoration: BoxDecoration(
                color: darken(swatchList[selectedTheme][0], .12),
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.all(
                    Radius.circular((height / 8) * 0.75 * 0.35)),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.9,
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //First Line
                      Expanded(
                        flex: 6,
                        child: FractionallySizedBox(
                          heightFactor: 0.8,
                          child: Row(
                            children: [
                              //Label
                              Expanded(
                                flex: 1,
                                child: FractionallySizedBox(
                                  heightFactor: 0.35,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${"label".tr}: ",
                                      style: TextStyle(
                                        color: swatchList[selectedTheme][2],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //Label Input
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: lighten(
                                        swatchList[selectedTheme][0], .01),
                                    border: Border.all(
                                        color: Colors.transparent, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            (height / 8) * 0.75 * 0.35)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: FractionallySizedBox(
                                      heightFactor: 0.9,
                                      alignment: Alignment.centerLeft,
                                      child: TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.bottom,
                                        initialValue: _editItemLabel,
                                        autofocus: true,
                                        maxLines: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9a-zA-Z ]"))
                                        ],
                                        decoration: InputDecoration(
                                            errorStyle:
                                                const TextStyle(height: 0.001),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.red),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      (height / 12) *
                                                          0.75 *
                                                          0.35)),
                                            ),
                                            border: InputBorder.none,
                                            prefixText: "  ",
                                            hintText: "item_name".tr,
                                            hintStyle: TextStyle(
                                              color: darken(
                                                  swatchList[selectedTheme][0],
                                                  .15),
                                            )),
                                        cursorColor: swatchList[selectedTheme]
                                            [2],
                                        cursorWidth: 1.5,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: swatchList[selectedTheme][5],
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _editItemLabel = value;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Secound Line
                      Expanded(
                        flex: 6,
                        child: FractionallySizedBox(
                          heightFactor: 0.8,
                          child: Row(
                            children: [
                              //Quantity
                              Expanded(
                                flex: 2,
                                child: FractionallySizedBox(
                                  heightFactor: 0.35,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${"quantity".tr}:  ",
                                      style: TextStyle(
                                        color: swatchList[selectedTheme][2],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //Quantity Input
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: lighten(
                                        swatchList[selectedTheme][0], .01),
                                    border: Border.all(
                                        color: Colors.transparent, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            (height / 8) * 0.75 * 0.35)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.bottom,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        autofocus: true,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          errorStyle:
                                              const TextStyle(height: 0.001),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular((height / 12) *
                                                    0.75 *
                                                    0.35)),
                                          ),
                                          border: InputBorder.none,
                                          hintText: "ex: 5",
                                          hintStyle: TextStyle(
                                            color: darken(
                                                swatchList[selectedTheme][0],
                                                .15),
                                          ),
                                        ),
                                        cursorColor: swatchList[selectedTheme]
                                            [2],
                                        cursorWidth: 1.5,
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: swatchList[selectedTheme][5],
                                        ),
                                        controller: _editQuantityController,
                                        onChanged: (value) {
                                          if (value != "") {
                                            setState(() {
                                              _editItemQuantity =
                                                  double.parse(value);
                                            });
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //Right Section
                              Expanded(
                                flex: 3,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(width: 2.0),
                                    //Quantity Control buttons
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        //Increment quantity button
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                if (_editItemQuantity != null) {
                                                  setState(() {
                                                    _editItemQuantity =
                                                        _editItemQuantity! + 1;
                                                    _editQuantityController
                                                            .text =
                                                        _editItemQuantity
                                                            .toString();
                                                  });
                                                } else {
                                                  setState(() {
                                                    _editItemQuantity = 1;
                                                    _editQuantityController
                                                            .text =
                                                        _editItemQuantity
                                                            .toString();
                                                  });
                                                }
                                              },
                                              child: FractionallySizedBox(
                                                heightFactor: 0.9,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Icon(
                                                    Icons
                                                        .arrow_circle_up_rounded,
                                                    color: swatchList[
                                                        selectedTheme][2],
                                                  ),
                                                ),
                                              ),
                                            )),
                                        //Decrement quantity button
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              if (_editItemQuantity != null) {
                                                if (_editItemQuantity! > 1) {
                                                  setState(() {
                                                    _editItemQuantity =
                                                        _editItemQuantity! - 1;
                                                    _editQuantityController
                                                            .text =
                                                        _editItemQuantity
                                                            .toString();
                                                  });
                                                } else {
                                                  setState(() {
                                                    _editItemQuantity = 1;
                                                    _editQuantityController
                                                        .text = "1";
                                                  });
                                                }
                                              }
                                            },
                                            child: FractionallySizedBox(
                                              heightFactor: 0.9,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Icon(
                                                  Icons
                                                      .arrow_circle_down_rounded,
                                                  color:
                                                      swatchList[selectedTheme]
                                                          [2],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //Item Type Menu
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: lighten(
                                                swatchList[selectedTheme][0],
                                                .01),
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 2.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular((height / 8) *
                                                    0.75 *
                                                    0.35)),
                                          ),
                                          child: FractionallySizedBox(
                                            heightFactor: 0.9,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6.0),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  (height /
                                                                          12) *
                                                                      0.75 *
                                                                      0.35)),
                                                      dropdownColor: swatchList[
                                                          selectedTheme][0],
                                                      items: itemTypeList.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem(
                                                            value: value,
                                                            child: Text(
                                                              value
                                                                  .toLowerCase()
                                                                  .tr,
                                                              maxLines: 1,
                                                              softWrap: false,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              style: TextStyle(
                                                                color: swatchList[
                                                                    selectedTheme][2],
                                                              ),
                                                            ));
                                                      }).toList(),
                                                      value: editDropDownValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          editDropDownValue =
                                                              value!;
                                                          if (value !=
                                                              itemTypeList[0]) {
                                                            editAddMenuExtra =
                                                                true;
                                                          } else {
                                                            editAddMenuExtra =
                                                                false;
                                                          }
                                                        });
                                                      }),
                                                ),
                                              ),
                                            ),
                                          )),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Third Line
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Expanded(
                              child: editAddMenuExtra
                                  //Extra Input
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: FractionallySizedBox(
                                          widthFactor: 0.8,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4.0,
                                                          bottom: 4.0),
                                                  child: Text(
                                                    editDropDownValue !=
                                                            itemTypeList[3]
                                                        ? "${"suffix".tr}: "
                                                        : "Pcs: ",
                                                    overflow: TextOverflow.fade,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      color: swatchList[
                                                          selectedTheme][2],
                                                    ),
                                                  ),
                                                ),
                                                editDropDownValue ==
                                                        itemTypeList[3]
                                                    ? Positioned(
                                                        left: 25,
                                                        top: 12.5,
                                                        child: Tooltip(
                                                          message:
                                                              "ex_container".tr,
                                                          child: SizedBox(
                                                            height: 7.0,
                                                            width: 7.0,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .contain,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    swatchList[
                                                                        selectedTheme][2],
                                                                child: Icon(
                                                                  Icons
                                                                      .question_mark_rounded,
                                                                  color: swatchList[
                                                                      selectedTheme][0],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        )),
                                        Expanded(
                                          child: FractionallySizedBox(
                                            heightFactor: 0.75,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: lighten(
                                                    swatchList[selectedTheme]
                                                        [0],
                                                    .01),
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 2.0),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        (height / 8) *
                                                            0.75 *
                                                            0.35)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                child: FractionallySizedBox(
                                                  heightFactor: 0.9,
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      errorStyle:
                                                          const TextStyle(
                                                              height: 0.001),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    Colors.red),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    (height /
                                                                            12) *
                                                                        0.75 *
                                                                        0.35)),
                                                      ),
                                                      border: InputBorder.none,
                                                      hintText:
                                                          editDropDownValue !=
                                                                  itemTypeList[
                                                                      3]
                                                              ? "ex: Kg"
                                                              : "ex: 15",
                                                      hintStyle: TextStyle(
                                                        color: darken(
                                                            swatchList[
                                                                selectedTheme][0],
                                                            .15),
                                                      ),
                                                    ),
                                                    cursorColor: swatchList[
                                                        selectedTheme][2],
                                                    cursorWidth: 1.5,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    textAlign: TextAlign.center,
                                                    inputFormatters:
                                                        editDropDownValue ==
                                                                itemTypeList[3]
                                                            ? <TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ]
                                                            : null,
                                                    initialValue: item.type != 3
                                                        ? _editItemPrefix
                                                        : _editItemPPB
                                                            .toString(),
                                                    style: TextStyle(
                                                      color: swatchList[
                                                          selectedTheme][2],
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (editDropDownValue ==
                                                                itemTypeList[
                                                                    3] &&
                                                            value != "") {
                                                          _editItemPPB =
                                                              int.parse(value);
                                                        } else if (value !=
                                                            "") {
                                                          _editItemPrefix =
                                                              value;
                                                        }
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                            //Color
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.8,
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${"color".tr}: ",
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                              color: swatchList[selectedTheme]
                                                  [2]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //Color picker button
                                  Expanded(
                                      child: InkWell(
                                    onTap: () async {
                                      await openColorDialog(
                                          height, width, true);
                                      setState(() {});
                                    },
                                    child: FractionallySizedBox(
                                      widthFactor: 0.7,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: CircleAvatar(
                                          backgroundColor: editItemColor != null
                                              ? darken(editItemColor!, .2)
                                              : Colors.grey.shade400,
                                          child: editItemColor != null
                                              ? FractionallySizedBox(
                                                  heightFactor: 0.9,
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            editItemColor,
                                                      )),
                                                )
                                              : Builder(builder: (context) {
                                                  double newWidth =
                                                      ((width * 0.8) *
                                                              0.75 *
                                                              0.9) *
                                                          0.7 *
                                                          0.9;
                                                  return CustomPaint(
                                                    size: Size(
                                                        (newWidth / 1.2) / 4,
                                                        ((newWidth / 1.2) /
                                                                4 *
                                                                0.5)
                                                            .toDouble()),
                                                    painter: DiagonalLine(),
                                                  );
                                                }),
                                        ),
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Edit menu action buttons
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: FractionallySizedBox(
                                    widthFactor: 0.275,
                                    alignment: Alignment.bottomLeft,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Icon(Icons.close_rounded,
                                          color: swatchList[selectedTheme][2]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () {
                                    if (_editFormKey.currentState != null) {
                                      if (_editFormKey.currentState!
                                          .validate()) {
                                        var newItem = Item(
                                          name: _editItemLabel!,
                                          quantity: _editItemQuantity,
                                          addDate: item.addDate,
                                          senderId:
                                              userLoggedIn ? account!.uid : "0",
                                          type: itemTypeList
                                              .indexOf(editDropDownValue),
                                          extension: _editItemPrefix,
                                          pcs: _editItemPPB,
                                          color: editItemColor,
                                        );
                                        this.setState(() {
                                          Item removedItem =
                                              itemsList.removeAt(index);
                                          AnimatedListRemovedItemBuilder
                                              builder = ((context, animation) {
                                            return _buildItem(width, height,
                                                index, removedItem, animation);
                                          });
                                          _listKey.currentState?.removeItem(
                                              index, builder,
                                              duration: const Duration(
                                                  milliseconds: 100));
                                          itemsList.add(newItem);
                                          _listKey.currentState?.insertItem(
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              itemsList.length - 1);
                                          Navigator.of(context).pop();
                                        });
                                      }
                                    }
                                  },
                                  child: FractionallySizedBox(
                                    widthFactor: 0.275,
                                    alignment: Alignment.bottomRight,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Icon(Icons.check_rounded,
                                          color: swatchList[selectedTheme][2]),
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
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

Widget emptyStateWidget(double height, double width) {
  return Stack(
    children: [
      CircleAvatar(
        backgroundColor: swatchList[selectedTheme][1],
        maxRadius: height < width ? height / 8 : width / 6,
      ),
      Image(
          height: height < width ? height / 4 : width / 3,
          width: height < width ? height / 4 : width / 3,
          image: const AssetImage("assets/no_item_items.png"),
          color: swatchList[selectedTheme][0]),
      Container(
        height: height < width ? height / 4 : width / 3,
        width: height < width ? height / 4 : width / 3,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/no_item_person.png"))),
      ),
    ],
  );
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = darken(swatchList[selectedTheme][1], .05)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, size.height * 0.8650000);
    path0.quadraticBezierTo(size.width * 0.2003125, size.height * 0.6831250,
        size.width * 0.2775000, size.height * 0.6450000);
    path0.cubicTo(
        size.width * 0.3903125,
        size.height * 0.5768750,
        size.width * 0.7259375,
        size.height * 0.7881250,
        size.width * 0.8187500,
        size.height * 0.7150000);
    path0.quadraticBezierTo(size.width * 0.9300000, size.height * 0.6325000,
        size.width, size.height * 0.4450000);
    path0.lineTo(size.width, size.height);
    path0.lineTo(0, size.height);
    path0.lineTo(0, size.height * 0.8650000);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DiagonalLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width, size.height);

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
