import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meak/main.dart';
import 'package:meak/Utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    init();
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
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      backgroundColor: swatchList[selectedTheme][2],
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: swatchList[selectedTheme][0]),
        ),
        backgroundColor: swatchList[selectedTheme][3],
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {},
          style: TextStyle(
            color: swatchList[selectedTheme][4],
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 8.0),
            border: InputBorder.none,
            hintText: "search_item".tr,
            hintStyle: TextStyle(
              color: swatchList[selectedTheme][4],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_rounded,
                  color: swatchList[selectedTheme][0]),
            ),
          )
        ],
      ),
    );
  }
}
