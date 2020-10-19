import 'package:flutter/material.dart';
import 'package:plant_monitor/Screens/LogInScreen.dart';
import 'package:plant_monitor/Screens/HomeScreen.dart';
import 'package:plant_monitor/Utils/StoreData.dart';

class InitialLoadingScreen extends StatefulWidget {
  static const String routeName = '/initialLoadingScreen';

  InitialLoadingScreen({Key key}) : super(key: key);

  @override
  _InitialLoadingScreenState createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {

  @override
  void initState() {
    super.initState();
    getInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return 
    SafeArea(
      child: 
      Scaffold(
        body:
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.green,
          child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Plant Monitor",
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 60.0,
                  fontFamily: 'Lobster',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child:
                CircularProgressIndicator(backgroundColor: Colors.grey[850],),
              )
          ],),
        ),
      ),
    );  
  }   

  void getInitialRoute() async {
    StoreData storeData = StoreData();
    bool controlIsLogged = await storeData.controlDataAsynchronous(key: "isLogged");
    if(controlIsLogged == true) {
      bool isLogged = await storeData.loadBoolAsynchronous(key: "isLogged");
      if (isLogged ==  true) /*Navigator.pushNamed(context, HomeScreen.routeName)*/  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()),  (route ) => false);
      else if(isLogged == false)  /*Navigator.pushNamed(context, LogInScreen.routeName)*/ Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LogInScreen()),  (route ) => false);
    }
    else if(controlIsLogged ==  false) /*Navigator.pushNamed(context, LogInScreen.routeName)*/ Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LogInScreen()),  (route ) => false);
  }
}

