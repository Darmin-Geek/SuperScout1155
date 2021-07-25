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

class AutoMatchScoutState extends State<AutoMatchScout> {
  List<Widget> pageList = [];

  //extraWidget is the amount of widgets not dependent on a question array
  final int extraWidgets = 4;

  //in intQuestions the elements are the questions for which the answer is a number (it defaults to 0)
  List<String> intQuestions = [
    "Starting power cells",
    "Low goal scored (A)",
    "High goal scored (A)",
    "Back hole scored (A)"
  ];
  //in yesNoQuestions the elements are the questions for which the answer is "yes" or "no" (it defaults to no)
  List<String> yesNoQuestions = ["Moved"];

  Future<List<Widget>> createThePage(
      List<String> qualitiesInt, List<String> qualitiesYesNo) async {
    //the first element of teamName and num is the the team number the second element [1] is the match number
    List<int> teamNameAndNum = await getTeamClosestTimeTeam();
    List<Widget> thePageValue = [];

    //add Text widgets to a value that will become pagelist and be displayed
    thePageValue.add(Text(teamNameAndNum[0].toString()));
    thePageValue.add(Text("Match Num" + teamNameAndNum[1].toString()));

    for (int i = 0; i < qualitiesInt.length; i++) {
      //add text widget of question
      thePageValue.add(Text(qualitiesInt[i]));

      //put value in allData so it can be displayed insteam of causing an error
      widget.allData.putIfAbsent(qualitiesInt[i], () => 0);

      //add a row widget
      thePageValue.add(Row(children: <Widget>[
        //Flat buttons are buttons that don't move when clicked. Their clickable surface is the area of the button, not the widget on it
        TextButton(
          //child is the widget in a thing
          child: Text("+1"),
          onPressed: () async {
            //increase the value assosiated with the question by 1
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value + 1);
            //the page does not update so instead the rebuilt page is added and the old page is removed
            pageList.addAll(await createThePage(qualitiesInt, qualitiesYesNo));
            pageList.removeRange(
                0,
                qualitiesInt.length * 2 +
                    extraWidgets +
                    qualitiesYesNo.length * 2);
            setState(() {});
          },
        ),
        TextButton(
          child: Text("-1"),
          onPressed: () async {
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value - 1);

            pageList.addAll(await createThePage(qualitiesInt, qualitiesYesNo));

            pageList.removeRange(
                0,
                qualitiesInt.length * 2 +
                    extraWidgets +
                    qualitiesYesNo.length * 2);
            setState(() {});
          },
        ),

        //This text shows the value being changed
        Text(widget.allData[qualitiesInt[i]].toString()),
      ]));
    }

    //Same thing except there is yes and no instead of +1 and -1
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
          },
        ),
        Text(widget.allData[qualitiesYesNo[i]].toString()),
      ]));
    }
    thePageValue.add(
      InkWell(
        child: Text(
          "Go To TeleOp Scout",
          textScaleFactor: 3,
        ),
        onTap: () {
          goToTeleOpMatchScout(context, widget.allData);
        },
      ),
    );
    thePageValue.add(
      InkWell(
        child: Text(
          "Go To Main Menu",
          textScaleFactor: 3,
        ),
        onTap: () {
          goToMainMenu(context);
        },
      ),
    );

    return thePageValue;
  }

  Future<List<int>> getTeamClosestTimeTeam() async {
    //get the file which stores the user's name
    File file = await _getNameFile();
    //read the file
    String name = file.readAsStringSync();

    //get the time now
    DateTime currentTime = new DateTime.now();

    //get all documents (matches) ordered by their match number
    var matchesPlace = await Firestore.instance
        .collection("matches")
        .orderBy("matchNum")
        .getDocuments();
    for (DocumentSnapshot match in matchesPlace.documents) {
      //get all documents (teams) in order on database
      var teams = await match.reference.collection("teams").getDocuments();
      for (DocumentSnapshot team in teams.documents) {
        DateTime dataMatchTime = DateTime.fromMillisecondsSinceEpoch(
                match["matchPredictedTime"] * 1000)
            .toLocal();
        //check if match is in the future
        if (team["scouter"] == name && currentTime.isBefore(dataMatchTime)) {
          //get the team number and name
          List<int> toReturn = [
            int.parse(team.documentID.substring(3)),
            int.parse(match.documentID)
          ];
          //because the matches are iterated in order, the first one that works is the closest match so return its information
          return toReturn;
        }
      }
    }
    //return these values if there is no match to scout
    return [-15, -215];
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
            //actions appear in the top right
            actions: <Widget>[
              //raised button is a button that moves when clicked and its clickable area is the entire visible button
              //this button loads the page into pageList, causing the widgets to be shown
              ElevatedButton(
                onPressed: () async {
                  pageList.addAll(
                      await createThePage(intQuestions, yesNoQuestions));
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
            child: Column(
          //uses variable pageList instead of declared List<Widget>
          children: pageList,
        )));
  }
}
