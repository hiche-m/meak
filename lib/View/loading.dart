import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meak/Models/profile.dart';
import 'package:meak/View/home.dart';
import 'package:meak/Utils/Services/auth.dart';
import 'package:provider/provider.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  late Stream<String?> userIdStream;
  @override
  void initState() {
    super.initState();
    userIdStream = Auth().userId;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<String?>.value(value: userIdStream, initialData: null),
      ],
      child: const Home(),
    );
  }
}
