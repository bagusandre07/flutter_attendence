import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:online_attendence/errorpages.dart';
import 'package:online_attendence/model/user.dart';
import 'package:online_attendence/services/location_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:http/http.dart' as http;

class TodayAttendence extends StatefulWidget {
  const TodayAttendence({Key? key}) : super(key: key);

  @override
  State<TodayAttendence> createState() => _TodayAttendenceState();
}

class _TodayAttendenceState extends State<TodayAttendence> {
  final String sUrl = "https://attendence.cleverapps.io/";
  final String wUrl = "https://api.openweathermap.org/";
  final String tUrl = " https://translate.googleapis.com/translate_a/";

  double screenHeight = 0;
  double screenWidth = 0;
  String checkin = "--/--";
  String checkout = "--/--";
  String name = " ";
  DateTime ntptime = DateTime.now();
  String address = "";
  String currentAdress = " ";
  double dTemp = 0;
  int temp = 0;
  Icon dataicon = Icon(Icons.cloud);
  late Position currentposition;
  double lat = 1;
  double lon = 1;
  String street = "";
  String clouds = "";
  bool isloading = true;
  @override
  void initState() {
    getinfo();
    _loadNtpTime();
    getdate();
    _determinePosition();
    // startLocation();
    super.initState();
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAdress =
            "${place.locality}, ${place.street},${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
    var endurl =
        "data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=5bb29f6f9c10737e0fb5fae86d250ad8";
    try {
      var res = await http.get(Uri.parse(wUrl + endurl));
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        print(response);
        print(response['weather'][0]['main']);
        setState(() {
          dTemp = response['main']['temp'];
          temp = dTemp.toInt();
          street = response['name'];
          clouds = response['weather'][0]['description'];
          isloading = false;
        });
      }
    } catch (e) {}
  }

//VALIDASI TANGGAL DENGAN NETWORK TIME
  void _loadNtpTime() async {
    setState(() async {
      ntptime = await NTP.now();
      if (DateFormat('dd MMMM yyyy').format(DateTime.now()) !=
          DateFormat('dd MMMM yyyy').format(ntptime)) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ErrorPages()));
      }
    });
  }

//AMBIL INFORMASI USER DARI LOCAL STORAGE

  void getinfo() async {
    SharedPreferences mailpref = await SharedPreferences.getInstance();
    setState(() {
      name = mailpref.getString('userid')!;
      User.username = mailpref.getString('userid')!;
    });
  }

//CEK ABSENSI DATA PER HARI
  @override
  void getdate() async {
    var getinfo = "record/getinfo?username=" +
        User.username +
        "&date=" +
        DateFormat('dd MMMM yyyy').format(ntptime);

    var res = await http.get(Uri.parse(sUrl + getinfo));
    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);
      setState(() {
        checkin = response['rows'][0]['checkin'];
        if (response['rows'][0]['checkout'] != null) {
          checkout = response['rows'][0]['checkout'];
        }
      });
      print(response);
    } else if (res.statusCode == 404) {
      var response = jsonDecode(res.body);
      print(response);
    }
  }

  @override
  void _attendence() async {
    var curl = "record/checking?username=" +
        User.username +
        "&date=" +
        DateFormat('dd MMMM yyyy').format(ntptime);

    try {
      var res = await http.get(Uri.parse(sUrl + curl));
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        var checkout = "record/checkout?checkout=" +
            DateFormat('HH:mm').format(DateTime.now()) +
            "&date=" +
            DateFormat('dd MMMM yyyy').format(DateTime.now()) +
            "&username=" +
            User.username;
        try {
          var res = await http.post(Uri.parse(sUrl + checkout));
          if (res.statusCode == 200) {
            var response = jsonDecode(res.body);
            setState(() async {
              getdate();
            });
          }
        } catch (e) {}
      } else if (res.statusCode == 401) {
        var response = jsonDecode(res.body);
        var checkin = "record/checkin?username=" +
            User.username +
            "&checkin=" +
            DateFormat('HH:mm').format(ntptime) +
            "&date=" +
            DateFormat('dd MMMM yyyy').format(ntptime);
        try {
          var res = await http.post(Uri.parse(sUrl + checkin));
          if (res.statusCode == 200) {
            var response = jsonDecode(res.body);
            setState(() {
              getdate();
            });
            print(response);
          }
        } catch (e) {}
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 32),
                child: Text(
                  "Selamat Datang \n $name",
                  style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  isloading == false
                      ? Container(
                          height: 100,
                          decoration: BoxDecoration(
                              color: Color(0xff827397),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xff363062),
                                    blurRadius: 11,
                                    offset: Offset(6, 5))
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          margin: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Column(
                            children: [
                              Container(
                                child: Icon(Icons.cloud),
                              ),
                              Text(
                                "$street",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white60),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Text(
                                      "$temp° C",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      " $clouds ",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                      : Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.04),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
                alignment: Alignment.centerLeft,
                child: RichText(
                    text: TextSpan(
                        text: ntptime.day.toString(),
                        style: TextStyle(
                            color: Colors.red, fontSize: screenWidth / 24),
                        children: [
                      TextSpan(
                          text: DateFormat(' MMMM yyyy').format(ntptime),
                          style: TextStyle(
                              color: Colors.black, fontSize: screenWidth / 20))
                    ]))),
          ),
          StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
                      style: TextStyle(
                          fontSize: screenWidth / 26, color: Colors.black54),
                    ));
              }),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 32),
            child: Text(
              "Status Hari Ini",
              style: TextStyle(
                  fontFamily: "NexaRegular", fontSize: screenWidth / 18),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 32),
            height: 150,
            decoration: BoxDecoration(
                color: Color(0xff874C62),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xffC98474),
                      blurRadius: 11,
                      offset: Offset(6, 5))
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                              fontSize: screenWidth / 24,
                              color: Colors.black26),
                        ),
                        Text(
                          "$checkin",
                          style: TextStyle(
                            fontSize: screenWidth / 18,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Check Out",
                            style: TextStyle(
                                fontSize: screenWidth / 24,
                                color: Colors.black26)),
                        Text(
                          "$checkout",
                          style: TextStyle(
                            fontSize: screenWidth / 18,
                          ),
                        )
                      ],
                    ),
                  )
                ]),
          ),
          checkout == "--/--"
              ? Container(
                  margin: EdgeInsets.only(top: 24),
                  child: Builder(builder: (context) {
                    final GlobalKey<SlideActionState> key = GlobalKey();
                    return SlideAction(
                        text: "Geser Untuk Absen",
                        key: key,
                        onSubmit: () {
                          _attendence();
                          if (currentposition != 1) {
                            _determinePosition();
                          }
                        });
                  }),
                )
              : Container(
                  margin: EdgeInsets.only(top: 32, bottom: 32),
                  child: Text(
                    "Hari Ini Kamu Sudah Selesai Absen",
                    style: TextStyle(color: Color(0xffF24A72)),
                  ),
                ),
          currentAdress != " " ? Text("Lokasi : $currentAdress") : SizedBox(),
        ],
      ),
    ));
  }
}
