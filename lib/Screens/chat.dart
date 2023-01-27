import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meak/Classes/member.dart';
import 'package:meak/Classes/message.dart';
import 'package:meak/Classes/chat_data.dart';
import 'package:meak/Classes/profile.dart';
import 'package:meak/lang/dates.dart';
import 'package:meak/main.dart';
import 'package:meak/themes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                                ? messageItem(data[index - 1], myAccount.uid,
                                    height, width)
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
                                          sendMessage(height);
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
                                                sendMessage(height);
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

  cleanArea() {
    Future.delayed(const Duration(milliseconds: 5), () {
      setState(() {
        messageController.clear();
      });
    });
  }

  void sendMessage(double height) {
    setState(() {
      if (data.isNotEmpty) {
        data.add(Message(
            id: data.last.id + 1,
            senderId: myAccount.uid,
            partyId: myAccount.partyId!,
            time:
                "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}T${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}",
            content: messageController.text,
            previousId: data.last.id));
        listKey.currentState!.insertItem(data.length);
        listController.animateTo(
            listController.position.maxScrollExtent + height / 8,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
      } else {
        data.add(Message(
          id: 0,
          senderId: myAccount.uid,
          partyId: myAccount.partyId!,
          time:
              "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}T${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}",
          content: messageController.text,
        ));
      }
    });
    focusNode.requestFocus();
    cleanArea();
  }

  void handleClick(String value) {
    if (value == 'clear_chat'.tr) {
      setState(() {
        data.clear();
      });
    } else {
      Navigator.of(context).pushNamed("/settings");
    }
  }

  //Message Item
  Widget messageItem(Message msg, String uid, double height, double width) {
    bool myself = uid == msg.senderId;
    DateTime time = DateTime.parse(msg.time);
    bool showDate = false;
    if (msg.previousId != null) {
      Message previousMessage =
          data.where((element) => element.id == msg.previousId).first;
      DateTime previousMessageDate = DateTime.parse(previousMessage.time);
      String today = msg.time.substring(0, 8);
      DateTime todayDate = DateTime.parse("${int.parse(today)}T000000");
      todayDate.isAfter(previousMessageDate) ? showDate = true : null;
    } else {
      showDate = true;
    }
    Member sender =
        membersList.where((element) => element.uid == msg.senderId).first;
    return Column(
      children: [
        //Full Date
        showDate
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
                child: Text(
                  " ${weekList[selectedLang]![time.weekday]} ${DateFormat('dd').format(time)} ${monthList[selectedLang]![time.month]} ${DateFormat('yyyy').format(time)}",
                  style: TextStyle(
                    color: swatchList[selectedTheme][4],
                    fontSize: 2.0 * (height * 0.01),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox(),
        //Message
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment:
                myself ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              //Time Left
              myself
                  ? Text(
                      "${DateFormat('HH:mm').format(time)} ",
                      style: TextStyle(
                        fontSize: 2.0 * (height * 0.01),
                        color: swatchList[selectedTheme][4],
                      ),
                    )
                  : const SizedBox(),
              //Info
              !myself
                  ? Tooltip(
                      message: sender.name,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        //Picture
                        child: CircleAvatar(
                          backgroundColor: swatchList[selectedTheme][5],
                          backgroundImage: sender.pic != null
                              ? NetworkImage(sender.pic!)
                              : const AssetImage("assets/default.png")
                                  as ImageProvider,
                          radius: 4.0 * (height * 0.01),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: myself
                        ? swatchList[selectedTheme][1]
                        : swatchList[selectedTheme][3],
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0 * (height * 0.01))),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.0 * (height * 0.01)),
                    child: Text(
                      msg.content,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 2.5 * (height * 0.01),
                        color: swatchList[selectedTheme][6],
                      ),
                    ),
                  ),
                ),
              ),
              //Time right
              !myself
                  ? Text(
                      " ${DateFormat('HH:mm').format(time)}",
                      style: TextStyle(
                        fontSize: 2.0 * (height * 0.01),
                        color: swatchList[selectedTheme][4],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
