import 'package:flutter/material.dart';
import 'package:plant_monitor/Screens/AccountScreen.dart';
import 'package:plant_monitor/Screens/HomeScreen.dart';
import 'package:plant_monitor/Screens/SettingsScreen.dart';
import 'package:plant_monitor/Screens/PlantScreen.dart';
import 'package:plant_monitor/Screens/LogInScreen.dart';
import 'package:plant_monitor/Screens/InitialLoadingScreen.dart';
 
abstract class Router {
  
 static Route<dynamic> generateRoute(RouteSettings settings) {
 
   switch (settings.name) {
     case HomeScreen.routeName:
       return MaterialPageRoute(
         builder: (context) => HomeScreen(),
         settings: settings);
       break;

      case PlantScreen.routeName:
       return MaterialPageRoute(
         builder: (context) => PlantScreen(),
         settings: settings);
       break;
 
     case SettingsScreen.routeName:
       return MaterialPageRoute<String>(
         builder: (context) => SettingsScreen(),
         settings: settings);
       break;

      case AccountScreen.routeName:
       return MaterialPageRoute<String>(
         builder: (context) => AccountScreen(),
         settings: settings);
       break; 

      case LogInScreen.routeName:
       return MaterialPageRoute<String>(
         builder: (context) => LogInScreen(),
         settings: settings);
       break; 

      case InitialLoadingScreen.routeName:
       return MaterialPageRoute<String>(
         builder: (context) => InitialLoadingScreen(),
         settings: settings);
       break;  

     default:
       return MaterialPageRoute(
         builder: (context) => HomeScreen(),
         settings: settings);
       break;
   }
 }
}
