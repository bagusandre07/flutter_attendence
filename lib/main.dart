import 'package:flutter/material.dart';
import 'package:online_attendence/model/user.dart';
import 'package:online_attendence/pages/HomesPages/homePage.dart';
import 'package:online_attendence/pages/loginPages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: CheckAuth());
  }
}


class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  late SharedPreferences sharedPreferences;
  bool userAvalaible = false;
  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      if (sharedPreferences.getString('userid') != null) {
        setState(() {
          userAvalaible = true;
          User.username = sharedPreferences.getString('userid')!;
        });
      }
    } catch (e) {
      setState(() {
        userAvalaible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvalaible ? HomePages() : LoginPage();
  }
}
