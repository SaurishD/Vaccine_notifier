import 'package:flutter/material.dart';
import './home.dart';

enum UserAge { EighteenPlus, FourtyfivePlus }
enum UserDose { Dose1, Dose2 }
enum VaccineType { All, CoviShield, Covaxine, SputnicV }

ThemeData themes = ThemeData(
  primarySwatch: Colors.purpleAccent[900], //0xFF263238
);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Enter Data",
      home: AppIntroScreen(),
    );
  }
}

class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({Key key}) : super(key: key);

  @override
  _AppIntroScreenState createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
 
  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
