import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/message.dart';
import '../Models/profile.dart';

class ChatModel {
  cleanArea(messageController) {
    Future.delayed(const Duration(milliseconds: 5), () {
      messageController.clear();
    });
  }

  void sendMessage(
      {required double height,
      required List<Message> data,
      required Profile myAccount,
      required TextEditingController messageController,
      required FocusNode focusNode,
      required GlobalKey<AnimatedListState> listKey,
      required ScrollController listController}) {
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
    focusNode.requestFocus();
    cleanArea(messageController);
  }
}
