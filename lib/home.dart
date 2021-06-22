import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './form.dart';

ThemeData themes = ThemeData(
  primarySwatch: Colors.purpleAccent[900], //0xFF263238
);

class HomePage extends MaterialPageRoute<Null> {
  HomePage()
      : super(builder: (BuildContext context) {
          return Home();
        });
}

class Home extends StatefulWidget {
  static String id = "home";
  final _HomeState _homeState = _HomeState();

  @override
  _HomeState createState() => _homeState;
}

class _HomeState extends State<Home> {
  String pincode = "";
  String distCode = "";
  List<dynamic> data = [];
  List<String> dose = ["","_dose1", "_dose2"];
  List<String> vaccine = ["All","COVISHIELD","COVAXIN","SPUTNIKV"];
  List<int> age = [18,30, 45];
  int ageIndex = 0;
  int doseIndex = 0;
  int vaccineIndex = 0;
  Color primaryFontColor = Colors.grey[700];
  FlutterLocalNotificationsPlugin _localNotifications;
  Timer fetchTimer;
  bool _enableNotification;
  bool _fetchByPincode = false;

  @override
  void initState() {
    super.initState();
    var androidInitialize = AndroidInitializationSettings('ic_launcher');
    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitialize);
    _localNotifications = FlutterLocalNotificationsPlugin();
    _localNotifications.initialize(initializationSettings);
  }

  Future _showNotification(int num) async {
    print("Notified");
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName", "Vaccines are available in your area");
    var notificationDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
        0,
        "Vaccines are available",
        num.toString() + " Slots are available in your city",
        notificationDetails,);
  }

  void _getData() async {
    final pref = await SharedPreferences.getInstance();
    _enableNotification = pref.getBool("notification") ?? false;
    //pincode = pref.getString('pincode');
    doseIndex = pref.getInt('dose');
  }

  Future<List> _fetchFromServer(int days) async {
    final DateTime now = DateTime.now();
    final DateTime day = DateTime(now.year, now.month, now.day + days);
    final DateFormat df = DateFormat("dd-MM-yyyy");
    String date = df.format(day);
    String uri;
    if (_fetchByPincode) {
      uri =
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=" +
              pincode +
              "&date=" +
              date;
    } else {
      uri =
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=" +
              distCode +
              "&date=" +
              date;
    }
    print(uri);
    var response = await http.get(Uri.parse(uri));
    return jsonDecode(response.body)['sessions'] as List;
  }

  void _fetchData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      distCode = pref.getString('districtCode') ?? "";
      pincode = pref.getString('pincode') ?? "";
      
      _fetchByPincode = pref.getBool("fetchPincode") ?? false;
      vaccineIndex = pref.getInt("vaccine") ?? 0;

      if (!_fetchByPincode && (distCode == "" || distCode == null)) {
        fetchTimer.cancel();
        Fluttertoast.showToast(
            msg: "Please enter all data",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
        Navigator.of(context).pushReplacement(MyCustomFormRoute());
        return;
      } else if (_fetchByPincode && (pincode == "" || pincode == null)) {
        fetchTimer.cancel();
        Fluttertoast.showToast(
            msg: "Please enter all data",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG);
        Navigator.of(context).pushReplacement(MyCustomFormRoute());
        return;
      }
      ageIndex = pref.getInt('age');
      doseIndex = pref.getInt('dose');
      print(distCode);
      var temp = await _fetchFromServer(1);
      temp =
          temp.where((val) => val['min_age_limit'] == age[ageIndex]).toList();
      if(vaccineIndex!=0){
        temp = temp.where((val)=> val['vaccine'] == vaccine[vaccineIndex]).toList();
      }
      data.clear();
      data.addAll(temp);
      //print(data);
      temp = await _fetchFromServer(0);
      temp =
          temp.where((val) => val['min_age_limit'] == age[ageIndex]).toList();
      if(vaccineIndex!=0){
        temp = temp.where((val)=> val['vaccine'] == vaccine[vaccineIndex]).toList();
      }
      data.addAll(temp);
      int total = 0;
      if (data.length == 0 && mounted) {
        Fluttertoast.showToast(
            msg: "No Centers found for given filters",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT);
        fetchTimer.cancel();
        Navigator.pushReplacement(context, MyCustomFormRoute());
      }
      for (var item in data) {
        total += item['available_capacity' + dose[doseIndex]];
      }
      if (total > 0 && _enableNotification) {
        //_enableNotification = false;
        _showNotification(total);
      }
      //print(data[0]['name']);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Color getColor(int i) {
    if (i > 0) return Colors.green;
    return Colors.red;
  }

  _HomeState() {
    _getData();
    _fetchData();

    const period = const Duration(seconds: 15);
    fetchTimer = new Timer.periodic(period, (Timer t) => _fetchData());
    //_fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: themes,
      home: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            backgroundColor: Colors.blueGrey[900],
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    _fetchData();
                  },
                  child: Icon(Icons.refresh, size: 26),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MyCustomFormRoute());
                  },
                  child: Icon(Icons.settings, size: 26),
                ),
              )
            ],
          ),
          body: ListView.builder(
            reverse: false,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data[index]['name'],
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryFontColor),
                      ),
                      const SizedBox(height: 12),
                      Text(data[index]['address'],
                          style: TextStyle(color: primaryFontColor)),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(data[index]['fee_type'],
                              style: TextStyle(color: primaryFontColor)),
                          VerticalDivider(),
                          Text(
                              "Available: " +
                                  data[index]['available_capacity' +
                                          dose[doseIndex]]
                                      .toString(),
                              style: TextStyle(
                                  color: getColor(data[index][
                                      'available_capacity' +
                                          dose[doseIndex]]))),
                          VerticalDivider(),
                          Text(
                              "Age: " +
                                  data[index]['min_age_limit'].toString() +
                                  '+',
                              style: TextStyle(color: primaryFontColor)),
                        ],
                      ),
                      Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(data[index]['vaccine'],
                                style: TextStyle(color: primaryFontColor)),
                            VerticalDivider(),
                            Text(data[index]['date'],
                                style: TextStyle(color: primaryFontColor)),
                          ]),
                    ],
                  ),
                ),
              );
            },
            itemCount: data.length,
          )),
    );
  }
}
