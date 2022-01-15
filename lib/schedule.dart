import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class SchedulePageState extends State<SchedulePage> {
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
            title: Text("Schedule")),
        //stream builder updates for each new item in the stream
        body: new StreamBuilder<QuerySnapshot>(
          //Firestore refrences the database when used with instance
          stream: FirebaseFirestore.instance
              .collection('matches')
              .orderBy("matchNum")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              //if the page is loading, show a loading message
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                //if not loading and there is not an error, create a scrollable list of Inkwells
                return new ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    return new Column(children: <Widget>[
                      //Time in the database is stored in seconds since epoch (1970) this must be multiplied by 1000 to get milleseconds. The substring takes out the hour and minute.
                      new InkWell(
                        child: new Text("match #" +
                            document.id +
                            "\t           " +
                            DateTime.fromMillisecondsSinceEpoch(
                                    document["matchPredictedTime"] * 1000)
                                .toLocal()
                                .toString()
                                .substring(
                                    DateTime.fromMillisecondsSinceEpoch(
                                                document["matchPredictedTime"] *
                                                    1000)
                                            .toLocal()
                                            .toString()
                                            .length -
                                        13,
                                    DateTime.fromMillisecondsSinceEpoch(
                                                document["matchPredictedTime"] *
                                                    1000)
                                            .toLocal()
                                            .toString()
                                            .length -
                                        7)),
                        onTap: () async {
                          List dataToSend = [];

                          //get the documents and with them do ...
                          await document.reference
                              .collection("teams")
                              .get()
                              .then((thing) {
                            for (DocumentSnapshot doc in thing.docs) {
                              print(doc.id);
                              dataToSend.add(doc.id);
                              dataToSend.add(doc["scouter"]);
                            }
                            dataToSend.add(document.id);
                          });
                          print(dataToSend.toString());
                          goToPitIndividualMatchScreen(context, dataToSend);
                        },
                      )
                    ]);
                    //turns the map into List<Widget>
                  }).toList(),
                );
            }
          },
        ));
  }
}
