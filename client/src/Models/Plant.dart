import 'package:flutter/cupertino.dart';

class Plant {
  String name;
  double moisture, humidity, temperature;
  int light;
  DateTime date;

  Plant({@required this.name, this.moisture = -1.0, this.humidity = -1.0, this.temperature = -1.0, this.light = -1 });
}