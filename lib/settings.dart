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


class SettingsState extends State<SettingsPage>{
  TextEditingController username = new TextEditingController();

  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar( 
          
        title: Text("Settings"),
      ),
      body: Center(child: 
      Column(children: <Widget>[
        TextField(controller: username, decoration: InputDecoration(hintText: "Name"),),
        InkWell(child: Text("Submit"),
        onTap: ()async{
          File theFile = await _getNameFile();
          theFile.writeAsString(username.text);
        },)

      ]
      ,)
      ,),
    );
  }
}
