import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

Future<bool> getDocumentExistence(
    DocumentSnapshot document, String path) async {
  document.reference.collection("pitScouts").document(path).get().then((doc) {
    return doc.exists;
  });
}

class PitScoutingState extends State<PitScoutingPage> {
  TextEditingController editingController = new TextEditingController();

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
      body: Column(
        children: <Widget>[
          TextField(
            controller: editingController,
            decoration: InputDecoration(hintText: "Team Number"),
          ),
          ElevatedButton(
            child: Text("Submit"),
            onPressed: () async {
              //document refrence is the path
              DocumentReference documentReference = Firestore.instance
                  .collection("teams")
                  .document(editingController.text);
              //document snapshot is the document with its data
              DocumentSnapshot document = await documentReference.get();
              var teamName = document['teamName'];
              var teamNumber = document["teamNumber"];
              var hasProgramingPitScout = document["hasProgrammingPitScout"];
              print(document['teamName']);
              goToPitScoutingTeamScreen(
                  context, teamName, teamNumber, hasProgramingPitScout);
            },
          )
        ],
      ),
    );
  }
}
