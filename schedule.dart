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
