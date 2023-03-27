import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meak/Utils/themes.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddMemberMenu {
  bool qrMode = false;
  bool waitingForResponse = false;
  TextEditingController emailController = TextEditingController();
  String link = 'cd.m/dsqxQSz2';
  TextEditingController copyLinkController = TextEditingController();
  int selectedTheme = 0;
  int initialIndex = 0;

  Future<dynamic> buildAddMember(
      BuildContext context, double height, double width) {
    PageController contentController = PageController(
        keepPage: true, viewportFraction: 1, initialPage: initialIndex);
    PageController actionsController = PageController(
        keepPage: true, viewportFraction: 1, initialPage: initialIndex);
    copyLinkController.text = link;
    copyLinkController.selection = TextSelection(
        baseOffset: 0, extentOffset: copyLinkController.value.text.length);
    List<MaterialColor> colorSchemes = swatchList[selectedTheme];
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  //Dialog object
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    //Dialog Size
                    child: Container(
                      height: height / 2,
                      width: width / 1.2,
                      decoration: BoxDecoration(
                          color: colorSchemes[2],
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.all(
                              Radius.circular((height / 8) * 0.40))),
                      //Dialog content
                      child: Column(
                        children: [
                          //Top bar
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: (height / 8) * 0.40 * 0.5,
                                  top: (height / 8) * 0.40 * 0.5,
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: colorSchemes[0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //Content
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Email or QR option
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      //Email
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              if (qrMode) {
                                                contentController.animateToPage(
                                                  0,
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  curve: Curves.bounceInOut,
                                                );
                                                actionsController.animateToPage(
                                                  0,
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  curve: Curves.bounceInOut,
                                                );
                                                setState(() {
                                                  initialIndex = 0;
                                                  qrMode = !qrMode;
                                                });
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: !qrMode
                                                      ? colorSchemes[1]
                                                          .withOpacity(0.3)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                        (height / 8) *
                                                            0.40 *
                                                            0.25),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "email".tr,
                                                    style: TextStyle(
                                                      color: qrMode
                                                          ? colorSchemes[5]
                                                          : colorSchemes[6],
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: colorSchemes[5],
                                        thickness: 0.5,
                                      ),
                                      //QR
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          alignment: Alignment.centerLeft,
                                          child: InkWell(
                                            onTap: () {
                                              if (!qrMode) {
                                                contentController.animateToPage(
                                                  1,
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  curve: Curves.bounceInOut,
                                                );
                                                actionsController.animateToPage(
                                                  1,
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  curve: Curves.bounceInOut,
                                                );
                                                setState(() {
                                                  initialIndex = 1;
                                                  qrMode = !qrMode;
                                                });
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: qrMode
                                                      ? colorSchemes[1]
                                                          .withOpacity(0.3)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                        (height / 8) *
                                                            0.40 *
                                                            0.25),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "QR",
                                                    style: TextStyle(
                                                      color: qrMode
                                                          ? colorSchemes[6]
                                                          : colorSchemes[5],
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: PageView(
                                    controller: contentController,
                                    children: [
                                      emailContent(setState, colorSchemes,
                                          height, width),
                                      qrContent(colorSchemes, height),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Dialog Actions
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: PageView(
                                controller: actionsController,
                                children: [
                                  emailActions(
                                      context, height, width, colorSchemes),
                                  qrActions(
                                      context, height, width, colorSchemes),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  Widget emailContent(void Function(void Function()) setState,
      List<MaterialColor> colorSchemes, double height, double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        children: [
          //Email fill section
          Expanded(
            flex: 2,
            child: FractionallySizedBox(
              widthFactor: 0.95,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FractionallySizedBox(
                      heightFactor: 0.35,
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${"email_full".tr}: ",
                          softWrap: false,
                          style: TextStyle(
                            color: colorSchemes[4],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: FractionallySizedBox(
                      heightFactor: 0.9,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                            color: colorSchemes[3],
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.all(
                                Radius.circular((height / 8) * 0.40 * 0.5))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: TextFormField(
                              maxLines: 1,
                              controller: emailController,
                              textInputAction: TextInputAction.send,
                              style: TextStyle(
                                fontSize: ((2 / 6) * (6 / 9) * height / 2) / 3,
                                color: colorSchemes[6],
                              ),
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "email_ex".tr,
                                  hintStyle: TextStyle(
                                    color: colorSchemes[5],
                                  )),
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
          //Or
          Expanded(
            flex: 1,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  "or".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorSchemes[6],
                  ),
                ),
              ),
            ),
          ),
          //Copy Link
          Expanded(
            flex: 2,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                    color: colorSchemes[3],
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                        Radius.circular((height / 8) * 0.40 * 0.5))),
                child: Row(
                  children: [
                    //Input
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: TextFormField(
                          maxLines: 1,
                          autofocus: true,
                          controller: copyLinkController,
                          style: TextStyle(
                            fontSize: ((2 / 6) * (6 / 9) * height / 2) / 3,
                            color: colorSchemes[6],
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "inv_code".tr,
                            hintStyle: TextStyle(
                              color: colorSchemes[5],
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Copy Button
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: copyLinkController.text));
                            copyLinkController.clear();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorSchemes[1],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  ((height / 8) * 0.40 * 0.5) * 0.7)),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all((height / 8) * 0.40 * 0.35),
                              child: Text(
                                "copy".tr,
                                style: TextStyle(
                                    fontSize:
                                        ((2 / 6) * (6 / 9) * height / 2) / 8,
                                    color: colorSchemes[6]),
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
    );
  }

  Widget emailActions(BuildContext context, double height, double width,
      List<MaterialColor> colorSchemes) {
    return Row(
      children: [
        //Left Button
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: (height / 8) * 0.40 * 0.5,
                bottom: (height / 8) * 0.40 * 0.35,
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => colorSchemes[3].withOpacity(0.3)),
                  ),
                  child: Text(
                    "cancel_option".tr,
                    style: TextStyle(
                      color: colorSchemes[4],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        //Right Button
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: (height / 8) * 0.40 * 0.5,
                bottom: (height / 8) * 0.40 * 0.35,
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                (height / 8) * 0.40 * 0.5),
                            side: const BorderSide(color: Colors.transparent))),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        !waitingForResponse
                            ? darken(colorSchemes[0], .1)
                            : colorSchemes[5]),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (height / 8) * 0.40 * 0.35,
                      vertical: (height / 8) * 0.40 * 0.5,
                    ),
                    child: Text(
                      !waitingForResponse
                          ? "send_option".tr
                          : "sending_option".tr,
                      style: TextStyle(color: colorSchemes[2]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget qrContent(List<MaterialColor> colorSchemes, double height) {
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular((height / 8) * 0.40 * 0.35)),
              child: QrImage(
                data: "0",
                backgroundColor: colorSchemes[3],
                foregroundColor: colorSchemes[6],
              ),
            ),
          ),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "scan_qr".tr,
                style: TextStyle(
                  color: colorSchemes[4],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget qrActions(BuildContext context, double height, double width,
      List<MaterialColor> colorSchemes) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: (height / 8) * 0.40 * 0.35,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular((height / 8) * 0.40 * 0.5),
                    side: const BorderSide(color: Colors.transparent))),
            backgroundColor: MaterialStateProperty.all<Color>(colorSchemes[3]),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (height / 8) * 0.40 * 0.35,
              vertical: (height / 8) * 0.40 * 0.5,
            ),
            child: Text(
              "close".tr,
              style: TextStyle(color: colorSchemes[4]),
            ),
          ),
        ),
      ),
    );
  }
}
