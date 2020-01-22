import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';




Future<File> _getNameFile() async {
      // get the path to the document directory.

      String dir = (await getApplicationDocumentsDirectory()).path;
      print(dir);
      File currentFile = File('$dir/Name.txt');
      print(currentFile);
      if (currentFile == null) {
        currentFile.create();
      }
      currentFile.create();
      return currentFile;
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


void Function() goToPitScoutingProgramingScreen(BuildContext context, String teamName, String teamNumber) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PitScoutingProgramming(teamName: teamName, teamNumber: teamNumber)),
  );
}

void Function() goToPitScoutingConstructionScreen(BuildContext context, String teamName, String teamNumber) {
  //go to page for putting back items
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PitScoutingConstruction(teamName: teamName, teamNumber: teamNumber)),
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
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunction(flutterLocalNotificationsPlugin);
    prepareNextMatchNotification(flutterLocalNotificationsPlugin,platformChannelSpecifics);
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
            InkWell(child: Text("Pit scout", textScaleFactor: 3),
              onTap: (){
                goToPitScoutingScreen(context);
              },
            ),
            InkWell(child: Text("Schedule", textScaleFactor: 3),
              onTap: (){
                goToPitScheduleScreen(context);
              },
            ),
            InkWell(child: Text("Settings"),
            onTap: (){ goToSettingsScreen(context);},),
            InkWell(
              child: Text("Send Notification"),
              onTap: () async{
                print(flutterLocalNotificationsPlugin.toString());
                await flutterLocalNotificationsPlugin.show(
    1, 'plain title', 'plain body', platformChannelSpecifics,
    payload: 'item x');
           // doNotify(flutterLocalNotif5icationsPlugin, platformChannelSpecifics);
            DateTime timeToShow = DateTime.now().add(new Duration(seconds: 10));
            print(timeToShow);
              await flutterLocalNotificationsPlugin.schedule(
          5,
          'scheduled title',
          'scheduled body',
          timeToShow,
        
         //DateTime.fromMillisecondsSinceEpoch((match["matchPredictedTime"]*1000)).toLocal(),
          platformChannelSpecifics,
          androidAllowWhileIdle:true,
          
          );
          print("scheduled");
            },
            ),
            InkWell(child: Text("Match Scout"),
            onTap: (){ goToAutoMatchScout(context,{"teamNum":-10});},
            )
            
          
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


class AutoMatchScoutState extends State<AutoMatchScout>{
/*

  mcq1 = ["Hang","Yes","No"]
  mcq2 = ["Balanced", "Yes", "No"]
  mcQuestions = [q1, q2]

  incDecq1 = ["Power Cells Scored", 0]
  incDecq2 = ["Number of fouls", 0]
  incDecFeilds = [incDecq1, incDecq2]

  createPage(mcQuestions, incDecFields) -> pageList

  */
  List<Widget> pageList = [];
 


  List<Widget> createThePage(List<String> qualities){
   Widget teamFinder = InkWell(child: Text("Load Page",),
            onTap: ()async{
             List<int> timeAndMatch = await getTeamClosestTimeTeam();
           
             widget.allData.addAll({
               "teamNum":timeAndMatch[0],
               "matchNum":timeAndMatch[1]
             });
            
             print(widget.teamNum);
             setState(() {
               
             });
            },);
    List<Widget> thePageValue = [teamFinder];
    for(int i = 0; i<qualities.length;i++){
      thePageValue.add(Text(qualities[i]));
      widget.allData.putIfAbsent(qualities[i], ()=>
       0
      );

      thePageValue.add(Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               print(widget.allData);
               
               print(widget.allData[qualities[i]]);
               setState(() {
                 widget.allData.update(qualities[i], (dynamic value)=>value+1);
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
             
               print(widget.allData[qualities[i]]);
               setState(() {
                  widget.allData.update(qualities[i], (dynamic value)=>value-1);
               });
             },
           ),
           
           Text(widget.allData[qualities[i]].toString()),
           ]));
    }
    
    return thePageValue;
  }
  
  
  /*int teamNum=-100;

  
  int lowGoalPowerCells = 0;
  int highGoalPowerCells = 0;
  int backHolePowerCells = 0;
  bool moved = true;
  
  */
  Future<List<int>> getTeamClosestTimeTeam() async{


  File file = await _getNameFile();
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
        List<int> toReturn = [int.parse(team.documentID.substring(3)),int.parse(match.documentID)];
        return toReturn;
} 
    }
   }
   return [-15,-215];
}


/*

@override
void initState() {
    // TODO: implement initState
    super.initState();
  getTeamClosestTimeTeam();
  print(teamNum);
  }
*/

 @override
  void initState() {
    super.initState();
  
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
        title: Text("Match Scout AUTO PERIOD"),
        actions: <Widget>[InkWell(child: Text("Load Page"),onTap: (){pageList.addAll(createThePage(["thing1","otherTHing23432","last thing"]));
        setState(() {
          
        });}),]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: pageList,
         /* children: <Widget>[
            InkWell(child: Text("Load Page",),
            onTap: ()async{
             List<int> timeAndMatch = await getTeamClosestTimeTeam();
             widget.teamNum = timeAndMatch[0];
             widget.matchNum = timeAndMatch[1];
             print(widget.teamNum);

             setState(() {
               
             });
            },),
          if(widget.allData["teamNum"]>0)
         Column(children: <Widget>[ Text("Scouting team #"+widget.teamNum.toString()),
         Text("Low goal: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.autoLowGoal++;
               print(widget.autoLowGoal);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.autoLowGoal--;
               print(widget.autoLowGoal);
               setState(() {
                 
               });
             },
           ),
           
           Text(widget.autoLowGoal.toString()),
           ]),

           Text("High goal: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.autoHighGoal++;
               print(widget.autoHighGoal);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.autoHighGoal--;
               print(widget.autoHighGoal);
               setState(() {
                 
               });
             },
           ),
           Text(widget.autoHighGoal.toString())
       
         
           


          
         ]),
             Text("Back hole: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.autoBackHole++;
               print(widget.autoBackHole);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.autoBackHole--;
               print(widget.autoBackHole);
               setState(() {
                 
               });
             },
           ),
           Text(widget.autoBackHole.toString())
         ]),
          Text("Moved"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: (){
               widget.moved = true;
               print(widget.moved);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
               widget.moved=false;
               print(widget.moved);
               setState(() {
                 
               });
             },
           ),
           Text(widget.moved.toString())
         ]),

         InkWell(child: Text("Go To TeleOp Scout",textScaleFactor: 3,),
         onTap: (){
          // goToTeleOpMatchScout(context,widget.teleOpLowGoal,widget.teleOpHighGoal, widget.teleOpBackHole,widget.autoLowGoal,widget.autoHighGoal,widget.autoBackHole,widget.rotationControl,widget.positionControl,widget.moved,widget.hang,widget.hangBalenced,widget.teamNum,widget.matchNum);
          goToTeleOpMatchScout(context, widget.allData);
         },),InkWell(child: Text("Back to Main Menu"),
         onTap: (){goToMainMenu(context);},)
          
          ])*/)
          ));

        
}
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


class TeleOpMatchScoutState extends State<TeleOpMatchScout>{


  int teamNum = -2;

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
        leading: new Container(),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Match Scout TELEOP PERIOD")
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            InkWell(child: Text("Load Page",),
            onTap: ()async{
              teamNum=widget.teamNum;
             print(teamNum);
             setState(() {
               
             });
            },),
          if(teamNum>0)
         Column(children: <Widget>[ Text("Scouting team #"+teamNum.toString()),
         Text("Low goal: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.teleOpLowGoal++;
               print(widget.teleOpLowGoal);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.teleOpLowGoal--;
               print(widget.teleOpLowGoal);
               setState(() {
                 
               });
             },
           ),
           
           Text(widget.teleOpLowGoal.toString()),
           ]),

           Text("High goal: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.teleOpHighGoal++;
               print(widget.teleOpHighGoal);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.teleOpHighGoal--;
               print(widget.teleOpHighGoal);
               setState(() {
                 
               });
             },
           ),
           Text(widget.teleOpHighGoal.toString())
       
         
           


          
         ]),
             Text("Back hole: Scored power cells"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               widget.teleOpBackHole++;
               print(widget.teleOpBackHole);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
               widget.teleOpBackHole--;
               print(widget.teleOpBackHole);
               setState(() {
                 
               });
             },
           ),
           Text(widget.teleOpBackHole.toString())
         ]),
         Text("Rotation Control"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: (){
               widget.rotationControl = true;
               print(widget.rotationControl);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
               widget.rotationControl=false;
               print(widget.rotationControl);
               setState(() {
                 
               });
             },
           ),
           Text(widget.rotationControl.toString())
         ]),
         Text("Position Control"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: (){
               widget.positionControl = true;
               print(widget.positionControl);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
               widget.positionControl=false;
               print(widget.positionControl);
               setState(() {
                 
               });
             },
           ),
           Text(widget.positionControl.toString())
         ]),
         // Method: does all of this. Takes: name, options
         // options should be a list of strings

         // ex: method("Hand",["Yes"; "No"])
         Text("Hang"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: (){
               widget.hang = true;
               print(widget.hang);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
               widget.hang = false;
               print(widget.hang);
               setState(() {
                 
               });
             },
           ),
           Text(widget.hang.toString())
         ]),
         Text("Position Control"),
         Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: (){
               widget.positionControl = true;
               print(widget.positionControl);
               setState(() {
                 
               });
             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
               widget.positionControl=false;
               print(widget.positionControl);
               setState(() {
                 
               });
             },
           ),
           Text(widget.positionControl.toString())
         ]),
        InkWell(child: Text("Back",textScaleFactor: 3,),
        onTap: (){goToAutoMatchScout(context, widget.allData);
        InkWell(child: Text("Submit"),
        onTap: (){
          Firestore.instance.collection("teams").document(widget.teamNum.toString()).collection("matchScouts").document(widget.matchNum.toString()).setData({
            "teamNum":widget.teamNum,
            "matchNum":widget.matchNum,
            "autoLowGoal":widget.autoLowGoal,
            "autoHighGoal":widget.autoHighGoal,
            "autoBackHole":widget.autoBackHole,
            "moved":widget.moved,
            "teleOpLowGoal":widget.teleOpLowGoal,
            "teleOpHighGoal":widget.teleOpHighGoal,
            "teleOpBackHole":widget.teleOpBackHole,
            "rotationControl":widget.rotationControl,
            "postionControl":widget.positionControl,
            "hang":widget.hang,
            "hangBalenced":widget.hangBalenced
            


          }           
          );
        },);
        })])])));
        
}

}

class SettingsPage extends StatefulWidget{

SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsPage>{
  TextEditingController username = new TextEditingController();

  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar( 
          
        title: Text("Settings"),
      ),
      body: Center(child: 
      Column(children: <Widget>[
        TextField(controller: username, decoration: InputDecoration(hintText: "Name"),),
        InkWell(child: Text("Sumbit"),
        onTap: ()async{
          File theFile = await _getNameFile();
          theFile.writeAsString(username.text);
        },)

      ]
      ,)
      ,),
    );
  }
}

class SchedulePage extends StatefulWidget {

  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>{
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
        title: Text("Schedule")
      ),
      body: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('matches').orderBy("matchNum").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new Column(
                  children: <Widget>[
                  new InkWell(
                   child: new Text("match #" + document.documentID+"\t           "+DateTime.fromMillisecondsSinceEpoch(document["matchPredictedTime"]*1000).toLocal().toString().substring(DateTime.fromMillisecondsSinceEpoch(document["matchPredictedTime"]*1000).toLocal().toString().length-13,DateTime.fromMillisecondsSinceEpoch(document["matchPredictedTime"]*1000).toLocal().toString().length-7)),
                   onTap: () async{
                    /*var allmatch = Firestore.instance.collection('matches');
                      for(int i = 1; i<3; i++){
                     var newSnap = allmatch.document(i.toString()).collection("teams").snapshots();
                      print(newSnap.toString());
                      }
                    */
                    List dataToSend = [];
                    await document.reference.collection("teams").getDocuments().then((thing){
                      
                      for(DocumentSnapshot doc in thing.documents){
                        print(doc.documentID);
                        dataToSend.add(doc.documentID);
                        dataToSend.add(doc["scouter"]);
                      }
                      dataToSend.add(document.documentID);
                    });
                    print(dataToSend.toString());
                      goToPitIndividualMatchScreen(context, dataToSend);
                    //goToPitScoutingTeamScreen(context, teamName, teamNumber, hasProgramingPitScout);
                    },
                  )
                  
                  ] 
                );
              }).toList(),
            );
        }
      },
    )
    );
}
}

class IndividualMatchPage extends StatefulWidget{
  IndividualMatchPage({Key key, this.title, this.teamsAndScouters}) : super(key: key);

  final String title;
  final List teamsAndScouters;

  @override
  IndividualMatchState createState() => IndividualMatchState();
}


class IndividualMatchState extends State<IndividualMatchPage>{
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
        title: Text(widget.teamsAndScouters[12]),
      ),
      body: Center(child: 
      Column(children: <Widget>[
        
        Text('Team 1 (Red) : '+widget.teamsAndScouters[0]+", "+widget.teamsAndScouters[1], textScaleFactor: 1.5,),
        Text('Team 2 (Blue) : '+widget.teamsAndScouters[2]+", "+widget.teamsAndScouters[3], textScaleFactor: 1.5,),
        Text('Team 3 (Blue) : '+widget.teamsAndScouters[4]+", "+widget.teamsAndScouters[5], textScaleFactor: 1.5,),
        Text('Team 4 (Red) : '+widget.teamsAndScouters[6]+", "+widget.teamsAndScouters[7], textScaleFactor: 1.5,),
        Text('Team 5 (Red) : '+widget.teamsAndScouters[8]+", "+widget.teamsAndScouters[9], textScaleFactor: 1.5,),
        Text('Team 6 (Blue) : '+widget.teamsAndScouters[10]+", "+widget.teamsAndScouters[11], textScaleFactor: 1.5,)
      ],
      ),
      ),

    );
}
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




class PitScoutingState extends State<PitScoutingPage> {


  void printConferm(){
    print("Hi, it worked!!");
  }

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
      body: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('teams').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new Column(
                  children: <Widget>[
                  new InkWell(
                   child: new Text(document['teamNumber']),
                   onTap: (){
                    var teamName = document['teamName'];
                    var teamNumber = document["teamNumber"];
                    var hasProgramingPitScout = document["hasProgrammingPitScout"];

                    print(document['teamName']);
                    goToPitScoutingTeamScreen(context, teamName, teamNumber, hasProgramingPitScout);
                    },
                  )
                  
                  ] 
                );
              }).toList(),
            );
        }
      },
    )
    );
  }
}

class PitScoutingTeamPage extends StatefulWidget{
  PitScoutingTeamPage({Key key, this.teamName, this.teamNumber, this.hasProgrammingPitScout}) : super(key: key); 

  final String  teamName;
  final String  teamNumber;
  final bool    hasProgrammingPitScout;

  @override
  PitScoutingTeamState createState() => PitScoutingTeamState();
  
} 

class PitScoutingTeamState extends State<PitScoutingTeamPage> with TickerProviderStateMixin{

  
  bool programmingScoutVisible = false;
  bool constructionScoutVisible = false;

  TextEditingController userName = new TextEditingController();
  
  //String scoringAbility;
  bool canScoreLowGoal = false;
  bool canScoreHighGoal = false;
  bool canAutoScoreLowGoal = false;
  bool canAutoScoreHighGoal = false;
  bool canAutoScoreBackHole = false;

  bool canRotationControl = false;
  bool canPositionControl = false;

  bool canHang = false;
  bool canMoveHang = false;

  bool theRobotIsCool=false;
  List<Widget> thePage=[];
  
  var pageType = "I";

  //TickerProviderStateMixin tickerProviderStateMixin;

  
  //TabController tabController = new TabController(vsync:  tickerProvider, length: 2);
  
  
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3, );
    _tabController.addListener(_handleTabSelection);
  }
  _handleTabSelection() {
                  setState(() {
                   // _currentIndex = _controller.index;
                  if(_tabController.index==0){
                    pageType="I";
                  }

                   if(_tabController.index==1){
                      pageType = "C";
                   }
                   if(_tabController.index==2){
                      pageType = "P";
                   }

                  });
              }
  @override
  Widget build(BuildContext context) {
 
   
    

    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.

      

        title: Text(widget.teamName),

        bottom: TabBar(
          tabs: <Widget>[
            Text("Information"),
               InkWell(
            child: Text("C",textAlign: TextAlign.left,),
            onTap: (){
              setState(() {
                  pageType = "C";
                  print("C");
              });
              
            }),

          /*  Padding(
              padding: EdgeInsets.all(15),
            ),
            */
             InkWell(
            child: Text("P",textAlign: TextAlign.left,),
            onTap: (){
              setState(() {
                  pageType = "P";
                  print("P");
              });
            }),
            
          ],
        controller: _tabController
        ),
      ),
              
            
          
      
      
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          
         mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(pageType=="C")
            Visibility(
              child: Center(
                  
                child:
                ListView(
                shrinkWrap: true,

                children: <Widget>[

              TextField(controller: userName, decoration: InputDecoration(hintText: "User Name")),
              Row(children: <Widget>[
                Text("Low goal"),
                Switch.adaptive(value: canScoreLowGoal, onChanged: (bool newValue){
                              setState(() {
                                canScoreLowGoal=newValue;
                              });
                          }),
              /*  Radio(groupValue: scoringAbility,value: "Low goal only", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   scoringAbility="Low goal only";
                 });
                  
                }),*/

                Text("Autonomously?"),
                Switch.adaptive(value: canAutoScoreLowGoal, onChanged: (bool newValue){
                              setState(() {
                                canAutoScoreLowGoal=newValue;
                              });
                          }),
              ]),

              Row(children: <Widget>[
               
                Text("High goal"),
                Switch.adaptive(value: canScoreHighGoal, onChanged: (bool newValue){
                              setState(() {
                                canScoreHighGoal=newValue;
                              });
                          }),
                Text("Autonomously?"),
                Switch.adaptive(value: canAutoScoreHighGoal, onChanged: (bool newValue){
                          setState(() {
                            canAutoScoreHighGoal=newValue;
                          });
                      }),
              ]), 
              Row(children: <Widget>[  
              Text("Score back hole autonomously"),
              Switch.adaptive(value: canAutoScoreBackHole, onChanged: (bool newValue){
                        setState(() {
                          canAutoScoreBackHole=newValue;
                        });
                    }),
            ]),     
            Text("Color wheel:"),
            Row(children: <Widget>[
              Text("Rotation"),
              Switch.adaptive(value: canRotationControl, onChanged: (bool newValue){
                            setState(() {
                              canRotationControl=newValue;
                            });
                        }),
            /*  Radio(groupValue: scoringAbility,value: "Low goal only", onChanged: (String placeHolderTwo){
              //print("hi");
              setState(() {
                scoringAbility="Low goal only";
              });
                
              }),*/

              Text("Position"),
              Switch.adaptive(value: canPositionControl, onChanged: (bool newValue){
                            setState(() {
                              canPositionControl=newValue;
                            });
                        }),
            ]),
            Row(
              children: <Widget>[
                Text("Hang"),
                Switch.adaptive(value: canHang, onChanged: (bool newValue){
                            setState(() {
                              canHang=newValue;
                            });
                        }),
              
              Text("Can move while hanging"),
                Switch.adaptive(value: canMoveHang, onChanged: (bool newValue){
                            setState(() {
                              canMoveHang=newValue;
                            });
                        }),
              ],
            ),        
                /*Radio(groupValue: scoringAbility,value: "High and low goals", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   print("hi?");
                   scoringAbility="High and low goals";
                 });
                  
                }                


                
            ),*/
          
            /*Switch.adaptive(value: theRobotIsCool, onChanged: (bool newValue){
              setState(() {
                theRobotIsCool=newValue;
              });
           }), */
            InkWell(
              child: Text("Submit pit scout"),
              onTap: () async {
                rootInstance.document(widget.teamNumber).collection("pitScouts").document("Contruction").setData({
                  //"energyScoringAbility":scoringAbility,
                  "UserName":userName.text,

                  "scoreLowGoal":canScoreLowGoal,
                  "scoreLowGoalAutonomously":canAutoScoreLowGoal,
                  "scoreHighGoal":canScoreHighGoal,
                  "scoreHighGoalAutonomously":canAutoScoreHighGoal,
                  "scoreBackHoleAutonomously":canAutoScoreBackHole,

                  "canRotationControl":canRotationControl,
                  "canPositionControl":canPositionControl,
              
                  "canHang":canHang,
                  "canMoveWhileHanging":canMoveHang
                  });
              }),
              ]
            ),
            )),
            
            if(pageType=="P")
            Visibility(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                TextField(controller: userName, decoration: InputDecoration(hintText: "User Name")),
            Text("Is the robot cool?"),
            Switch.adaptive(value: theRobotIsCool, onChanged: (bool newValue){
              setState(() {
                theRobotIsCool=newValue;
              });
            }),
            InkWell(
              child: Text("Submit pit scout"),
              onTap: () async {
                rootInstance.document(widget.teamNumber).collection("pitScouts").document("Programming").setData({
                  "isRobotCool":theRobotIsCool,
                  "UserName":userName.text
                  });
              }
            )
                ]
            ))
          ],
          
        )
            


              
            
            /*  Text("Programming Pit Scout"),
              if(widget.hasProgrammingPitScout) Icon(Icons.check)
              
              else   InkWell(child: Icon(Icons.note_add),
                onTap: (){
                  goToPitScoutingProgramingScreen(context, widget.teamName, widget.teamNumber);
                },
              ),

              Text("Construction Pit Scout"),
              if(widget.hasProgrammingPitScout) Icon(Icons.check)
              
              else   InkWell(child: Icon(Icons.note_add),
                onTap: (){
                  goToPitScoutingConstructionScreen(context, widget.teamName, widget.teamNumber);
                },
              )
            */  
          
      )   
      );
    
  }
  
}



class PitScoutingProgramming extends StatefulWidget
{
   PitScoutingProgramming({Key key, this.teamName, this.teamNumber}) : super(key: key); 

   final String  teamName;
   final String  teamNumber;

  @override
  PitScoutingProgrammingState createState() => PitScoutingProgrammingState();
}

class PitScoutingProgrammingState extends State<PitScoutingProgramming>{

  bool theRobotIsCool=false;
  TextEditingController userName = new TextEditingController();
  

  @override
  Widget build(BuildContext context) {
 
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.teamName),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(controller: userName, decoration: InputDecoration(hintText: "User Name")),
            Text("Is the robot cool?"),
            Switch.adaptive(value: theRobotIsCool, onChanged: (bool newValue){
              setState(() {
                theRobotIsCool=newValue;
              });
            }),
            InkWell(
              child: Text("Submit pit scout"),
              onTap: () async {
                rootInstance.document(widget.teamNumber).collection("pitScouts").document("Programming").setData({
                  "isRobotCool":theRobotIsCool,
                  "UserName":userName.text
                  });
              }
            )
          ]
        )
      )
    );
  }
}


class PitScoutingConstruction extends StatefulWidget
{
   PitScoutingConstruction({Key key, this.teamName, this.teamNumber}) : super(key: key); 

   final String  teamName;
   final String  teamNumber;

  @override
  PitScoutingConstructionState createState() => PitScoutingConstructionState();
}


class PitScoutingConstructionState extends State<PitScoutingConstruction>{

  bool theRobotIsCool=false;
  TextEditingController userName = new TextEditingController();
  
  String scoringAbility;
  

  @override
  Widget build(BuildContext context) {
 
   
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.teamName),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(controller: userName, decoration: InputDecoration(hintText: "User Name")),
            Text("Where can the robot score?"),
            Row(
              
              children: <Widget>[

                /*DropdownButton<String>(
                  items: <DropdownMenuItem<String>>["can not score","hi"].map<DropdownMenuItem<String>>
                  ),
*/
                /*Text("Can not score"),
                Radio(groupValue: scoringAbility,value: "Can not score", onChanged: (String placeHolder){
                  setState(() {
                    scoringAbility="Can not score";
                  });
                  
                }),


                Text("Only low goal"),

                Radio(groupValue: scoringAbility,value: "Low goal only", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   
                   scoringAbility="Low goal only";
                 });
                  
                }),
                
                Text("High and low goals"),

                Radio(groupValue: scoringAbility,value: "High and low goals", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   
                   scoringAbility="High and low goals";
                 });
                  
                }),


                ],
            ),
            */
            /*Switch.adaptive(value: theRobotIsCool, onChanged: (bool newValue){
              setState(() {
                theRobotIsCool=newValue;
              });
           }), */
            InkWell(
              child: Text("Submit pit scout"),
              onTap: () async {
                rootInstance.document(widget.teamNumber).collection("pitScouts").document("Contruction").setData({
                  "energyScoringAbility":scoringAbility,
                  "UserName":userName.text
                  });
              }
            )
          ]
        )
          ]
      )
      )
    );
  }
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