import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_monitor/Utils/StoreData.dart';

class DialogChangePlantName {
  
  DialogChangePlantName(String plantName, BuildContext context) {
    this._plantname = plantName;
    this._context = context;
  }

  String _plantname;
  BuildContext _context;

  TextEditingController _nameController;
  bool _firstTimeNameTextField = true;

  Future<Null> dialogShow () async {
    return showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change plant name", textAlign: TextAlign.center,),
          titlePadding: EdgeInsets.only(top: 30),
          titleTextStyle: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
          buttonPadding: EdgeInsets.only(bottom: 10, right: 10, left: 22),
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.only(top: 40, right: 10, left: 10),
          content: Container(
            height: MediaQuery.of(context).size.height / 10,
            child: Column(
              children: <Widget>[
                _textFieldName(),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoButton(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30.0),
              padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 30.0, right: 30.0),
              pressedOpacity: 0.6,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
                style: TextStyle(color: Colors.grey[850], fontSize: 22.0),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
              onPressed: () => _savePlantName(_context),
            ),
          ],
        );
      
        
      }
    );
  }

  Widget _textFieldName() {

    if(_firstTimeNameTextField == true) {
      
      _firstTimeNameTextField = false;

      return TextField(
        controller: _nameController = TextEditingController(text: _plantname),
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
    else if(_firstTimeNameTextField == false) {
      return TextField(
        controller: _nameController,
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

  _savePlantName(BuildContext context) async {
    if(_nameController.text.length == 0) {
      Fluttertoast.showToast(
        msg: "Insert plant name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown,
        textColor: Colors.grey[850],
        fontSize: 14.0
      );
    }
    else {
      StoreData storedata = StoreData();
      bool success = await storedata.saveStringAsynchronous(_nameController.text, "plant0Name");
      if(success == true) {
        Fluttertoast.showToast(
          msg: "Name saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.brown,
          textColor: Colors.grey[850],
          fontSize: 14.0
        );
      Navigator.pop(context);
      }
      else if(success == false) {
        Fluttertoast.showToast(
            msg: "Error, retry!",
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
}