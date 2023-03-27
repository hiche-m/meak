import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meak/Utils/Services/auth.dart';
import 'package:meak/Utils/TextFormulations.dart';
import 'package:meak/Utils/themes.dart';

class LogInSignUpMenu {
  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? lastName;
  String? firstName;
  String? newPassword;
  String? repeatPassword;
  String? signupEmail;
  String? loginEmail;
  String? password;

  bool lastNameErrored = false;
  bool firstNameErrored = false;
  bool newPasswordErrored = false;
  bool repeatPasswordErrored = false;
  bool signupEmailErrored = false;
  bool loginEmailErrored = false;
  bool passwordErrored = false;

  bool lastNameEmpty = true;
  bool firstNameEmpty = true;
  bool newPasswordEmpty = true;
  bool repeatPasswordEmpty = true;
  bool signupEmailEmpty = true;
  bool loginEmailEmpty = true;
  bool passwordEmpty = true;

  bool signup = false;

  bool processing = false;

  final _signupFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();

  int selectedTheme = 0;
  int initialIndex = 0;

  Future<dynamic> showLogInOrSignUpMenu(
      BuildContext context, bool exist, double height, double width) {
    initialIndex = exist ? 0 : 1;
    signup = exist ? false : true;
    double loginHeight =
        height / 2 - (0.4 * (5 / 6) * (6 / 9) * (height / 2) - 4) * 0.855;
    double signupHeight =
        (0.4 * (5 / 6) * (6 / 9) * (height / 2) - 4) * 0.855 + height / 2;
    PageController contentController = PageController(
        keepPage: true, viewportFraction: 1, initialPage: initialIndex);
    PageController actionsController = PageController(
        keepPage: true, viewportFraction: 1, initialPage: initialIndex);
    List<MaterialColor> colorSchemes = swatchList[selectedTheme];
    return showDialog(
        barrierDismissible: processing ? false : true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              //Dialog Size
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: signup ? signupHeight : loginHeight,
                width: width / 1.2,
                decoration: BoxDecoration(
                    color: colorSchemes[2],
                    border: Border.all(color: Colors.transparent),
                    borderRadius:
                        BorderRadius.all(Radius.circular((height / 8) * 0.40))),
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
                            onTap: processing
                                ? null
                                : () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.close_rounded,
                                color: processing
                                    ? Colors.grey.shade700
                                    : colorSchemes[0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Content
                    Expanded(
                      flex: signup ? 6 : 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Login or Signup
                          Expanded(
                            flex: signup ? 1 : 2,
                            child: Row(
                              children: [
                                //Login
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (signup) {
                                          clearErrors();
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
                                            signup = !signup;
                                          });
                                        }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: !signup
                                                ? colorSchemes[1]
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  (height / 8) * 0.40 * 0.25),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "log-in".tr,
                                              style: TextStyle(
                                                color: signup
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
                                //Signup
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        if (!signup) {
                                          clearErrors();
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
                                            signup = !signup;
                                          });
                                        }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: signup
                                                ? colorSchemes[1]
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  (height / 8) * 0.40 * 0.25),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "sign-up".tr,
                                              style: TextStyle(
                                                color: signup
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
                                loginContent(
                                    setState, colorSchemes, height, width),
                                signupContent(
                                    setState, colorSchemes, height, width),
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
                            loginActions(
                                context, setState, height, width, colorSchemes),
                            signupActions(
                                context, setState, height, width, colorSchemes),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void clearErrors() {
    lastNameErrored = false;
    firstNameErrored = false;
    newPasswordErrored = false;
    repeatPasswordErrored = false;
    signupEmailErrored = false;
    loginEmailErrored = false;
    passwordErrored = false;
  }

  void clearInputs() {
    lastNameController.clear();
    firstNameController.clear();
    newPasswordController.clear();
    repeatPasswordController.clear();
    signupEmailController.clear();
    loginEmailController.clear();
    passwordController.clear();
  }

  Widget loginContent(void Function(void Function()) setState,
      List<MaterialColor> colorSchemes, double height, double width) {
    return Form(
      key: _loginFormKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          children: [
            //Email fill section
            Expanded(
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: loginEmailErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: loginEmailController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "email_ex".tr,
                                  hintStyle: TextStyle(
                                    color: loginEmailErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !loginEmailEmpty
                                      ? InkWell(
                                          onTap: () {
                                            loginEmailController.clear();
                                            setState(() {
                                              loginEmailEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: loginEmailErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      loginEmailErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      loginEmailErrored = true;
                                    });
                                    return "Value empty";
                                  }
                                  setState(() {
                                    loginEmailErrored
                                        ? loginEmailErrored = false
                                        : null;
                                  });
                                  return null;
                                },
                                onChanged: (value) {
                                  loginEmailErrored == true
                                      ? setState(() {
                                          loginEmailErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    loginEmailEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  loginEmail = value!.trim();
                                },
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
            //Password section
            Expanded(
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
                            "${"your_pass".tr}: ",
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: passwordErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: passwordController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "enter_yp".tr,
                                  hintStyle: TextStyle(
                                    color: passwordErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !passwordEmpty
                                      ? InkWell(
                                          onTap: () {
                                            passwordController.clear();
                                            setState(() {
                                              passwordEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: passwordErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      passwordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      passwordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.length < 8) {
                                    setState(() {
                                      passwordErrored = true;
                                    });
                                    return "This password is too short";
                                  }
                                  setState(() {
                                    passwordErrored == true
                                        ? passwordErrored = false
                                        : null;
                                  });
                                  return null;
                                },
                                onChanged: (value) {
                                  passwordErrored == true
                                      ? setState(() {
                                          passwordErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    passwordEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  password = value!;
                                },
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
          ],
        ),
      ),
    );
  }

  Widget loginActions(
      BuildContext context,
      void Function(void Function()) setState,
      double height,
      double width,
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
                  onPressed: processing
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => colorSchemes[3].withOpacity(0.3)),
                  ),
                  child: Text(
                    "cancel_option".tr,
                    style: TextStyle(
                      color:
                          processing ? Colors.grey.shade500 : colorSchemes[4],
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
                  onPressed: processing
                      ? null
                      : () async {
                          if (_loginFormKey.currentState!.validate()) {
                            _loginFormKey.currentState!.save();
                            setState(() {
                              processing = true;
                            });
                            String? login = await Auth().signInWithEmail(
                                email: loginEmail!, password: password!);
                            bool successful = login == null;
                            setState(() {
                              processing = false;
                            });
                            if (successful) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                loginEmailErrored = true;
                                passwordErrored = true;
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(login.tr),
                              ));
                            }
                          }
                        },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                (height / 8) * 0.40 * 0.5),
                            side: const BorderSide(color: Colors.transparent))),
                    backgroundColor: MaterialStateProperty.all<Color>(processing
                        ? Colors.grey.shade500
                        : darken(colorSchemes[0], .1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (height / 8) * 0.40 * 0.35,
                      vertical: (height / 8) * 0.40 * 0.5,
                    ),
                    child: Text(
                      "log-in".tr,
                      style: TextStyle(
                          color: processing
                              ? Colors.grey.shade700
                              : colorSchemes[2]),
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

  Widget signupContent(void Function(void Function()) setState,
      List<MaterialColor> colorSchemes, double height, double width) {
    return Form(
      key: _signupFormKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          children: [
            //Name
            Expanded(
              flex: 5,
              child: FractionallySizedBox(
                widthFactor: 0.95,
                child: Row(
                  children: [
                    //First Name
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: firstNameErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: firstNameController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: !firstNameEmpty
                                        ? InkWell(
                                            onTap: () {
                                              firstNameController.clear();
                                              setState(() {
                                                firstNameEmpty = true;
                                              });
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: ((2 / 6) *
                                                      (6 / 9) *
                                                      height /
                                                      2) /
                                                  3,
                                              color: firstNameErrored
                                                  ? Colors.grey.shade900
                                                      .withOpacity(0.5)
                                                  : colorSchemes[5],
                                            ),
                                          )
                                        : null,
                                    errorStyle: const TextStyle(fontSize: 0.01),
                                    border: InputBorder.none,
                                    hintText: "first_name".tr,
                                    hintStyle: TextStyle(
                                      color: firstNameErrored
                                          ? Colors.grey.shade900
                                              .withOpacity(0.5)
                                          : colorSchemes[5],
                                    )),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      firstNameErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      firstNameErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.length > 30) {
                                    setState(() {
                                      firstNameErrored = true;
                                    });
                                    return "This name is too long";
                                  }
                                  firstNameErrored == true
                                      ? setState(() {
                                          firstNameErrored = false;
                                        })
                                      : null;
                                  return null;
                                },
                                onChanged: (value) {
                                  firstNameErrored == true
                                      ? setState(() {
                                          firstNameErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    firstNameEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  firstName = capFix(value!);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    //Last Name
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: lastNameErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: lastNameController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "last_name".tr,
                                  hintStyle: TextStyle(
                                    color: lastNameErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !lastNameEmpty
                                      ? InkWell(
                                          onTap: () {
                                            lastNameController.clear();
                                            setState(() {
                                              lastNameEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: lastNameErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      lastNameErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      lastNameErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.length > 30) {
                                    setState(() {
                                      lastNameErrored = true;
                                    });
                                    return "This name is too long";
                                  }
                                  lastNameErrored == true
                                      ? setState(() {
                                          lastNameErrored = false;
                                        })
                                      : null;
                                  return null;
                                },
                                onChanged: (value) {
                                  lastNameErrored == true
                                      ? setState(() {
                                          lastNameErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    lastNameEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  lastName = capFix(value!);
                                },
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
            //Email fill section
            Expanded(
              flex: 5,
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: signupEmailErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: signupEmailController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "email_ex".tr,
                                  hintStyle: TextStyle(
                                    color: signupEmailErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !signupEmailEmpty
                                      ? InkWell(
                                          onTap: () {
                                            signupEmailController.clear();
                                            setState(() {
                                              signupEmailEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: signupEmailErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      signupEmailErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      signupEmailErrored = true;
                                    });
                                    return "Value empty";
                                  }
                                  setState(() {
                                    signupEmailErrored
                                        ? signupEmailErrored = false
                                        : null;
                                  });
                                  return null;
                                },
                                onChanged: (value) {
                                  signupEmailErrored == true
                                      ? setState(() {
                                          signupEmailErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    signupEmailEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  signupEmail = value!.trim();
                                },
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
            //Password
            Expanded(
              flex: 5,
              child: FractionallySizedBox(
                widthFactor: 0.95,
                child: Row(
                  children: [
                    //Password
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: newPasswordErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: newPasswordController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "new_pass".tr,
                                  hintStyle: TextStyle(
                                    color: newPasswordErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !newPasswordEmpty
                                      ? InkWell(
                                          onTap: () {
                                            newPasswordController.clear();
                                            setState(() {
                                              newPasswordEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: newPasswordErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      newPasswordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      newPasswordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.length < 8) {
                                    setState(() {
                                      newPasswordErrored = true;
                                    });
                                    return "This password is too short";
                                  }
                                  setState(() {
                                    newPasswordErrored == true
                                        ? newPasswordErrored = false
                                        : null;
                                  });
                                  return null;
                                },
                                onChanged: (value) {
                                  newPasswordErrored == true
                                      ? setState(() {
                                          newPasswordErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    newPasswordEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                onSaved: (String? value) {
                                  newPassword = value!;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    //Repeat Password
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: repeatPasswordErrored
                                  ? Colors.red.shade300
                                  : colorSchemes[3],
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                  Radius.circular((height / 8) * 0.40 * 0.5))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                readOnly: processing,
                                maxLines: 1,
                                controller: repeatPasswordController,
                                textInputAction: TextInputAction.send,
                                style: TextStyle(
                                  fontSize:
                                      ((2 / 6) * (6 / 9) * height / 2) / 3,
                                  color: colorSchemes[6],
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  border: InputBorder.none,
                                  hintText: "repeat_np".tr,
                                  hintStyle: TextStyle(
                                    color: repeatPasswordErrored
                                        ? Colors.grey.shade900.withOpacity(0.5)
                                        : colorSchemes[5],
                                  ),
                                  suffixIcon: !repeatPasswordEmpty
                                      ? InkWell(
                                          onTap: () {
                                            repeatPasswordController.clear();
                                            setState(() {
                                              repeatPasswordEmpty = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: ((2 / 6) *
                                                    (6 / 9) *
                                                    height /
                                                    2) /
                                                3,
                                            color: repeatPasswordErrored
                                                ? Colors.grey.shade900
                                                    .withOpacity(0.5)
                                                : colorSchemes[5],
                                          ),
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  repeatPasswordErrored == true
                                      ? setState(() {
                                          repeatPasswordErrored = false;
                                        })
                                      : null;
                                  setState(() {
                                    repeatPasswordEmpty =
                                        value.isEmpty ? true : false;
                                  });
                                },
                                validator: (String? value) {
                                  if (value == null) {
                                    setState(() {
                                      repeatPasswordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value.isEmpty) {
                                    setState(() {
                                      repeatPasswordErrored = true;
                                    });
                                    return "Value empty";
                                  }

                                  if (value != newPasswordController.text) {
                                    setState(() {
                                      repeatPasswordErrored = true;
                                    });
                                    return "Passwords do not match";
                                  }
                                  setState(() {
                                    repeatPasswordErrored == true
                                        ? repeatPasswordErrored = false
                                        : null;
                                  });
                                  return null;
                                },
                                onSaved: (String? value) {
                                  repeatPassword = value!;
                                },
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
            //Privacy Policy
            Expanded(
              flex: 2,
              child: FractionallySizedBox(
                heightFactor: 0.9,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: " ${"signup_privacy_terms".tr} ",
                        style: TextStyle(
                          color: colorSchemes[6],
                        ),
                      ),
                      TextSpan(
                        text: "use_terms".tr,
                        style: TextStyle(
                          color: colorSchemes[0],
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(
                        text: " ${"and".tr} ",
                        style: TextStyle(
                          color: colorSchemes[6],
                        ),
                      ),
                      TextSpan(
                        text: "privacy_policy".tr,
                        style: TextStyle(
                          color: colorSchemes[0],
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(
                        text: ". ",
                        style: TextStyle(
                          color: colorSchemes[6],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signupActions(
      BuildContext context,
      void Function(void Function()) setState,
      double height,
      double width,
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
                  onPressed: processing
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => colorSchemes[3].withOpacity(0.3)),
                  ),
                  child: Text(
                    "cancel_option".tr,
                    style: TextStyle(
                      color:
                          processing ? Colors.grey.shade500 : colorSchemes[4],
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
                  onPressed: processing
                      ? null
                      : () async {
                          if (_signupFormKey.currentState!.validate()) {
                            _signupFormKey.currentState!.save();
                            setState(() {
                              processing = true;
                            });
                            String? signup = await Auth().signUpWithEmail(
                              email: signupEmail!,
                              password: newPassword!,
                              firstName: firstName!,
                              lastName: lastName!,
                            );
                            bool successful = signup == null;
                            setState(() {
                              processing = false;
                            });
                            if (successful) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                loginEmailErrored = true;
                                passwordErrored = true;
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(signup.tr),
                              ));
                            }
                          }
                        },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                (height / 8) * 0.40 * 0.5),
                            side: const BorderSide(color: Colors.transparent))),
                    backgroundColor: MaterialStateProperty.all<Color>(processing
                        ? Colors.grey.shade500
                        : darken(colorSchemes[0], .1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (height / 8) * 0.40 * 0.35,
                      vertical: (height / 8) * 0.40 * 0.5,
                    ),
                    child: Text(
                      "sign-up".tr,
                      style: TextStyle(
                          color: processing
                              ? Colors.grey.shade700
                              : colorSchemes[2]),
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
}
