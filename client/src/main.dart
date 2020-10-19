import 'package:flutter/material.dart';
import 'package:plant_monitor/Utils/Router.dart';
import 'package:plant_monitor/Screens/InitialLoadingScreen.dart';
import 'package:flutter/services.dart';

void main() async {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // Block the app in portrait mode
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]); 
    return MaterialApp (
      title: 'Plant Monitor',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: InitialLoadingScreen.routeName,
      onGenerateRoute: (settings) => Router.generateRoute(settings),
      //onUnknownRoute: (context) => ErrorScreen(),
    );
  }
}