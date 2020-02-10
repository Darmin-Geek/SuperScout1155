import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

Future<File> _getUploadCountFile() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  print(dir);
  File currentFile = File('$dir/uploadPhotoCount.txt');
  print(currentFile);

  File newFile = await currentFile.create();
  return newFile;
}

Future<File> _getNameFile() async {
  // get the path to the document directory.
  String dir = (await getApplicationDocumentsDirectory()).path;
  print(dir);
  File currentFile = File('$dir/Name.txt');
  print(currentFile);

  File newFile = await currentFile.create();
  return newFile;
}

class PitScoutingTeamState extends State<PitScoutingTeamPage>
    with TickerProviderStateMixin {
  TextEditingController description = new TextEditingController();

  int extraWidgets = 2;

  //page list for the tabs that use it
  List<Widget> conPageList = [];
  List<Widget> proPageList = [];

  //question lists
  List<String> constructionNumPitScoutQuestions = ["Rate its existence (1-5)"];
  List<String> constructionYesNoPitScoutQuestions = ["Does it exist?"];

  List<String> programmingNumPitScoutQuestions = [
    "How many questions are there?"
  ];
  List<String> programmingYesNoPitScoutQuestions = ["Are the questions good?"];

  File image;
  bool showImageSubmit = false;
  var pageType = "I";

  List<Widget> createThePage(
      List<String> qualitiesInt, List<String> qualitiesYesNo, String path) {
    List<Widget> thePageValue = [];

    for (int i = 0; i < qualitiesInt.length; i++) {
      thePageValue.add(Text(qualitiesInt[i]));
      widget.allData.putIfAbsent(qualitiesInt[i], () => 0);

      thePageValue.add(Row(children: <Widget>[
        FlatButton(
          child: Text("+1"),
          onPressed: () {
            print(widget.allData);

            print(widget.allData[qualitiesInt[i]]);
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value + 1);

            thePageValue
                .addAll(createThePage(qualitiesInt, qualitiesYesNo, path));

            thePageValue.removeRange(
                0, qualitiesInt.length * 2 + extraWidgets + qualitiesYesNo.length * 2);

            setState(() {});
          },
        ),
        FlatButton(
          child: Text("-1"),
          onPressed: () {
            widget.allData
                .update(qualitiesInt[i], (dynamic value) => value - 1);

            thePageValue
                .addAll(createThePage(qualitiesInt, qualitiesYesNo, path));

            thePageValue.removeRange(
                0, qualitiesInt.length * 2 + extraWidgets + qualitiesYesNo.length * 2);

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
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            widget.allData.update(qualitiesYesNo[i], (dynamic value) => "Yes");

            thePageValue
                .addAll(createThePage(qualitiesInt, qualitiesYesNo, path));
            print(thePageValue);
            thePageValue.removeRange(
                0, qualitiesInt.length * 2 + extraWidgets + qualitiesYesNo.length * 2);
            print(thePageValue);
            setState(() {});
          },
        ),
        FlatButton(
          child: Text("No"),
          onPressed: () {
            widget.allData.update(qualitiesYesNo[i], (dynamic value) => "No");

            thePageValue
                .addAll(createThePage(qualitiesInt, qualitiesYesNo, path));

            thePageValue.removeRange(
                0, qualitiesInt.length * 2 + extraWidgets + qualitiesYesNo.length * 2);

            setState(() {});
          },
        ),
        Text(widget.allData[qualitiesYesNo[i]].toString()),
      ]));
    }
    thePageValue.add(InkWell(
      child: Text("Submit"),
      onTap: () async{
        print("uploading");

        File nameFile = await _getNameFile();
        
        String name = nameFile.readAsStringSync();

        //widget.allData.putIfAbsent("name", () => [name]);
        // if(widget.allData["name"]==name)

        Firestore.instance
            .collection("teams")
            .document(widget.teamNumber)
            .collection("pitScouts")
            .document(path)
            .setData({
          "allData": widget.allData,
        });
        print("done");
        showDialog(context: context, 
        builder: (BuildContext context){return AlertDialog(
          content: Text("Uploaded!"),
        );});
      },
    ));
    if (path == "Construction") {
      conPageList = thePageValue;
    }
    if (path == "Programming") {
      proPageList = thePageValue;
    }
    return thePageValue;
  }

  TabController _tabController;
  @override
  void initState() {
    super.initState();
    //create the tabcontroller. vsync as this is possible do to the mixin
    _tabController = new TabController(
      vsync: this,
      length: 4,
    );
    //addListener adds the function that changes the tabs and the page
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    setState(() {
      // _currentIndex = _controller.index;
      if (_tabController.index == 0) {
        pageType = "I";
        //Firestore.instance.collection("teams").document(widget.teamNumber).collection("pitScouts").document("Construction").get().then((onValue))
      }

      if (_tabController.index == 1) {
        pageType = "C";
        conPageList = createThePage(constructionNumPitScoutQuestions,
            constructionYesNoPitScoutQuestions, "Construction");
      }
      if (_tabController.index == 2) {
        pageType = "P";
        proPageList = createThePage(programmingNumPitScoutQuestions,
            programmingYesNoPitScoutQuestions, "Programming");
      }
      if (_tabController.index == 3) {
        pageType = "photo";
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

          bottom: TabBar(tabs: <Widget>[
            Text("Information"),
            Text("Construction"),
            Text("Programming"),
            Text("Photo"),
          ], controller: _tabController),
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (pageType == "I")
               Column(
                  children: <Widget>[
                    Text(
                        "I can not currently check if a pitscout has been submited\nIf I could, that information would be here")
                  ],
                ),
            
              
            if (pageType == "C")
               Center(
                child: ListView(
                    padding: EdgeInsets.all(20),
                    shrinkWrap: true,
                    children: conPageList),
              ),
            if (pageType == "P")
              ListView(
                      padding: EdgeInsets.all(20),
                      shrinkWrap: true,
                      children: proPageList),
            if (pageType == "photo")
              Visibility(
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text(
                        "Upload photo of robot",
                        textScaleFactor: 2.5,
                      ),
                      onPressed: () async {
                        await ImagePicker.pickImage(source: ImageSource.gallery)
                            .then((takenPhoto) {
                          setState(() {
                            image = takenPhoto;
                            showImageSubmit = true;
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            if (pageType == "photo" && showImageSubmit)
              Column(
                children: <Widget>[
                  TextField(
                    controller: description,
                    decoration: InputDecoration(hintText: "Description"),
                  ),
                  RaisedButton(
                    child: Text(
                      "Submit photo of robot",
                      textScaleFactor: 2.5,
                    ),
                    onPressed: () async {
                      //counts uploads to use as part of folder upload name
                      File senderUploadCountFile = await _getUploadCountFile();
                      String countDocString =
                          await senderUploadCountFile.readAsString();
                      int count = countDocString.length;

                      File senderNameFile = await _getNameFile();
                      String senderName = await senderNameFile.readAsString();
                      //Storage refrence is path
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child(widget.teamNumber)
                          .child(senderName + " " + count.toString())
                          .child("image");
                      //Order an upload and record it
                      StorageUploadTask storageUploadTask =
                          storageReference.putFile(image);
                      String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      StorageReference referenceOfText = FirebaseStorage
                          .instance
                          .ref()
                          .child(widget.teamNumber)
                          .child(senderName + " " + count.toString())
                          .child("text");
                      File descriptionFile = File("$dir/" + count.toString());
                      String descriptionText = description.text;
                      await descriptionFile.writeAsString(descriptionText);
                      StorageUploadTask sendText =
                          referenceOfText.putFile(descriptionFile);
                      //wait until the uploads are completed
                      await storageUploadTask.onComplete;
                      await sendText.onComplete;
                      print("File uploaded");
                      senderUploadCountFile.writeAsString(
                          await senderUploadCountFile.readAsString() + "0");
                    },
                  ),
                ],
              ),
          ],
        )));
  }
}
