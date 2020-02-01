
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
    
class TeleOpMatchScoutState extends State<TeleOpMatchScout>{
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

  int teamNum = -2;

  List<Widget> pageList = [];

  List<String> qualitiesInt = ["low goal scored", "high goal scored", "back hole scored"];
  List<String> qualitiesYesNo = ["Rotation Control","Position Control","Hang","Hang balenced"];

  Future<List<Widget>> createThePage(List<String> qualitiesInt, List<String> qualitiesYesNo)async{
  
    List<int> teamNameAndNum = await getTeamClosestTimeTeam();
    List<Widget> thePageValue = [];
    widget.allData["teamNum"] = teamNameAndNum[0];
    widget.allData["matchNum"]=teamNameAndNum[1];
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
             
           
                  widget.allData.update(qualitiesInt[i], (dynamic value)=>value-1);
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });
            
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
             
            
               //setState(() {
                 //print("called");
                // randomTestPart=-1;
                  widget.allData.update(qualitiesYesNo[i], (dynamic value)=>"No");
                  
                  pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
                  print(pageList);
                  pageList.removeRange(0, qualitiesInt.length*2+4+qualitiesYesNo.length*2);
                  print(pageList);
                  setState(() {
                    
                  });
              // });
             },
           ),
           
           Text(widget.allData[qualitiesYesNo[i]].toString()),
           ]));
    }
      thePageValue.add(
        InkWell(child: Text("go to auto",textScaleFactor: 2,),
         onTap: (){
          goToAutoMatchScout(context, widget.allData);
         },),
      );
      thePageValue.add(InkWell(child: Text("go to Drivier Rating",textScaleFactor: 2,),
         onTap: (){
          goToDriverRatingMatchScout(context, widget.allData);
         },),);
    
    return thePageValue;
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
        leading: new Container(),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Match Scout TELEOP PERIOD"),
        actions: <Widget>[
          RaisedButton(onPressed: ()async{pageList.addAll(await createThePage(qualitiesInt,qualitiesYesNo));
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
          children: pageList
          /*  InkWell(child: Text("Load Page",),
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
        })])
        */)));
        
}

}
