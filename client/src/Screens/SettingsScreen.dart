import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_monitor/Pages/HomeDrawer.dart';
import 'package:plant_monitor/Utils/Atmosphere.dart';
 
class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settingsScreen';

 SettingsScreen({Key key}) : super(key: key);
 
 _SettingsScreenState createState() => _SettingsScreenState();
}
 
class _SettingsScreenState extends State<SettingsScreen> {
 
  Future<int> _scanInterval;
  TextEditingController _scanIntervalController;
  bool _firstTimeTextField = true;

  @override
  void initState() {
    super.initState();
    _scanInterval = _getScanInterval();
  }

  @override
  Widget build(BuildContext context) {

   return SafeArea(
     child: Scaffold(
        appBar: AppBar(
          title: 
          Text("Settings",
            style: TextStyle(color: Colors.black87),
          ),
        iconTheme: IconThemeData(color: Colors.grey[850]),  
        leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
          color: Colors.grey[850],),
        onPressed: () => Navigator.pop(context),
        ),
        ),
        backgroundColor: Colors.grey[850],
        endDrawer: HomeDrawer(),
        body: 
        Padding(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child:
                Text(
                  "Scan Interval",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: Colors.green, fontSize: 22.0),
                ),
              ),
              Stack(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 30.0/*(MediaQuery.of(context).size.width.toDouble()/5.0)*/, right: (MediaQuery.of(context).size.width.toDouble()/1.7)),
                  child:
                   FutureBuilder( 
                    future: _scanInterval,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return CircularProgressIndicator(backgroundColor: Colors.grey[850]);
                        case ConnectionState.done: {
                          if(_firstTimeTextField == true) {
                            _firstTimeTextField = false;
                            return TextField(
                              controller: _scanIntervalController = TextEditingController(text: snapshot.data.toString()),
                              textAlign: TextAlign.center,
                              cursorColor: Colors.green,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 25.0,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.white24, width: 2.0),
                                )
                              ),
                            );
                          }
                        else
                          return TextField(
                              controller: _scanIntervalController,
                              textAlign: TextAlign.center,
                              cursorColor: Colors.green,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 25.0,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.white24, width: 2.0),
                                )
                              ),
                            );
                        }
                      }
                    }
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, left: (MediaQuery.of(context).size.width.toDouble()/2.4)),
                  child:
                  Text(
                    "Hours",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(color: Colors.green, fontSize: 25.0),
                  ),
                ), 
              ],
              ),  
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: (MediaQuery.of(context).size.width.toDouble()/1.6)),
                child:
                CupertinoButton(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30.0),
                  padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 30.0, right: 30.0),
                  pressedOpacity: 0.6,
                  child: Text(
                    "Save",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(color: Colors.grey[850], fontSize: 22.0),
                  ),
                  onPressed: () => _postScanInterval(),
                ),
              ),   
            ],
          ),  
        ),
      ),
   );  
  }

  Future<int> _getScanInterval() async {
    Atmosphere atmosphere = Atmosphere();
    int scanInterval = await atmosphere.getScanInterval();
    return scanInterval;
  }
  
  void _postScanInterval() async {
    if(_scanIntervalController.text.length == 0) {
      Fluttertoast.showToast(
        msg: "Insert scan interval",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
    }
    // Check if text is not an integer
    else if(int.tryParse(_scanIntervalController.text) == null) {
      Fluttertoast.showToast(
        msg: "Insert a number",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
    }
    else {
      Atmosphere atmosphere = Atmosphere();
      String posted = await atmosphere.postScanInterval(int.parse(_scanIntervalController.text));
      if(posted == "200") {
        Fluttertoast.showToast(
          msg: "Scan interval saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.brown,
          textColor: Colors.grey[850],
          fontSize: 14.0
        );
      }
      else {
        Fluttertoast.showToast(
          msg: "Error " + posted + ", scan interval not saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.brown,
          textColor: Colors.grey,
          fontSize: 14.0
        );
      }
    }
  }
}
