import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:online_attendence/pages/HomesPages/homePage.dart';
import 'package:online_attendence/pages/registerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _Username = TextEditingController();
  TextEditingController _Password = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final String sUrl = "https://attendence.cleverapps.io/";

  @override
  _cekLogin() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var curl = "karyawan/login?username=" +
        _Username.text +
        "&password=" +
        _Password.text;
    if (_Username.text == "" || _Password.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: const Text("Username Dan Password tidak boleh kosong")));
    } else {
      try {
        var res = await http.get(Uri.parse(sUrl + curl));
        if (res.statusCode == 200) {
          var response = jsonDecode(res.body);

          setState(() {
            sharedPreferences
                .setString('userid', response[0]['username'])
                .then((_) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePages()));
            });
          });
        } else if (res.statusCode == 401) {
          var response = jsonDecode(res.body);

          var msg = response['response'];
          print(msg);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$msg")));
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xffFF9F29),
                    Color(0xffE8AA42),
                    const Color(0xffFAC213),
                    Color(0xffFFEE63),
                  ])),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 120,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo-kabupaten.png",
                      width: 150,
                      height: 200,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'SIK TENJOLAYA',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NIK'),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xffF9FFA4),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black87,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ]),
                          height: 60,
                          child: TextField(
                            controller: _Username,
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(top: 14),
                                prefixIcon: Icon(
                                  Icons.add_card_rounded,
                                  color: Color(0xffFECD70),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        const Text('PIN'),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xffF9FFA4),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black87,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ]),
                          height: 60,
                          child: TextField(
                            controller: _Password,
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(top: 14),
                                prefixIcon: Icon(
                                  Icons.key_outlined,
                                  color: Color(0xffFECD70),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                                child: Container(
                                  child: const Text(
                                    "Belum Punya Akun / Daftar!",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                onTap: (() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage()),
                                  );
                                })),
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: Container(
                                height: 50,
                                width: 250,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      const BoxShadow(
                                          color: const Color(0xffFF8D29),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: Offset(4, 4)),
                                      const BoxShadow(
                                          color: Colors.white,
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: Offset(-4, -4))
                                    ]),
                                child: const Center(child: const Text("Login")),
                              ),
                              onTap: () {
                                _cekLogin();
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
