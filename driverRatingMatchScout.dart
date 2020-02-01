
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



class DriverRatePageState extends State<DriverRatePage>{

  String speedScore = "notSelected";
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
        title: Text("Match Scout DRIVER RATING"),
           
               //  });})]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            Text("Speed"),
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value: "slow",
                  child: Text("Slow"),
                ),
                DropdownMenuItem(
                  value: "averageSpeed",
                  child: Text("Average speed"),
                ),
                DropdownMenuItem(
                  value: "fast",
                  child: Text("Fast"),
                ),
              ],
              onChanged: (value){
                setState(() {
                  widget.allData["speedScore"]=value;
                });
                print(widget.allData["speedScore"]);
              },
              value: widget.allData["speedScore"],
            ),
            Text("Defense"),
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value:"noDefense" ,
                  child: Text("No defense"),
                ),
                DropdownMenuItem(value: "blockedFewBalls",
                child: Text("Blocked a few balls"),),
                DropdownMenuItem(value: "blockedManyBalls",
                child: Text("Blocked many balls")),
                DropdownMenuItem(value: "onlyCanDoDefenseAndPoorly",
                child: Text("incompetent defense bot"),),
                DropdownMenuItem(value: "onlyCanDoDefenseAndWell",
                child: Text("Good defense bot"),),
                
                
              ],
               onChanged: (value){
                setState(() {
                  widget.allData["defenseScore"]=value;
                });
                print(widget.allData["defenseScore"]);
              },
              value: widget.allData["defenseScore"],
            ),
  InkWell(child: Text("Submit"),
      onTap: (){
        print("uploading");
        
        Firestore.instance.collection("teams").document(widget.allData["teamNum"].toString()).collection("matchScouts").document(widget.allData["matchNum"].toString()).setData({
          "allData":widget.allData,
      });
      print("done");
      },
      )
          ],
        )
      )
    );

  }
} 
