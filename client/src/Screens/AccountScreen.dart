import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_monitor/Pages/AccountDrawer.dart';
import 'package:plant_monitor/Utils/StoreData.dart';

class AccountScreen extends StatefulWidget {

static const String routeName = '/accountScreen';

 AccountScreen({Key key}) : super(key: key);
 
 _AccountScreenState createState() => _AccountScreenState();
}
 
class _AccountScreenState extends State<AccountScreen> {

  TextEditingController _userController;
  TextEditingController _passController;
  Future<String> _username;
  Future<String> _password;
  bool _firstTimeUsernameTextField = true ;
  bool _firstTimePasswordTextField = true ;


  @override
  void initState() {

    super.initState();
    _username = getUsername();
    _password = getPassword();
  }

 @override
 Widget build(BuildContext context) {

   return SafeArea(
     child: Scaffold(
       appBar: AppBar(
         title: 
           Text("Account",
             style: TextStyle(color: Colors.black87),
           ),
         iconTheme: IconThemeData(color: Colors.grey[850]), 
         leading: IconButton(
           icon: Icon(Icons.arrow_back_ios, color: Colors.grey[850],),
           onPressed: () => Navigator.pop(context),
          ),
        ),
      backgroundColor: Colors.grey[850],
      endDrawer: AccountDrawer(),
      body: 
        Padding(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child:
                Text(
                  "Username",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: Colors.green, fontSize: 22.0),
                ),
              ),  
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: 
                FutureBuilder(
                  future: _username,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return CircularProgressIndicator(backgroundColor: Colors.grey[850],);
                      case ConnectionState.done: {
                        if(_firstTimeUsernameTextField == true) {
                          _firstTimeUsernameTextField = false;
                          return TextField(
                            controller: _userController = TextEditingController(text: snapshot.data),
                            cursorColor: Colors.green,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                            ),
                            decoration: InputDecoration(
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
                            controller: _userController,
                            cursorColor: Colors.green,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                            ),
                            decoration: InputDecoration(
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
                  }),
                ),    
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 20.0),
                child:
                Text(
                  "Password",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: Colors.green, fontSize: 22.0),
                ),
              ),  
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: 
                FutureBuilder(
                  future: _password,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return CircularProgressIndicator(backgroundColor: Colors.grey[850],);
                      case ConnectionState.done: {
                        if(_firstTimePasswordTextField == true) {
                          _firstTimePasswordTextField = false ;
                          return TextField(
                          controller: _passController = TextEditingController(text: snapshot.data),
                          cursorColor: Colors.green,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
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
                          controller: _passController,
                          cursorColor: Colors.green,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
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
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getUsername() async {
    StoreData storeData = StoreData();
    String username = await storeData.loadStringAsynchronous(key: "username");
    return username;
  }

  Future<String> getPassword() async {
    StoreData storeData = StoreData();
    String  password = await storeData.loadStringAsynchronous(key: "password");
    return password;
  }
}