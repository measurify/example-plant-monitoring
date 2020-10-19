import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_monitor/Screens/HomeScreen.dart';
import 'package:plant_monitor/Utils/Atmosphere.dart';

class LogInScreen extends StatefulWidget {
  static const String routeName = '/loginscreen';

  LogInScreen({Key key}) : super(key: key);


  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  bool _hidePassword = true;
  IconData _iconHidePassword = Icons.visibility_off;
  TextEditingController _userController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  void hidePassword () {
    if(_hidePassword == true) {
      setState(() {_hidePassword = false; _iconHidePassword = Icons.visibility;});
    } 
    else setState(() {_hidePassword = true; _iconHidePassword = Icons.visibility_off;});
  }

  void login() async {
    if(_userController.text.length == 0 && _passController.text.length == 0) {
      Fluttertoast.showToast(
        msg: "Insert username and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
    }
    else if(_userController.text.length == 0 ) {
      Fluttertoast.showToast(
        msg: "Insert username",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
    }
    else if(_passController.text.length == 0) {
      Fluttertoast.showToast(
        msg: "Insert password",
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
      bool successLogin =  await atmosphere.login(username: _userController.text.toString(), password: _passController.text.toString());
      if (successLogin == true) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()),  (route ) => false);
      }
      else if(successLogin == false) {
        Fluttertoast.showToast(
        msg: "Wrong username or password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child:Scaffold(
        backgroundColor: Colors.green,
        //resizeToAvoidBottomPadding: false,
        body:
        ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: 
          //ListView(children: <Widget>[
           Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                    child: 
                    Image(
                      image: ExactAssetImage("assets/images/LogoColorCubemdpi.png",),
                      width: 135.0,
                      height: 135.0,
                    ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: 
                Text(
                  "Plant Monitor",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 60.0,
                    fontFamily: 'Lobster',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, right: 40.0, left: 40.0),
                child: 
                Container(
                  padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.grey[850],
                    shape: BoxShape.rectangle,
                  ),
                  height: 310.0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextField(
                          controller: _userController,
                          textAlign: TextAlign.center,
                            cursorColor: Colors.green,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18.0,
                            ),
                          decoration: InputDecoration(
                            labelText: '     Username',
                            labelStyle: TextStyle(color: Colors.green, fontSize: 18.0),
                            contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                            icon: Icon(Icons.account_circle, color: Colors.green,),
                            focusedBorder: 
                            OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            enabledBorder: 
                            OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Colors.white24, width: 2.0),
                            )
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 25.0),
                          child: 
                            TextField(
                              controller: _passController,
                              textAlign: TextAlign.center,
                              cursorColor: Colors.green,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18.0,
                              ),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                 icon: Icon(_iconHidePassword),
                                 color: Colors.white24,
                                 onPressed: () => {hidePassword()},
                                ),
                                labelText: "     Password",
                                labelStyle: TextStyle(color: Colors.green, fontSize: 18.0),
                                contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                icon: Icon(Icons.lock_outline, color: Colors.green,),                            
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.white24, width: 2.0),
                                )
                              ),
                              obscureText: _hidePassword,
                            ),  
                        ),
                        Padding(
                          padding: 
                          EdgeInsets.only(top: 15.0),
                          child: 
                          Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.green, fontSize: 18.0)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: 
                          CupertinoButton(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30.0),
                            padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 30.0, right: 30.0),
                            pressedOpacity: 0.6,
                            child: Text(
                              "Login",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(color: Colors.grey[850], fontSize: 22.0),
                            ),
                            onPressed: () => {login()},
                          ),
                        ),
                        Padding(
                          padding: 
                          EdgeInsets.only(top: 10.0),
                          child: 
                          Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.green, fontSize: 20.0)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),           
            ],
          ),
          ),
        ]),
      ),
    );    
  } 
}