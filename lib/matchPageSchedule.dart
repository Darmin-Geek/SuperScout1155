import 'package:flutter/material.dart';


import 'main.dart';


class IndividualMatchState extends State<IndividualMatchPage>{
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
        title: Text(widget.teamsAndScouters[12]),
      ),
      body: Center(child: 
      Column(children: <Widget>[
        //display team # (color) $teamNumber, scouter
        Text('Team 1 (Red) : '+widget.teamsAndScouters[0]+", "+widget.teamsAndScouters[1], textScaleFactor: 1.5,),
        Text('Team 2 (Blue) : '+widget.teamsAndScouters[2]+", "+widget.teamsAndScouters[3], textScaleFactor: 1.5,),
        Text('Team 3 (Blue) : '+widget.teamsAndScouters[4]+", "+widget.teamsAndScouters[5], textScaleFactor: 1.5,),
        Text('Team 4 (Red) : '+widget.teamsAndScouters[6]+", "+widget.teamsAndScouters[7], textScaleFactor: 1.5,),
        Text('Team 5 (Red) : '+widget.teamsAndScouters[8]+", "+widget.teamsAndScouters[9], textScaleFactor: 1.5,),
        Text('Team 6 (Blue) : '+widget.teamsAndScouters[10]+", "+widget.teamsAndScouters[11], textScaleFactor: 1.5,)
      ],
      ),
      ),

    );
}
}
