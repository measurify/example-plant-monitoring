import 'package:flutter/material.dart';
import 'package:plant_monitor/Screens/SettingsScreen.dart';
import 'package:plant_monitor/Screens/AccountScreen.dart';
import 'package:plant_monitor/Screens/LogInScreen.dart';
import 'package:plant_monitor/Utils/StoreData.dart';

class HomeDrawer extends StatefulWidget {

  static const String routeName = '/homeDrawer';

  HomeDrawer({Key key}) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
  
}

class _HomeDrawerState extends State<HomeDrawer> {

    @override
  Widget build(BuildContext context) {
    return Drawer( 
      child: Scaffold(
        body: Container(
          color: Colors.green,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0) ,
            child: ListView(
              children: <Widget>[
                Row(children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.only(left: 10.0),
                    icon: Icon(Icons.menu, color: Colors.grey[850],),
                    alignment: Alignment.centerRight,
                    onPressed: () => Navigator.pop(context),
                  ), 
                  Padding(
                    padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width.toDouble()/4.7)),
                    child:
                    Text(
                      "Menu",
                      textDirection: TextDirection.ltr,
                      style: TextStyle( color: Colors.black87, fontSize: 22.0),
                    ),
                  ),  
                ],
                ),
                Divider(
                    color: Colors.black87,
                ),
                Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only( top: 25.0, bottom: 10.0, left: (MediaQuery.of(context).size.width.toDouble()/4.2)),
                    child: 
                    ClipOval(
                      child: 
                      Image(
                        image: ExactAssetImage("assets/images/LogoColorCubemdpi.png",),
                        width: 135.0,
                        height: 135.0,
                      ),
                    ),
                  ),  
                ],),  
                ListTile(
                  contentPadding: EdgeInsets.only(top: (MediaQuery.of(context).size.height.toDouble()/30.0), left: (MediaQuery.of(context).size.width.toDouble()/4.6)),
                  leading: Icon(Icons.account_circle, color: Colors.grey[850], size: 45.0),
                  title: Text(
                    "Account",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.black87, fontSize: 22.0),
                  ),
                  onTap: () => Navigator.pushNamed(context, AccountScreen.routeName),
                ),
                ListTile(
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: ((MediaQuery.of(context).size.height.toDouble()*32)/100) , left: (MediaQuery.of(context).size.width.toDouble()/4.6)),
                  leading: Icon(Icons.exit_to_app, color: Colors.grey[850], size: 45.0),
                  title: Text(
                    "Log out",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.black87, fontSize: 22.0),
                  ),
                  onTap: () => logOut()
                ),
                
              ],
            ), 
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.green,
          child:
          Container(
            height: 62,
            child: Column(
              children: [
              Divider(
                height: 6,
                color: Colors.black87,),
              ListTile(
                contentPadding: EdgeInsets.only(left: (MediaQuery.of(context).size.width.toDouble()/4.6)),
                leading: Icon(Icons.settings, color: Colors.grey[850], size: 45.0,),
                title: Text(
                  "Settings",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black87, fontSize: 22.0),
                ),
                onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
              ),
              ]
            ),
          )
        ),
      ),
    );
  }

  void logOut() async {
    StoreData storeData = StoreData();
    bool removeUsername = await storeData.removeDataAsynchronous(key: "username");
    bool removePassword = await storeData.removeDataAsynchronous(key: "password");
    bool storeIsLogged = await storeData.saveBoolAsynchronous(false, "isLogged");
    if(removeUsername == true && removePassword == true && storeIsLogged == true)
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LogInScreen()),  (route ) => false);
  }
}