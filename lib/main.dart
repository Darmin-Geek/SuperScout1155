//Import packages

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//import app files
import 'autoMatchScout.dart';
import 'teleOpMatchScout.dart';
import 'driverRatingMatchScout.dart';
import 'pitScout.dart';

import 'schedule.dart';
import 'matchPageSchedule.dart';
import 'selectionPitScout.dart';

Future<File> _getNameFile() async {
  // get the path to the document directory.
  String dir = (await getApplicationDocumentsDirectory()).path;
  print(dir);
  //initialize the file at the directory
  File currentFile = File('$dir/Name.txt');
  print(currentFile);
  //actually create the file IF it does not exist
  File newFile = await currentFile.create();
  return newFile;
}

//goToFunctions take in the context of where they are called and change the page

void Function() goToMainMenu(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MainPage()),
  );
}

void Function() goToPitScoutingTeamScreen(BuildContext context, String teamName,
    String teamNumber, bool hasProgrammingPitScout) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => PitScoutingTeamPage(
              teamName: teamName,
              teamNumber: teamNumber,
              hasProgrammingPitScout: hasProgrammingPitScout,
            )),
  );
}

void Function() goToPitScoutingScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PitScoutingPage()),
  );
}

void Function() goToPitScheduleScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SchedulePage()),
  );
}

//open individual match data from the schedule
void Function() goToPitIndividualMatchScreen(
    BuildContext context, List dataToSend) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            IndividualMatchPage(teamsAndScouters: dataToSend)),
  );
}

void Function() goToAutoMatchScout(BuildContext context, Map inputMap) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AutoMatchScout(
                allData: inputMap,
              )));
}

void Function() goToTeleOpMatchScout(BuildContext context, Map inputMap) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TeleOpMatchScout(
                allData: inputMap,
              )));
}

void Function() goToDriverRatingMatchScout(BuildContext context, Map inputMap) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DriverRatePage(
                allData: inputMap,
              )));
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

// make function that takes a FLutterLocalNotifcationsPlugin, and initializes it
// don't call it initialize

class MainPageState extends State<MainPage> {
  TextEditingController nameController = new TextEditingController();

  //make construcor for class and put initFunction in it
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Main page")),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            //Column arranges its widgets in a column of a fixed size on the page
            child: Column(
          children: <Widget>[
            //padding is space between widgets
            Padding(
              padding: EdgeInsets.all(10),
            ),
            //Text field is a text entry line, the text is stored in the controller
            //hint text is text shown when there is no user inputed text, (when they open the page)
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Name"),
              onChanged: (name) async {
                File nameFile = await _getNameFile();
                nameFile.writeAsStringSync(name);
                print(nameFile.readAsStringSync());
              },
            ),
            Padding(
              padding: EdgeInsets.all(20),
            ),
            ElevatedButton(
                onPressed: () async {
                  FlutterLocalNotificationsPlugin().initialize(
                      InitializationSettings(
                          android: AndroidInitializationSettings("notify")));
                  FlutterLocalNotificationsPlugin().cancelAll();

                  tz.initializeTimeZones();
                  print(tz.UTC);

                  String name = (await _getNameFile()).readAsStringSync();

                  print("name is:" + name + "|");
                  bool hasGoneThrough = false;
                  var matchDocs =
                      await Firestore().collection("matches").getDocuments();
                  for (var match in matchDocs.documents) {
                    var scoutDocs = await match.reference
                        .collection("teams")
                        .getDocuments();
                    for (var scout in scoutDocs.documents) {
                      print(scout.data["scouter"] == name);
                      print(tz.TZDateTime.fromMillisecondsSinceEpoch(
                          tz.getLocation("America/New_York"),
                          match.data["matchPredictedTime"] * 1000));
                      print("comparer" +
                          tz.TZDateTime.fromMillisecondsSinceEpoch(
                                  tz.getLocation("America/New_York"),
                                  match.data["matchPredictedTime"] * 1000)
                              .toLocal()
                              .toString() +
                          tz.TZDateTime.now(tz.getLocation("America/New_York"))
                              .toLocal()
                              .toString());
                      if (scout.data["scouter"] == name &&
                          tz.TZDateTime.fromMillisecondsSinceEpoch(
                                  tz.getLocation("America/New_York"),
                                  match.data["matchPredictedTime"] * 1000)
                              .toLocal()
                              .isAfter(tz.TZDateTime.now(
                                      tz.getLocation("America/New_York"))
                                  .toLocal())) {
                        print("created 1");
                        hasGoneThrough = true;
                        await FlutterLocalNotificationsPlugin().zonedSchedule(
                            Random().nextInt(10000),
                            "3 minute alert",
                            "Match#" +
                                match.data["matchNum"].toString() +
                                "  Team #" +
                                scout.documentID.substring(3) +
                                " " +
                                scout.data["allance"] +
                                " alliance",
                            tz.TZDateTime.fromMillisecondsSinceEpoch(
                                    tz.getLocation("America/New_York"),
                                    match.data["matchPredictedTime"] * 1000)
                                .subtract(Duration(minutes: 3)),
                            NotificationDetails(
                                android: AndroidNotificationDetails(
                                    "matchIn3Id",
                                    "3 minute alerts",
                                    "Alerts that show 3 minutes before the predicted time of the match",
                                    fullScreenIntent: true,
                                    category: "Robotics",
                                    priority: Priority.high)),
                            androidAllowWhileIdle: true,
                            uiLocalNotificationDateInterpretation:
                                UILocalNotificationDateInterpretation
                                    .absoluteTime);
                        await FlutterLocalNotificationsPlugin().zonedSchedule(
                            Random().nextInt(10000),
                            "1 minute alert",
                            "Match#" +
                                match.data["matchNum"].toString() +
                                "  Team #" +
                                scout.documentID.substring(3) +
                                " " +
                                scout.data["allance"] +
                                " alliance",
                            tz.TZDateTime.fromMillisecondsSinceEpoch(
                                    tz.getLocation("America/New_York"),
                                    match.data["matchPredictedTime"] * 1000)
                                .subtract(Duration(minutes: 1)),
                            NotificationDetails(
                                android: AndroidNotificationDetails(
                                    "matchIn1Id",
                                    "1 minute alerts",
                                    "Alerts that show 1 minute before the predicted time of the match",
                                    fullScreenIntent: true,
                                    category: "Robotics",
                                    priority: Priority.high)),
                            androidAllowWhileIdle: true,
                            uiLocalNotificationDateInterpretation:
                                UILocalNotificationDateInterpretation
                                    .absoluteTime);
                      }
                    }
                  }

                  await FlutterLocalNotificationsPlugin().zonedSchedule(
                      0,
                      "Notifications have been created",
                      "If you fully close the app, the notifications may be discarded and you will have to press the button again.",
                      tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
                      NotificationDetails(
                          android: AndroidNotificationDetails(
                              "testsId",
                              "Other",
                              "Other notifications such as ones to inform you that notifcations have been created.",
                              fullScreenIntent: true,
                              category: "Robotics",
                              priority: Priority.high)),
                      androidAllowWhileIdle: true,
                      uiLocalNotificationDateInterpretation:
                          UILocalNotificationDateInterpretation.absoluteTime);
                  /*FlutterLocalNotificationsPlugin().show(
                      1,
                      "right now",
                      "this body should show now",
                      NotificationDetails(
                          AndroidNotificationDetails(
                            "com.android.example.WORK_EMAIL",
                            "NameTestChannel1",
                            "test description1",
                          ),
                          IOSNotificationDetails()));*/
                  print("scheduled");
                  print("has gone:" + hasGoneThrough.toString());
                },
                child: Text("Schedule Notifications")),
            Padding(
              padding: EdgeInsets.all(20),
            ),
            ElevatedButton(
              child: Text("Pit scout", textScaleFactor: 3),
              onPressed: () {
                goToPitScoutingScreen(context);
              },
              //color is color of the button
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFFFC107))),
            ),

            Padding(
              padding: EdgeInsets.all(20),
            ),
            ElevatedButton(
              child: Text("Schedule", textScaleFactor: 3),
              onPressed: () {
                goToPitScheduleScreen(context);
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color((0xFFFFC107)))),
            ),

            Padding(
              padding: EdgeInsets.all(20),
            ),
            ElevatedButton(
              child: Text("Match Scout", textScaleFactor: 3),
              onPressed: () {
                goToAutoMatchScout(context, {"teamNum": -10});
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFFFC107))),
            ),
          ],
        )));
  }
}

class AutoMatchScout extends StatefulWidget {
  //constructor
  AutoMatchScout({Key key, this.allData}) : super(key: key);

  //map is a hashtable
  Map allData = {};
  //createState puts the page in the tree (it creates that page for the user to see)
  AutoMatchScoutState createState() => AutoMatchScoutState();
}

class TeleOpMatchScout extends StatefulWidget {
  TeleOpMatchScout({Key key, this.allData}) : super(key: key);

  Map allData;

  TeleOpMatchScoutState createState() => TeleOpMatchScoutState();
}

class DriverRatePage extends StatefulWidget {
  DriverRatePage({Key key, this.allData}) : super(key: key);
  Map allData;
  DriverRatePageState createState() => DriverRatePageState();
}

class SchedulePage extends StatefulWidget {
  SchedulePageState createState() => SchedulePageState();
}

class IndividualMatchPage extends StatefulWidget {
  IndividualMatchPage({Key key, this.title, this.teamsAndScouters})
      : super(key: key);

  final String title;
  final List teamsAndScouters;

  @override
  IndividualMatchState createState() => IndividualMatchState();
}

class PitScoutingPage extends StatefulWidget {
  final String title = "Pit scout selection";

  @override
  PitScoutingState createState() => PitScoutingState();
}

class PitScoutingTeamPage extends StatefulWidget {
  PitScoutingTeamPage(
      {Key key, this.teamName, this.teamNumber, this.hasProgrammingPitScout})
      : super(key: key);

  final String teamName;
  final String teamNumber;
  final bool hasProgrammingPitScout;

  Map allData = {};

  @override
  PitScoutingTeamState createState() => PitScoutingTeamState();
}
