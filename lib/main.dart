import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


import 'autoMatchScout.dart';
import 'teleOpMatchScout.dart';
import 'driverRatingMatchScout.dart';
import 'pitScout.dart';
import 'settings.dart';
import 'schedule.dart';
import 'matchPageSchedule.dart';
import 'selectionPitScout.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
Future<File> _getNameFile() async {
      // get the path to the document directory.

      String dir = (await getApplicationDocumentsDirectory()).path;
      print(dir);
      File currentFile = File('$dir/Name.txt');
      print(currentFile);
      
      File newFile = await currentFile.create();
      return newFile;
    }


var rootInstance = Firestore.instance.collection('teams');


List sortByID(List toSort){
  toSort.sort((a,b) => a.documentID.compareTo(b.documentID));
  return toSort;
   }
   
//enum energyBallAbilities {canNotScore, lowGoalOwnly,highAndLowGoal, highGoalOnly, throughBackGoal, throughBackGoalAndLow}

void Function() goToMainMenu(BuildContext context) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MainPage()),
  );
}

void Function() goToPitScoutingTeamScreen(BuildContext context, String teamName, String teamNumber, bool hasProgrammingPitScout) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PitScoutingTeamPage(teamName: teamName, teamNumber: teamNumber, hasProgrammingPitScout: hasProgrammingPitScout,)),
  );
}




void Function() goToPitScoutingScreen(BuildContext context) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PitScoutingPage()),
  );
}

void Function() goToPitScheduleScreen(BuildContext context) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SchedulePage()),
  );
}

void Function() goToPitIndividualMatchScreen(BuildContext context, List dataToSend) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => IndividualMatchPage(teamsAndScouters: dataToSend)),
  );
}

void Function() goToSettingsScreen(BuildContext context) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SettingsPage()),
  );
}
/*
void Function() goToAutoMatchScout(BuildContext context, int teleOpLowGoal, int teleOpHighGoal, int teleOpBackHole, int autoLowGoal, int autoHighGoal, int autoBackHole, bool rotationControl, bool positionControl, bool moved, bool hang,bool hangBalenced,int teamNum,int matchNum) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AutoMatchScout(teleOpLowGoal: teleOpLowGoal,teleOpHighGoal: teleOpHighGoal,teleOpBackHole: teleOpBackHole,autoLowGoal: autoLowGoal,autoHighGoal: autoHighGoal,autoBackHole: autoBackHole,rotationControl: rotationControl,positionControl: positionControl, moved: moved, hang: hang,hangBalenced:hangBalenced, teamNum:teamNum,matchNum:matchNum,)),
  );
}


void Function() goToTeleOpMatchScout(BuildContext context, int teleOpLowGoal, int teleOpHighGoal, int teleOpBackHole, int autoLowGoal, int autoHighGoal, int autoBackHole, bool rotationControl, bool positionControl, bool moved,bool hang,bool hangBalenced, int teamNum, int matchNum) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TeleOpMatchScout(teleOpLowGoal: teleOpLowGoal,teleOpHighGoal: teleOpHighGoal,teleOpBackHole: teleOpBackHole,autoLowGoal: autoLowGoal,autoHighGoal: autoHighGoal,autoBackHole: autoBackHole,rotationControl: rotationControl,positionControl: positionControl, moved: moved, hang: hang,hangBalenced:hangBalenced, teamNum: teamNum,matchNum: matchNum,)),
  );
}

*/

void Function() goToAutoMatchScout(BuildContext context, Map inputMap){
  Navigator.push(context, MaterialPageRoute(builder: (context)=> AutoMatchScout(allData: inputMap,)));
}


void Function() goToTeleOpMatchScout(BuildContext context, Map inputMap){
  Navigator.push(context, MaterialPageRoute(builder: (context)=> TeleOpMatchScout(allData: inputMap,)));
}

void Function() goToDriverRatingMatchScout(BuildContext context, Map inputMap){
  Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverRatePage(allData: inputMap,)));
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

void initFunction(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin){
  print("Hi");
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('notify');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void prepareNextMatchNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, NotificationDetails notificationDetails)async{
  File file = await _getNameFile();
  if(file != null){
  String name = file.readAsStringSync();
  print(name);
  DateTime currentTime = new DateTime.now();
  var matchesPlace = await  Firestore.instance.collection("matches").orderBy("matchNum").getDocuments();
  for(DocumentSnapshot match in matchesPlace.documents){
    var teams = await match.reference.collection("teams").getDocuments();
    for(DocumentSnapshot team in teams.documents){
     // var matchTime = 
      
      //if(team["scouter"]==name && (match["matchPredictedTime"]*1000)>currentTime.millisecondsSinceEpoch){
      DateTime dataMatchTime = DateTime.fromMillisecondsSinceEpoch(match["matchPredictedTime"]*1000).toLocal();
        if(team["scouter"]==name && currentTime.isBefore(dataMatchTime)){
        print(DateTime.fromMillisecondsSinceEpoch(match["matchPredictedTime"]*1000).toLocal());
        print(DateTime.now());
        print(team.documentID);
        print(match.documentID);
        print("\n");
        await flutterLocalNotificationsPlugin.schedule(
          0,
          'scheduled title',
          'scheduled body',
          DateTime.now().add(new Duration(seconds: 40)),
         //DateTime.fromMillisecondsSinceEpoch((match["matchPredictedTime"]*1000)).toLocal(),
          notificationDetails);
            }
    }
  }
  print("done");
  }
}


void doNotify(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, NotificationDetails notificationDetails)async{
  DateTime timeToShow = DateTime.now().add(new Duration(seconds: 10));
            print(timeToShow);
              await flutterLocalNotificationsPlugin.schedule(
          5,
          'scheduled title',
          'scheduled body',
          timeToShow,
        
         //DateTime.fromMillisecondsSinceEpoch((match["matchPredictedTime"]*1000)).toLocal(),
          notificationDetails,
          androidAllowWhileIdle:true,
          
          );
          print("scheduled");
}

class MainPageState extends State<MainPage>{
  

  
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
   if (message.containsKey('data')) {
     // Handle data message
     final dynamic data = message['data'];
   }

   if (message.containsKey('notification')) {
     // Handle notification message
     final dynamic notification = message['notification'];
   }

   // Or do other work.
 }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunction(flutterLocalNotificationsPlugin);
    prepareNextMatchNotification(flutterLocalNotificationsPlugin,platformChannelSpecifics);
     _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            print("onMessage: $message");
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        content: ListTile(
                        title: Text(message['notification']['title']),
                        subtitle: Text(message['notification']['body']),
                        ),
                        actions: <Widget>[
                        FlatButton(
                            child: Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                ),
            );
        },
        onLaunch: (Map<String, dynamic> message) async {
            print("onLaunch: $message");
            // TODO optional
        },
        onResume: (Map<String, dynamic> message) async {
            print("onResume: $message");
            // TODO optional
        },
      );
    
  }

  
 
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
   static var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  static var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  
 
  //make construcor for class and put initFunction in it
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Main page")
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            
            Padding(padding:EdgeInsets.all(20),),
            RaisedButton(child: Text("Pit scout", textScaleFactor: 3),
            onPressed: (){
                goToPitScoutingScreen(context);
              },
              color: Color(0xFFFFC107),
            //disabledColor: ,
            ),

            Padding(padding:EdgeInsets.all(20),),
            RaisedButton(child: Text("Schedule", textScaleFactor: 3),
            onPressed: (){
                goToPitScheduleScreen(context);
              },
              color: Color(0xFFFFC107),
            //disabledColor: ,
            ),


            Padding(padding:EdgeInsets.all(20),),
            RaisedButton(child: Text("Settings", textScaleFactor: 3),
            onPressed: (){
                goToSettingsScreen(context);
              },
              color: Color(0xFFFFC107),
            //disabledColor: ,
            ),

            Padding(padding:EdgeInsets.all(20),),
            RaisedButton(child: Text("Match Scout", textScaleFactor: 3),
            onPressed: (){
                goToAutoMatchScout(context,{"teamNum":-10});
              },
              color: Color(0xFFFFC107),
            //disabledColor: ,
            ),


           
         
          
          ],
        )));

  }
}

class AutoMatchScout extends StatefulWidget{
  //AutoMatchScout({Key key, this.teleOpLowGoal, this.teleOpHighGoal,this.teleOpBackHole,this.autoLowGoal,this.autoHighGoal,this.autoBackHole,this.rotationControl,this.positionControl,this.moved,this.hang,this.hangBalenced,this.teamNum,this.matchNum}) : super(key: key);
  AutoMatchScout({Key key, this.allData}) : super(key: key);
  int teleOpLowGoal;
  int teleOpHighGoal;
  int teleOpBackHole;
  
  int autoLowGoal;
  int autoHighGoal;
  int autoBackHole;

  bool rotationControl;
  bool positionControl;
  bool moved;
  bool hang;
  bool hangBalenced;
  int teamNum;
  int matchNum;

  Map allData = {};
  AutoMatchScoutState createState() => AutoMatchScoutState();
}




class TeleOpMatchScout extends StatefulWidget{

  //TeleOpMatchScout({Key key, this.teleOpLowGoal, this.teleOpHighGoal,this.teleOpBackHole,this.autoLowGoal,this.autoHighGoal,this.autoBackHole,this.rotationControl,this.positionControl,this.moved,this.hang,this.hangBalenced,this.teamNum,this.matchNum}) : super(key: key);
  TeleOpMatchScout({Key key, this.allData}) : super(key: key);
  
  int teleOpLowGoal;
  int teleOpHighGoal;
  int teleOpBackHole;
  
  int autoLowGoal;
  int autoHighGoal;
  int autoBackHole;

  bool rotationControl;
  bool positionControl;
  bool moved;
  bool hang;
  bool hangBalenced;
  int teamNum;
  int matchNum;

  Map allData;

  TeleOpMatchScoutState createState()=>TeleOpMatchScoutState(); 
}



class DriverRatePage extends StatefulWidget{
  DriverRatePage({Key key, this.allData}) : super(key: key);
  Map allData;
  DriverRatePageState createState() => DriverRatePageState();
}

class SettingsPage extends StatefulWidget{

SettingsState createState() => SettingsState();
}

class SchedulePage extends StatefulWidget {

  SchedulePageState createState() => SchedulePageState();
}

class IndividualMatchPage extends StatefulWidget{
  IndividualMatchPage({Key key, this.title, this.teamsAndScouters}) : super(key: key);

  final String title;
  final List teamsAndScouters;

  @override
  IndividualMatchState createState() => IndividualMatchState();
}


class PitScoutingPage extends StatefulWidget {
  //PitScoutingPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "spot2";

  
  @override
  PitScoutingState createState() => PitScoutingState();
}



class PitScoutingTeamPage extends StatefulWidget{
  PitScoutingTeamPage({Key key, this.teamName, this.teamNumber, this.hasProgrammingPitScout}) : super(key: key); 

  final String  teamName;
  final String  teamNumber;
  final bool    hasProgrammingPitScout;

  Map allData = {};

  @override
  PitScoutingTeamState createState() => PitScoutingTeamState();
  
} 







          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
     /*     mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hi hello')
          ])));
  */



/*
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('books').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['title']),
                  subtitle: new Text(document['author']),
                );
              }).toList(),
            );
        }
      },
    )
    );
  }
}

*/