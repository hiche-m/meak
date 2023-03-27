import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meak/Models/member.dart';
import 'package:meak/Models/message.dart';
import 'package:meak/Models/chat_data.dart';
import 'package:meak/Models/profile.dart';
import 'package:meak/Utils/lang/dates.dart';
import 'package:meak/View/settings.dart';
import 'package:meak/main.dart';
import 'package:meak/Utils/themes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/message_item.dart';
import '../ViewModels/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

Profile myAccount = Profile(
  email: "hichem1029@live.fr",
  firstName: "Hichem",
  lastName: "Rahmani",
  uid: "0",
  provider: "Email",
  middleName: "Mohamed",
  partyId: 0,
  pic: "https://alfitude.com/wp-content/uploads/2019/09/Anthony-Ramos.jpg",
  showMiddleName: true,
  firstNameFirst: true,
  isOwner: true,
);

class _ChatScreenState extends State<ChatScreen> {
  FocusNode focusNode = FocusNode();
  List<Member> membersList = members;
  var messageController = TextEditingController();
  var listController = ScrollController();
  final _sendKet = GlobalKey<FormState>();
  bool chatActive = true;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    listController = ScrollController();
    init();

    data.isNotEmpty
        ? WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            listController.jumpTo(listController.position.maxScrollExtent);
          })
        : null;
  }

  late SharedPreferences prefs;
  int selectedTheme = 0;
  void init() async {
    prefs = await SharedPreferences.getInstance();
    selectedTheme = prefs.getInt("selectedTheme") ?? defaultTheme;
    setState(() {
      selectedTheme;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    init();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: swatchList[selectedTheme][2],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: height,
            width: width,
            child: Stack(
              children: [
                //Texts
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: data.isNotEmpty
                      ? AnimatedList(
                          itemBuilder: ((context, index, animation) {
                            return index < data.length + 1 && index != 0
                                ? MessageItem(
                                    msg: data[index - 1],
                                    uid: myAccount.uid,
                                    height: height,
                                    width: width,
                                    data: data,
                                    membersList: membersList)
                                : SizedBox(
                                    height: (height / 7),
                                  );
                          }),
                          initialItemCount: data.length + 2,
                          key: listKey,
                          controller: listController,
                        )
                      : Center(
                          child: Container(
                            height: height < width ? height / 2 : width / 2,
                            width: height < width ? height / 2 : width / 2,
                            decoration: BoxDecoration(
                              color: swatchList[selectedTheme][3]
                                  .withOpacity(0.25),
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(4.0 * (height * 0.01))),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: FractionallySizedBox(
                                    heightFactor: 0.5,
                                    widthFactor: 0.9,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        "The chat is empty",
                                        style: TextStyle(
                                          color: swatchList[selectedTheme][5],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ),
                ),
                //Top Bar
                Container(
                  height: height / 10,
                  width: width,
                  decoration: BoxDecoration(
                    color: swatchList[selectedTheme][0],
                    border: Border.all(color: Colors.transparent),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.5,
                          child: FittedBox(
                            alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: FractionallySizedBox(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.35,
                          child: FittedBox(
                            alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "chat".tr,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.5,
                          child: FittedBox(
                            alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            child: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    (height / 12) * 0.75 * 0.35)),
                              ),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              color: swatchList[selectedTheme][1],
                              onSelected: handleClick,
                              itemBuilder: (BuildContext context) {
                                return {'clear_chat'.tr, 'settings'.tr}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    textStyle: TextStyle(
                                      color: swatchList[selectedTheme][4],
                                    ),
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Bottom Bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: width,
                    height: height / 8,
                    decoration: BoxDecoration(
                      color: swatchList[selectedTheme][3],
                      border: Border.all(color: Colors.transparent),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -1), // Shadow position
                        ),
                      ],
                    ),
                    child: FractionallySizedBox(
                        heightFactor: 0.9,
                        widthFactor: 0.98,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Input text
                            Expanded(
                              flex: 5,
                              child: FractionallySizedBox(
                                heightFactor: 0.75,
                                widthFactor: 0.98,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: swatchList[selectedTheme][2],
                                    border:
                                        Border.all(color: Colors.transparent),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0)),
                                  ),
                                  child: Form(
                                    key: _sendKet,
                                    child: TextFormField(
                                      controller: messageController,
                                      focusNode: focusNode,
                                      expands: true,
                                      minLines: null,
                                      maxLines: null,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.only(top: 8.0),
                                        border: InputBorder.none,
                                        prefixText: "    ",
                                        hintText: "send_txt".tr,
                                        hintStyle: TextStyle(
                                          color: swatchList[selectedTheme][5],
                                        ),
                                        errorStyle:
                                            const TextStyle(height: 0.001),
                                      ),
                                      cursorColor: swatchList[selectedTheme][5],
                                      textInputAction: TextInputAction.send,
                                      onFieldSubmitted: (value) {
                                        if (_sendKet.currentState!.validate()) {
                                          ChatModel().sendMessage(
                                            height: height,
                                            data: data,
                                            myAccount: myAccount,
                                            messageController:
                                                messageController,
                                            focusNode: focusNode,
                                            listKey: listKey,
                                            listController: listController,
                                          );
                                          setState(() {});
                                        }
                                      },
                                      textAlign: TextAlign.justify,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                        color: swatchList[selectedTheme][4],
                                        fontSize: (height / 8) * 0.9 * 0.5 / 2,
                                      ),
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      validator: ((value) {
                                        return value == null ||
                                                value.trim() == ""
                                            ? ""
                                            : null;
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Send button
                            messageController.text.isNotEmpty
                                ? Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.7,
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              swatchList[selectedTheme][0],
                                          child: IconButton(
                                            onPressed: () {
                                              if (_sendKet.currentState!
                                                  .validate()) {
                                                ChatModel().sendMessage(
                                                  height: height,
                                                  data: data,
                                                  myAccount: myAccount,
                                                  messageController:
                                                      messageController,
                                                  focusNode: focusNode,
                                                  listKey: listKey,
                                                  listController:
                                                      listController,
                                                );
                                                setState(() {});
                                              }
                                            },
                                            icon: const FractionallySizedBox(
                                              heightFactor: 0.75,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Icon(
                                                  Icons.send_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            splashRadius: 0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleClick(String value) {
    if (value == 'clear_chat'.tr) {
      setState(() {
        data.clear();
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SettingsScreen(account: myAccount)),
      );
    }
  }
}
