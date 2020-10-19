import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_monitor/Screens/PlantScreen.dart';
import 'package:plant_monitor/Utils/StoreData.dart';
import 'package:plant_monitor/Utils/Atmosphere.dart';

class PlantPreviewWidget extends StatefulWidget {

  String _plantName;

  PlantPreviewWidget();

  @override
  _PlantPreviewWidgetState createState() => _PlantPreviewWidgetState();
}

class _PlantPreviewWidgetState extends State<PlantPreviewWidget> {
  
  Atmosphere _atmosphere = Atmosphere();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Container(
      width: MediaQuery.of(context).size.width.toDouble(),
      height: 130,
        child: GestureDetector(
          onTap: ({plantName}) => Navigator.pushNamed(context, PlantScreen.routeName, arguments: plantName = widget._plantName),
          child: Material(
           color: Colors.brown,
           elevation: 10.0,
           borderRadius: BorderRadius.circular(14.0),
           shadowColor: Colors.black,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: 
                  FutureBuilder(
                    future: _getPlantName(),
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.waiting: return Text("", textAlign: TextAlign.center, style: TextStyle(fontSize: 0.0),);
                        case ConnectionState.done: {
                          return 
                          Text(
                            widget._plantName = snapshot.data,
                            //textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 27.0, color: Colors.black87),
                          );
                        }
                      }
                    }
                  ),
                ),  
                FutureBuilder(
                  future: _atmosphere.getAllMeasurements(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.waiting: return Text("");
                      case ConnectionState.done : {
                        return Column(
                          children:[
                          Text(
                            _getDate(DateTime.parse(snapshot.data['docs'][0]['startDate'])),
                            //textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, color: Colors.grey[850]),
                          ),
                          Padding(padding: EdgeInsets.only(top: 2.0, bottom: 10.0, left: 5.0, right: 5.0),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.only(bottom: 10.0),
                                    child: 
                                      Text(
                                        "Moisture: " + _getMoisture(snapshot.data),
                                        //textDirection: TextDirection.ltr,
                                        style: TextStyle(fontSize: 16.5, color: Colors.white70),
                                      ),
                                    ), 
                                    Text(
                                      "Temperature: " + _getTemperature(snapshot.data),
                                      //textDirection: TextDirection.ltr,
                                      style: TextStyle(fontSize: 16.5, color: Colors.white70),
                                    )
                                  ]
                                ), 
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                  Padding(padding: EdgeInsets.only(bottom: 10.0),
                                    child: 
                                      Text(
                                        "Humidity: " + _getHumidity(snapshot.data),
                                        //textDirection: TextDirection.ltr,
                                        style: TextStyle(fontSize: 16.5, color: Colors.white70),
                                      ),
                                    ), 
                                    Text(
                                      "Light: " + _getLight(snapshot.data),
                                      //textDirection: TextDirection.ltr,
                                      style: TextStyle(fontSize: 16.5, color: Colors.white70),
                                    )
                                  ]
                                ) 
                              ],
                            ),
                          )
                        ]);
                      }
                    }
                  }
                )
              ],
            ), 
          ),
        ),
      ),
    );
  }

  Future<String> _getPlantName() async {
    StoreData storeData = StoreData();
    bool plantExists = await storeData.controlDataAsynchronous(key: "plant0Name");
    if(plantExists == false) {
      storeData.saveStringAsynchronous("Tulipano", "plant0Name");
      return "Tulipano";
    }
    else {
      String plantName = await storeData.loadStringAsynchronous(key: "plant0Name");
      return plantName;
    }
  }

  String _getDate(DateTime date) {
    if(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year) {
      DateFormat dateFormat = DateFormat('HH:mm');
      String result = 'Today ' + dateFormat.format(date);
      return result;
    }
    else if(DateTime.now().subtract(Duration(days: 1)).day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year) {
      DateFormat dateFormat = DateFormat('HH:mm');
      String result = 'Yesterday ' + dateFormat.format(date);
      return result;
    }
    else {
      DateFormat dateFormat = DateFormat('EEEE d MMM yyyy');
      String result = dateFormat.format(date);
      return result;
    }
  }

  String _getMoisture(Map<String, dynamic> measurements) {
    String result;
    double y;
    for(int i = 0; i < 4; i++ ) {
      // Convert moisture in %RH
      if(measurements['docs'][i]['feature'] == "moisture") {
        if(measurements['docs'][i]['samples'][0]['values'][0] is double == false)
          y = measurements['docs'][i]['samples'][0]['values'][0].toDouble();
        else  
          y = measurements['docs'][i]['samples'][0]['values'][0];
        double percentage = (((y - 520) / (260 - 520)) * 100);
        double decimals = (percentage - percentage.truncateToDouble()) * 100 ;
        decimals = (decimals.truncateToDouble() / 100);
        if(((percentage.truncateToDouble()) + decimals).toString().length >= 5)
          return result = (((percentage.truncateToDouble()) + decimals).toString().substring(0, 4)) + "%RH";
        else if(((percentage.truncateToDouble()) + decimals).toString().length < 5)
          return (((percentage.truncateToDouble()) + decimals).toString().substring(0, 2)) + "%RH";
      }
    }
    result = "No data";
    return result;
  }

  String _getHumidity(Map<String, dynamic> measurements) {
    String result;
    for(int i = 0; i < 3; i++ ) {
      if(measurements['docs'][i]['feature'] == "humidity")
        return result = measurements['docs'][i]['samples'][0]['values'][0].toString() + "%RH";
    }
    result = "No data";
    return result;
  }

  String _getTemperature(Map<String, dynamic> measurements) {
    String result;
    for(int i = 0; i < 2; i++ ) {
      if(measurements['docs'][i]['feature'] == "temperature")
        return result = measurements['docs'][i]['samples'][0]['values'][0].toString() + "°C";
    }
    result = "No data";
    return result;
  }

  String _getLight(Map<String, dynamic> measurements) {
    String result;
    for(int i = 0; i < 1; i++ ) {
      if(measurements['docs'][i]['feature'] == "light")
        return result = measurements['docs'][i]['samples'][0]['values'][0].toString() + " Lux";
    }
    result = "No data";
    return result;
  }
}