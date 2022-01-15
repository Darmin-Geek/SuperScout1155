import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

class TeleOpMatchScoutState extends State<TeleOpMatchScout> {
  Future<List<int>> getTeamClosestTimeTeam() async {
    File file = await _getNameFile();
    String name = file.readAsStringSync();
    print(name);
    DateTime currentTime = new DateTime.now();
    var matchesPlace = await FirebaseFirestore.instance
        .collection("matches")
        .orderBy("matchNum")
        .get();
    for (DocumentSnapshot match in matchesPlace.docs) {
      var teams = await match.reference.collection("teams").get();
      for (DocumentSnapshot team in teams.docs) {
        // var matchTime =

        //if(team["scouter"]==name && (match["matchPredictedTime"]*1000)>currentTime.millisecondsSinceEpoch){
        DateTime dataMatchTime = DateTime.fromMillisecondsSinceEpoch(
                match["matchPredictedTime"] * 1000)
            .toLocal();
        if (team["scouter"] == name && currentTime.isBefore(dataMatchTime)) {
          print(DateTime.fromMillisecondsSinceEpoch(
                  match["matchPredictedTime"] * 1000)
              .toLocal());
          print(DateTime.now());
          print(team.id);
          print(match.id);
          print("\n");
          List<int> toReturn = [
            int.parse(team.id.substring(3)),
            int.parse(match.id)
          ];
          return toReturn;
        }
      }
    }
    return [-15, -215];
  }

  int teamNum = -2;

  int extraWidgets = 4;

  List<Widget> pageList = [];

  List<String> qualitiesInt = [
    "low goal scored",
    "high goal scored",
    "back hole scored"
  ];
  List<String> qualitiesYesNo = [
    "Rotation Control",
    "Position Control",
    "Hang",
    "Hang balenced",
    "any violations",
    "won game"
  ];

  Future<List<Widget>> createThePage(
      List<String> qualitiesInt, List<String> qualitiesYesNo) async {
    List<int> teamNameAndNum = await getTeamClosestTimeTeam();
    List<Widget> thePageValue = [];
    widget.allData["teamNum"] = teamNameAndNum[0];
    widget.allData["matchNum"] = teamNameAndNum[1];
    thePageValue.add(Text(teamNameAndNum[0].toString()));
    thePageValue.add(Text("Match Num" + teamNameAndNum[1].toString()));
    for (int i = 0; i < qualitiesInt.length; i++) {
      thePageValue.add(Text(qualitiesInt[i]));
      widget.allData.putIfAbsent(qualitiesInt[i], () => 0);

      thePageValue.add(Row(children: <Widget>[
        TextButton(
          child: Text("+1"),
          onPressed: () async {
            print(widget.allData);

            print(widget.allData[qualitiesInt[i]]);
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value + 1);

            /* pageList.addAll(await createThePage(qualitiesInt, qualitiesYesNo));
            print(pageList);
            pageList.removeRange(
                0,
                qualitiesInt.length * 2 +
                    extraWidgets +
                    qualitiesYesNo.length * 2);*/
            pageList = await createThePage(qualitiesInt, qualitiesYesNo);
            print(pageList);
            setState(() {});
          },
        ),
        TextButton(
          child: Text("-1"),
          onPressed: () async {
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value - 1);

            pageList = await createThePage(qualitiesInt, qualitiesYesNo);
            print(pageList);
            setState(() {});
          },
        ),
        Text(widget.allData[qualitiesInt[i]].toString()),
      ]));
    }

    for (int i = 0; i < qualitiesYesNo.length; i++) {
      thePageValue.add(Text(qualitiesYesNo[i]));
      widget.allData.putIfAbsent(qualitiesYesNo[i], () => "No");

      thePageValue.add(Row(children: <Widget>[
        TextButton(
          child: Text("Yes"),
          onPressed: () async {
            widget.allData.update(qualitiesYesNo[i], (dynamic value) => "Yes");

            pageList = await createThePage(qualitiesInt, qualitiesYesNo);
            print(pageList);
            setState(() {});
          },
        ),
        TextButton(
          child: Text("No"),
          onPressed: () async {
            widget.allData.update(qualitiesYesNo[i], (dynamic value) => "No");

            pageList = await createThePage(qualitiesInt, qualitiesYesNo);
            print(pageList);
            setState(() {});
            // });
          },
        ),
        Text(widget.allData[qualitiesYesNo[i]].toString()),
      ]));
    }
    thePageValue.add(
      InkWell(
        child: Text(
          "go to auto",
          textScaleFactor: 2,
        ),
        onTap: () {
          goToAutoMatchScout(context, widget.allData);
        },
      ),
    );
    thePageValue.add(
      InkWell(
        child: Text(
          "go to Drivier Rating",
          textScaleFactor: 2,
        ),
        onTap: () {
          goToDriverRatingMatchScout(context, widget.allData);
        },
      ),
    );

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
              ElevatedButton(
                onPressed: () async {
                  pageList = await createThePage(qualitiesInt, qualitiesYesNo);
                  setState(() {});
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFd82934))),
                child: Text("Load Page"),
              )
            ]),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ListView(children: pageList)));
  }
}
