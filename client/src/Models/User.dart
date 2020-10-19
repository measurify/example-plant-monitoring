import 'package:flutter/cupertino.dart';

class User {
  String userName;
  String _password;

  User({@required username, @required password}){
    this.userName = userName;
    this._password = password;
  }

  String get password {return _password;}
  set password(value) {_password = value;}
}