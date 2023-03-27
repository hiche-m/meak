import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meak/Utils/themes.dart';

import '../Models/member.dart';
import '../Models/message.dart';
import '../Utils/lang/dates.dart';
import '../View/home.dart';
import '../main.dart';

class MessageItem extends StatelessWidget {
  final Message msg;
  final String uid;
  final double height;
  final double width;
  final List<Message> data;
  final List<Member> membersList;

  const MessageItem({
    super.key,
    required this.msg,
    required this.uid,
    required this.height,
    required this.width,
    required this.data,
    required this.membersList,
  });

  @override
  Widget build(BuildContext context) {
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
