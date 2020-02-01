import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

Future<File> _getNameFile() async {
      // get the path to the document directory.

      String dir = (await getApplicationDocumentsDirectory()).path;
      print(dir);
      File currentFile = File('$dir/Name.txt');
      print(currentFile);
      
      File newFile = await currentFile.create();
      return newFile;
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
  
  int randomTestPart = 0;
  List<String> intQuestions =["Starting power cells","Low goal scored (A)","High goal scored (A)","Back hole scored (A)"];
  List<String> yesNoQuestions = ["Moved"];

  bool shownTeleOpButton = false;
 Future<List<Widget>> createThePage(List<String> qualitiesInt, List<String> qualitiesYesNo)async{
  
    List<int> teamNameAndNum = await getTeamClosestTimeTeam();
    List<Widget> thePageValue = [];
    thePageValue.add(Text(teamNameAndNum[0].toString()));
    thePageValue.add(Text("Match Num"+teamNameAndNum[1].toString()));
    for(int i = 0; i<qualitiesInt.length;i++){
      thePageValue.add(Text(qualitiesInt[i]));
      widget.allData.putIfAbsent(qualitiesInt[i], ()=>
       0
      );

      thePageValue.add(Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: ()async{
               print(widget.allData);
               
               print(widget.allData[qualitiesInt[i]]);
               widget.allData.update(qualitiesInt[i], (dynamic value)=>value+1);
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });

             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: ()async{
             
            
               //setState(() {
                 //print("called");
                // randomTestPart=-1;
                  widget.allData.update(qualitiesInt[i], (dynamic value)=>value-1);
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });
              // });
             },
           ),
           
           Text(widget.allData[qualitiesInt[i]].toString()),
           ]));
    }

     for(int i = 0; i<qualitiesYesNo.length;i++){
      thePageValue.add(Text(qualitiesYesNo[i]));
      widget.allData.putIfAbsent(qualitiesYesNo[i], ()=>
       "No"
      );

      thePageValue.add(Row(children: <Widget>[
           FlatButton(
             child: Text("Yes"),
             onPressed: ()async{
               
               widget.allData.update(qualitiesYesNo[i], (dynamic value)=>"Yes");
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });

             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: ()async{
             
            
                  widget.allData.update(qualitiesYesNo[i], (dynamic value)=>"No");
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });

             },
           ),
           
           Text(widget.allData[qualitiesYesNo[i]].toString()),
           ]));
    }
          thePageValue.add(
        InkWell(child: Text("Go To TeleOp Scout",textScaleFactor: 3,),
         onTap: (){
          goToTeleOpMatchScout(context, widget.allData);
         },),
      );
      thePageValue.add(
        InkWell(child: Text("Go To Main Menu",textScaleFactor: 3,),
         onTap: (){
          goToMainMenu(context);
         },),
      );
      
      
    
    return thePageValue;
  }
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
        actions: <Widget>[
          RaisedButton(onPressed: ()async{pageList.addAll(await createThePage(intQuestions,yesNoQuestions));
        setState(() {
          
        });

          },color: Color(0xFFd82934),
          child: Text("Load Page"),)
        ]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: pageList,
        )
          ));

        
}
}
