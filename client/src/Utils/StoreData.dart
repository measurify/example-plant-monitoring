import 'package:shared_preferences/shared_preferences.dart';

class StoreData {

  StoreData();

  /*bool saveStringSynchronous(String data, String key) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {value.setString(key, data).then((secondValue) {return secondValue;});});
  }*/

  Future<bool> saveStringAsynchronous(String data, String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool result = await sharedPreferences.setString(key, data);
    return result;
  }

  /*String loadStringSynchronous({String key}) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {String data = value.getString(key); return data;});
  }*/

  Future<String> loadStringAsynchronous({String key}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String data = sharedPreferences.getString(key);
  return data;
  }

  /*bool saveIntSynchronous(int data, String key) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {value.setInt(key, data).then((secondValue) {return secondValue;});});
  }*/

  Future<bool> saveIntAsynchronous(int data, String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool result = await sharedPreferences.setInt(key, data);
    return result;
  }

  /*int loadIntSynchronous({String key}) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {int data = value.getInt(key); return data;});
  }*/

  Future<int> loadIntAsynchronous({String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance(); 
    int data = sharedPreferences.getInt(key);
    return data;
  }

  /*bool saveBoolSynchronous(bool data, String key) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {value.setBool(key, data).then((secondValue) {return secondValue;});});
  }*/

  Future<bool> saveBoolAsynchronous(bool data, String key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool result = await sharedPreferences.setBool(key, data);
  return result;
  }

  /*bool loadBoolSynchronous({String key}) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {bool data = value.getBool(key); return data;});
  }*/

  Future<bool> loadBoolAsynchronous({String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance(); 
    bool data = sharedPreferences.getBool(key);
    return data;
  }  

  /*bool controlDataSynchronous({String key}) {
    bool result;
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) {result = value.containsKey(key);}); 
    return result;
  }*/

  Future<bool> controlDataAsynchronous({String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool found = sharedPreferences.containsKey(key);
    if(found == true) {
      return true;
    }  
    else if(found == false) {
      return false;  
    }  
  }

  /*bool removeDataSynchronous({String key}) {
    Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    sharedPreferences.then((value) { value.remove(key).then((secondValue) {return secondValue;});});
  }*/
  
  Future<bool> removeDataAsynchronous({String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool result = await sharedPreferences.remove(key);
    return result;
  }
}