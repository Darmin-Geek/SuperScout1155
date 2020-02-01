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


Future<bool> getDocumentExistence(DocumentSnapshot document, String path) async{
  document.reference.collection("pitScouts").document(path).get().then((doc){
    return doc.exists;
  });
}


class PitScoutingState extends State<PitScoutingPage> {

  TextEditingController editingController = new TextEditingController();

/*
  List<Widget> pageList = [];
  TextEditingController searchController = new TextEditingController();

  Future<List<Widget>> buildPage(String searchTerm) async{
    List<Widget> pageValue = [];
   
    pageValue.add(TextField(controller: searchController, onChanged: (searchTerm) async{
      pageList = await buildPage(searchTerm);
      setState(() {
        
      });
    },));
    QuerySnapshot teamsSnap = await Firestore.instance.collection("teams").getDocuments();
    if(searchTerm==""){
      for(DocumentSnapshot document in teamsSnap.documents){
        pageValue.add(  new RaisedButton(
                  /* child: new Row(children: <Widget>[ Text(document['teamNumber']+"\tNeeds:"),
                   //if(getDocumentExistence(document)) Text("Construction")
                   ]),
                   */
                  child:Text(document["teamNumber"]),
                   onPressed: ()async{
                    
                    var teamName = document['teamName'];
                    var teamNumber = document["teamNumber"];
                    var hasProgramingPitScout = document["hasProgrammingPitScout"];

                    print(document['teamName']);
                    goToPitScoutingTeamScreen(context, teamName, teamNumber, hasProgramingPitScout);
                    },
                  )
                  
                );
      }
      
    }else{
    teamsSnap = await Firestore.instance.collection("teams").where("teamNumber",isEqualTo: searchTerm).getDocuments();
    for(DocumentSnapshot document in teamsSnap.documents){
        pageValue.add(  new RaisedButton(
                  /* child: new Row(children: <Widget>[ Text(document['teamNumber']+"\tNeeds:"),
                   //if(getDocumentExistence(document)) Text("Construction")
                   ]),
                   */
                  child:Text(document["teamNumber"]),
                   onPressed: ()async{
                   
                    var teamName = document['teamName'];
                    var teamNumber = document["teamNumber"];
                    var hasProgramingPitScout = document["hasProgrammingPitScout"];

                    print(document['teamName']);
                    goToPitScoutingTeamScreen(context, teamName, teamNumber, hasProgramingPitScout);
                    },
                  )
                  
                );
    }
    }
    //pageValue.add(ListView(children: prePageValue,));
    return pageValue;
  }

  void printConferm(){
    print("Hi, it worked!!");
  }
*/
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
      body: Column(children: <Widget>[
        TextField(controller: editingController, decoration: InputDecoration(hintText: "Team Number"),),
        RaisedButton(child: Text("Submit"),
        onPressed: ()async{
          DocumentReference documentReference = Firestore.instance.collection("teams").document(editingController.text);
          //Stream<DocumentSnapshot> documentStream = documentReference.snapshots();
          DocumentSnapshot document = await documentReference.get();
          var teamName = document['teamName'];
          var teamNumber = document["teamNumber"];
          var hasProgramingPitScout = document["hasProgrammingPitScout"];
          print(document['teamName']);
          goToPitScoutingTeamScreen(context, teamName, teamNumber, hasProgramingPitScout);
        },)
      ],),
      /*body: new StreamBuilder<QuerySnapshot>(
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
                  new RaisedButton(
                  /* child: new Row(children: <Widget>[ Text(document['teamNumber']+"\tNeeds:"),
                   //if(getDocumentExistence(document)) Text("Construction")
                   ]),
                   */
                  child:Text(document["teamNumber"]),
                   onPressed: ()async{
                    bool constructExists = await getDocumentExistence(document,"Construction");
                    bool programExists = await getDocumentExistence(document, "Programming");
                    showDialog(context: context,builder: (context){
                      AlertDialog(title: Text("Scouts needed (if blank, none are needed)"),
                      content:Column(children: <Widget>[
                        if(!constructExists) Text("Construction"),
                        if(!programExists) Text("Programming")
                      ]),);
                    });
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
    )*/
    );
  }
}
