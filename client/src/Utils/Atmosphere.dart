import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:plant_monitor/Utils/StoreData.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class Atmosphere {

  Atmosphere();

  Future<bool> login({@required String username, @required String password}) async {
    bool logged = false;
    var url = 'http://test.atmosphere.tools/v1/login';
    var response = await http.post(url,headers: <String, String> {'Content-Type': 'application/json; charset=utf-8'}, body: '{"username":' + '"' + username + '"' + ',' +  '"password":' + '"' + password + '"}');
    if(response.statusCode.toString().contains("200")) {
      StoreData storeData = StoreData();
      bool savedUsername = await storeData.saveStringAsynchronous(username, "username");
      bool savedPassword = await storeData.saveStringAsynchronous(password, "password");
      bool savedisLogged = await storeData.saveBoolAsynchronous(true, "isLogged");
      if(savedUsername == true && savedPassword == true && savedisLogged == true)
        logged = true;
    } 
    return logged;
  }

  Future<String> getToken() async {
    var url = 'http://test.atmosphere.tools/v1/login';
    StoreData storeData = StoreData();
    String username = await storeData.loadStringAsynchronous(key: "username");
    String password = await storeData.loadStringAsynchronous(key: "password");
    var response = await http.post(url,headers: <String, String> {'Content-Type': 'application/json; charset=utf-8'}, body: '{"username":' + '"' + username + '"' + ',' +  '"password":' + '"' + password + '"}');
    Map<String, dynamic> responseMap = json.decode(response.body);
    String token = responseMap['token'];
    return token;
  }

  Future<Map<String, dynamic>> getMeasurements(String feature, DateTime startDate, DateTime endDate) async {
    DateTime newEndDate = endDate.add(Duration(days: 1));
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String startDateFormatted = dateFormat.format(startDate);
    //String endDateFormatted = dateFormat.format(endDate);
    String newEndDateFormatted = dateFormat.format(newEndDate);
    String token = await getToken();
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': token
    };

    // Day Mode
    if(startDate.day == endDate.day && startDate.month == endDate.month && startDate.year == endDate.year) {
      var url = 'http://test.atmosphere.tools/v1/measurements?filter={"thing":"plant", "feature": "' + feature + '","startDate": {"\$gt": "' + startDateFormatted + '"},"endDate": {"\$lt": "' + newEndDateFormatted + '"}}&limit=100&page=1';
      var response = await http.get(url,headers: requestHeaders);
      Map<String, dynamic> responseMap = json.decode(response.body);
      return responseMap;
    }

    // Month Mode
    if(((startDate.add(Duration(days: 31)).isAfter(endDate) && startDate.day != endDate.day) || (startDate.add(Duration(days: 31)).day == endDate.day && startDate.add(Duration(days: 31)).month == endDate.month))){
      var url = 'http://test.atmosphere.tools/v1/measurements?filter={"thing":"plant", "feature": "' + feature + '","startDate": {"\$gt": "' + startDateFormatted + '"},"endDate": {"\$lt": "' + newEndDateFormatted + '"}}&limit=2000&page=1';
      var response = await http.get(url,headers: requestHeaders);
      Map<String, dynamic> responseMap = json.decode(response.body);
      return responseMap;
    }
    // Year Mode
    if(startDate.add(Duration(days: 31)).isBefore(endDate)) {
      Duration durationTime = endDate.difference(startDate);
      double totalMonths = durationTime.inDays/31;
      // We speculate that the max of datas sent to atmosphere for each feature in one month is 2000
      int limit = (totalMonths*2000).ceil(); 
      var url = 'http://test.atmosphere.tools/v1/measurements?filter={"thing":"plant", "feature": "' + feature + '","startDate": {"\$gt": "' + startDateFormatted + '"},"endDate": {"\$lt": "' + newEndDateFormatted + '"}}&limit=' + limit.toString() + '&page=1';
      var response = await http.get(url,headers: requestHeaders);
      Map<String, dynamic> responseMap = json.decode(response.body);
      return responseMap;
    }
  }

  Future<Map<String, dynamic>> getAllMeasurements() async {
    String token = await getToken();
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': token
    };
    var url = 'http://test.atmosphere.tools/v1/measurements?filter={"thing":"plant"}&limit=10&page=1';
    var response = await http.get(url,headers: requestHeaders);
    Map<String, dynamic> responseMap = json.decode(response.body);
    return responseMap;
  }

  Future<int> getScanInterval() async {
    String token = await getToken();
    Map<String, String> requestHeaders = {
      'Authorization': token
    };
    var url = 'http://test.atmosphere.tools/v1/scripts/plant-monitor-script';
    var response = await http.get(url,headers: requestHeaders);
    Map<String, dynamic> responseMap = json.decode(response.body);
    return int.parse(responseMap['code']);
  }

  Future<String> postScanInterval(int scanInterval) async {
    String token = await getToken();
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json; charset=utf-8',
      'Authorization': token
    };
    var url = 'http://test.atmosphere.tools/v1/scripts/plant-monitor-script';
    var response = await http.put(url, headers: requestHeaders, body: '{"code": ' + scanInterval.toString() + '}');
    return response.statusCode.toString();
  }
}