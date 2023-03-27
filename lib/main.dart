import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:meak/Models/member.dart';
import 'package:meak/Models/profile.dart';
import 'package:meak/View/home.dart';
import 'package:meak/View/loading.dart';
import 'package:meak/View/settings.dart';
import 'package:meak/Utils/lang/lang_string.dart';
import 'package:meak/Utils/themes.dart';
import 'firebase_options.dart';

//EN: English
//FR: French
String selectedLang = "EN";

int defaultTheme = 0;

Map<String, bool> defaultNots = {
  "App_Not": true,
  "Chat_Not": true,
};
List<Member> members = [
  Member(
    uid: "1",
    name: "Chaimaa",
    pic:
        "https://www.letudiant.fr/static/uploads/mediatheque/ETU_ETU/3/8/2271738-outlook-wrukscxa-300x250.png",
  ),
  Member(
    uid: "0",
    name: "Hichem",
    pic: "https://alfitude.com/wp-content/uploads/2019/09/Anthony-Ramos.jpg",
    isOwner: true,
  ),
  Member(
    uid: "3",
    name: "Idriss",
  ),
  Member(
    uid: "2",
    name: "Amina",
    pic:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Mona_Lisa-restored.jpg/1200px-Mona_Lisa-restored.jpg",
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "1567459190367812",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    translations: LangString(),
    locale: const Locale('en', 'US'),
    theme: ThemeData(
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: lighten(swatchList[selectedTheme][0], .3)),
      fontFamily: 'Ubuntu',
      primarySwatch: swatchList[selectedTheme][0],
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: swatchList[selectedTheme][0]),
    ),
    initialRoute: '/',
    routes: {
      "/": (context) => const Loading(),
    },
  ));
}
