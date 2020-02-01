
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

Future<File> _getUploadCountFile() async{
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


class PitScoutingTeamState extends State<PitScoutingTeamPage> with TickerProviderStateMixin{

  
  bool programmingScoutVisible = false;
  bool constructionScoutVisible = false;

  TextEditingController description = new TextEditingController();

  //String scoringAbility;
  bool canScoreLowGoal = false;
  bool canScoreHighGoal = false;
  bool canAutoScoreLowGoal = false;
  bool canAutoScoreHighGoal = false;
  bool canAutoScoreBackHole = false;

  bool canRotationControl = false;
  bool canPositionControl = false;

  bool canHang = false;
  bool canMoveHang = false;

  bool theRobotIsCool=false;

  List<Widget> conPageList=[];
  List<Widget> proPageList = [];

  List<String> constructionNumPitScoutQuestions = ["Rate its existence (1-5)"]; 
  List<String> constructionYesNoPitScoutQuestions = ["Does it exist?"]; 

  List<String> programmingNumPitScoutQuestions = ["How many questions are there?"];
  List<String> programmingYesNoPitScoutQuestions = ["Are the questions good?"];

  File image;
  bool showImageSubmit=false;
  var pageType = "I";

  var hasConScout;
  //TickerProviderStateMixin tickerProviderStateMixin;

  
  //TabController tabController = new TabController(vsync:  tickerProvider, length: 2);
  
    List<Widget> createThePage(List<String> qualitiesInt, List<String> qualitiesYesNo, String path){
  
   
    List<Widget> thePageValue = [];
   
    for(int i = 0; i<qualitiesInt.length;i++){
      thePageValue.add(Text(qualitiesInt[i]));
      widget.allData.putIfAbsent(qualitiesInt[i], ()=>
       0
      );

      thePageValue.add(Row(children: <Widget>[
           FlatButton(
             child: Text("+1"),
             onPressed: (){
               print(widget.allData);
               
               print(widget.allData[qualitiesInt[i]]);
               widget.allData.update(qualitiesInt[i], (dynamic value)=>value+1);
                  
                  thePageValue.addAll(createThePage(qualitiesInt,qualitiesYesNo,path));
                 
                  thePageValue.removeRange(0, qualitiesInt.length*2+2+qualitiesYesNo.length*2);
                 
                  setState(() {
                    
                  });

             },
           ),
           FlatButton(
             child: Text("-1"),
             onPressed: (){
             
           
                  widget.allData.update(qualitiesInt[i], (dynamic value)=>value-1);
                  
                  thePageValue.addAll(createThePage(qualitiesInt,qualitiesYesNo,path));
                  
                  thePageValue.removeRange(0, qualitiesInt.length*2+2+qualitiesYesNo.length*2);
                  
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
             onPressed: (){
               
               widget.allData.update(qualitiesYesNo[i], (dynamic value)=>"Yes");
                  
                  thePageValue.addAll(createThePage(qualitiesInt,qualitiesYesNo,path));
                  print(thePageValue);
                  thePageValue.removeRange(0, qualitiesInt.length*2+2+qualitiesYesNo.length*2);
                  print(thePageValue);
                  setState(() {
                    
                  });

             },
           ),
           FlatButton(
             child: Text("No"),
             onPressed: (){
             
            
               //setState(() {
                 //print("called");
                // randomTestPart=-1;
                  widget.allData.update(qualitiesYesNo[i], (dynamic value)=>"No");
                  
                  thePageValue.addAll(createThePage(qualitiesInt,qualitiesYesNo,path));
                  
                  thePageValue.removeRange(0, qualitiesInt.length*2+2+qualitiesYesNo.length*2);
                  
                  setState(() {
                    
                  });
              // });
             },
           ),
           
           Text(widget.allData[qualitiesYesNo[i]].toString()),
           ]));
    }
    thePageValue.add(
      InkWell(child: Text("Submit"),
      onTap: (){
        print("uploading");
        
        Firestore.instance.collection("teams").document(widget.teamNumber).collection("pitScouts").document(path).setData({
          "allData":widget.allData,
      });
      print("done");
      },
      ));
      if(path=="Construction"){
        conPageList=thePageValue;
      }
      if(path=="Programming"){
        proPageList=thePageValue;
      }
    return thePageValue;
  }


  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4, );
    _tabController.addListener(_handleTabSelection);
  }
  _handleTabSelection() {
                  setState(() {
                   // _currentIndex = _controller.index;
                  if(_tabController.index==0){
                    pageType="I";
                  //Firestore.instance.collection("teams").document(widget.teamNumber).collection("pitScouts").document("Construction").get().then((onValue))
                  }

                   if(_tabController.index==1){
                      pageType = "C";
                      conPageList = createThePage(constructionNumPitScoutQuestions, constructionYesNoPitScoutQuestions,"Construction");
                   }
                   if(_tabController.index==2){
                      pageType = "P";
                      proPageList = createThePage(programmingNumPitScoutQuestions, programmingYesNoPitScoutQuestions, "Programming");
                   }
                   if(_tabController.index==3){
                     pageType="photo";
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

        bottom: TabBar(
          tabs: <Widget>[
            Text("Information"),
          Text("Construction"),

          /*  Padding(
              padding: EdgeInsets.all(15),
            ),
            */
             Text("Programming"),
              Text("Photo"),
          ],
        controller: _tabController
        ),
      ),
              
            
          
      
      
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          
         mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            if(pageType=="I")
            Visibility(child: Column(
              children: <Widget>[
                Text("I can not currently check if a pitscout has been submited\nIf I could, that information would be here")
              ],
            ),),

            if(pageType=="C")
            Visibility(
              child: Center(
                  
                child:
                ListView(
                shrinkWrap: true,

                children: conPageList

              //TextField(controller: userName, decoration: InputDecoration(hintText: "User Name")),
              /*Row(children: <Widget>[
                Text("Low goal"),
                Switch.adaptive(value: canScoreLowGoal, onChanged: (bool newValue){
                              setState(() {
                                canScoreLowGoal=newValue;
                              });
                          }),
              /*  Radio(groupValue: scoringAbility,value: "Low goal only", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   scoringAbility="Low goal only";
                 });
                  
                }),*/

                Text("Autonomously?"),
                Switch.adaptive(value: canAutoScoreLowGoal, onChanged: (bool newValue){
                              setState(() {
                                canAutoScoreLowGoal=newValue;
                              });
                          }),
              ]),

              Row(children: <Widget>[
               
                Text("High goal"),
                Switch.adaptive(value: canScoreHighGoal, onChanged: (bool newValue){
                              setState(() {
                                canScoreHighGoal=newValue;
                              });
                          }),
                Text("Autonomously?"),
                Switch.adaptive(value: canAutoScoreHighGoal, onChanged: (bool newValue){
                          setState(() {
                            canAutoScoreHighGoal=newValue;
                          });
                      }),
              ]), 
              Row(children: <Widget>[  
              Text("Score back hole autonomously"),
              Switch.adaptive(value: canAutoScoreBackHole, onChanged: (bool newValue){
                        setState(() {
                          canAutoScoreBackHole=newValue;
                        });
                    }),
            ]),     
            Text("Color wheel:"),
            Row(children: <Widget>[
              Text("Rotation"),
              Switch.adaptive(value: canRotationControl, onChanged: (bool newValue){
                            setState(() {
                              canRotationControl=newValue;
                            });
                        }),
         

              Text("Position"),
              Switch.adaptive(value: canPositionControl, onChanged: (bool newValue){
                            setState(() {
                              canPositionControl=newValue;
                            });
                        }),
            ]),
            Row(
              children: <Widget>[
                Text("Hang"),
                Switch.adaptive(value: canHang, onChanged: (bool newValue){
                            setState(() {
                              canHang=newValue;
                            });
                        }),
              
              Text("Can move while hanging"),
                Switch.adaptive(value: canMoveHang, onChanged: (bool newValue){
                            setState(() {
                              canMoveHang=newValue;
                            });
                        }),
              ],
            ),        
                /*Radio(groupValue: scoringAbility,value: "High and low goals", onChanged: (String placeHolderTwo){
                 //print("hi");
                 setState(() {
                   print("hi?");
                   scoringAbility="High and low goals";
                 });
                  
                }                


                
            ),*/
          
            /*Switch.adaptive(value: theRobotIsCool, onChanged: (bool newValue){
              setState(() {
                theRobotIsCool=newValue;
              });
           }), */
            InkWell(
              child: Text("Submit pit scout"),
              onTap: () async {
                File senderNameFile =await _getNameFile();
                String senderName = await senderNameFile.readAsString();
                rootInstance.document(widget.teamNumber).collection("pitScouts").document("Contruction").setData({

                  "UserName":senderName,

                  "scoreLowGoal":canScoreLowGoal,
                  "scoreLowGoalAutonomously":canAutoScoreLowGoal,
                  "scoreHighGoal":canScoreHighGoal,
                  "scoreHighGoalAutonomously":canAutoScoreHighGoal,
                  "scoreBackHoleAutonomously":canAutoScoreBackHole,

                  "canRotationControl":canRotationControl,
                  "canPositionControl":canPositionControl,
              
                  "canHang":canHang,
                  "canMoveWhileHanging":canMoveHang
                  });
              }),*/
              
            ),
            )),
                
            if(pageType=="P")
            Visibility(
              child: ListView(
                shrinkWrap: true,
                children: proPageList
            )),
            if(pageType=="photo")
            Visibility(
              child: Column(children: <Widget>[
                InkWell(child: Text("Take photo of robot",textScaleFactor: 3,),
                onTap: ()async{
                  await ImagePicker.pickImage(source: ImageSource.gallery).then((takenPhoto){
                    setState(() {
                      image=takenPhoto;
                      showImageSubmit=true;
                    });
                  });
                },),
               
              ],),
            ),
            if(pageType == "photo" && showImageSubmit)
            Column(children: <Widget>[ 
              TextField(controller: description, decoration: InputDecoration(hintText: "Description"),),
              InkWell(child: Text("Upload photo of robot",textScaleFactor: 2.5,),
                            onTap: ()async{

                              File senderUploadCountFile = await _getUploadCountFile();
                              String countDocString = await senderUploadCountFile.readAsString();
                              int count = countDocString.length;

                              File senderNameFile = await _getNameFile();
                              String senderName= await senderNameFile.readAsString();
                              StorageReference storageReference = FirebaseStorage.instance.ref().child(widget.teamNumber).child(senderName+" "+count.toString()).child("image");
                              StorageUploadTask storageUploadTask = storageReference.putFile(image);
                              String dir = (await getApplicationDocumentsDirectory()).path;
                              StorageReference referenceOfText = FirebaseStorage.instance.ref().child(widget.teamNumber).child(senderName+" "+count.toString()).child("text");
                              File descriptionFile = File("$dir/"+count.toString());
                              String descriptionText = description.text;
                              await descriptionFile.writeAsString(descriptionText);
                              StorageUploadTask sendText = referenceOfText.putFile(descriptionFile);
                              await storageUploadTask.onComplete;
                              await sendText.onComplete;
                              print("File uploaded");
                              senderUploadCountFile.writeAsString(await senderUploadCountFile.readAsString()+"0");

                            },
            ),
            ],),
                            

          ],
          
                ))
            


              
            
            /*  Text("Programming Pit Scout"),
              if(widget.hasProgrammingPitScout) Icon(Icons.check)
              
              else   InkWell(child: Icon(Icons.note_add),
                onTap: (){
                  goToPitScoutingProgramingScreen(context, widget.teamName, widget.teamNumber);
                },
              ),

              Text("Construction Pit Scout"),
              if(widget.hasProgrammingPitScout) Icon(Icons.check)
              
              else   InkWell(child: Icon(Icons.note_add),
                onTap: (){
                  goToPitScoutingConstructionScreen(context, widget.teamName, widget.teamNumber);
                },
              )
            */  
          
          );
      
    
  }
  
}