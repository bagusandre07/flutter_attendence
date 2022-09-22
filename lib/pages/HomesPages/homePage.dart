import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:online_attendence/pages/HomesPages/dashboard.dart';
import 'package:online_attendence/pages/HomesPages/historypages.dart';
import 'package:online_attendence/pages/HomesPages/profilepages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user.dart';
import '../../services/location_services.dart';

class HomePages extends StatefulWidget {
  const HomePages({Key? key}) : super(key: key);

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  double screenHeight = 0;
  double screenWidth = 0;
  int currentindex = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    List<IconData> navigationIcons = [
      FontAwesomeIcons.calendarWeek,
      FontAwesomeIcons.check,
      FontAwesomeIcons.user
    ];
    return Scaffold(
      body: IndexedStack(
        index: currentindex,
        children: [HistoryPages(), TodayAttendence(), ProfilePage()],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.only(left: 12, right: 12, bottom: 25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(3, 2))
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentindex = i;
                    });
                  },
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navigationIcons[i],
                        color: i == currentindex ? Colors.red : Colors.black,
                        size: i == currentindex ? 30 : 24,
                      ),
                    ],
                  )),
                ))
              }
            ],
          ),
        ),
      ),
    );
  }
}
