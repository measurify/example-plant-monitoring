import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:plant_monitor/Utils/Atmosphere.dart';

class PlantTabPage extends StatefulWidget {
  final String measureName;
  const PlantTabPage({@required this.measureName});

  @override
  _PlantTabPageState createState() => _PlantTabPageState();
}

class _PlantTabPageState extends State<PlantTabPage> with AutomaticKeepAliveClientMixin {

  DateTime _startDate = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _endDate = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateFormat _dateFormatDisplay = DateFormat("dd/MM/yyyy");
  List<FlSpot> flSpots;

  void getDate({DateTime date, context, int selection}) async {

    var finalDate = await showRoundedDatePicker(
    
      context: context,
      initialDate: date,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      borderRadius: 20.0,
      theme: ThemeData(       
        primarySwatch: Colors.green,  // Button
        primaryColor: Colors.green,
        accentColor: Colors.green,
        dialogBackgroundColor: Colors.grey[850],
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black87),
          caption: TextStyle(color: Colors.white70),
        ),
        disabledColor: Colors.white70,
        accentTextTheme: TextTheme(
          body2: TextStyle(color: Colors.white70)
        )
      ),
    );  

    if (finalDate != null && selection == 0) {
      setState(() => (_startDate = finalDate));
    }  
    if (finalDate != null && selection == 1) {
      setState(() => (_endDate = finalDate));
    }
  }
  // Set measure unit for y axis title and for info cloud
  String setMeasureUnit() {
    if(widget.measureName == "moisture")
      return "%RH";
    else if(widget.measureName == "humidity")
      return "%RH";
    else if(widget.measureName == "temperature")
      return "°C";
    else if(widget.measureName == "light")
      return " Lux";
  }

  // Create the list of points for chart
  Future<List<FlSpot>> setSpots() async {
    List<FlSpot> listFlSpot = [];
    Atmosphere atmosphere = Atmosphere();
    Map<String, dynamic> measurementsMap = await atmosphere.getMeasurements(widget.measureName, _startDate, _endDate);
    int numberMeasuremts = measurementsMap['totalDocs'];
    DateTime timeMonthMode = _startDate;
    DateTime timeYearMode = _startDate;
    double averageMonthMode = 0;
    double averageYearMode = 0;
    int countMeasurementsMonthMode = 0;
    int countMeasurementsYearMode = 0;

    for(int i = numberMeasuremts - 1; i >= 0; i--) {
      DateTime x = DateTime.parse(measurementsMap['docs'][i]['startDate']);

      // Day mode
      if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
        int hours = x.hour;
        int minutes = x.minute;
        double xResult = hours + (minutes/60);
        double yResult;
        // Control if there are samples
        List<dynamic> samples = (measurementsMap['docs'][i]['samples']);
        if(samples.isEmpty == false) {
          // Elaborate samples
          var y = (measurementsMap['docs'][i]['samples'][0]['values'][0]);
          if( y is int) yResult = y.toDouble();
          else if(y is double == false) yResult = y[0].toDouble();
          else yResult = y;
          // If this is light graph, divide value by 100, so we can have a range from 0 to 450 instead of 0 45000
          if (widget.measureName == "light") yResult = (yResult.toInt()/100).toDouble();
          // if this is moistore graph, convert moisture in %RH
          else if(widget.measureName == "moisture") {
            if(y > 520)
              y = 520;
            else if(y < 260)
              y = 260;
            double percentage = (((y - 520) / (260 - 520)) * 100);
            double decimals = (percentage - (percentage.truncateToDouble())) * 100 ;
            decimals = (decimals.truncateToDouble() / 100);
            if(((percentage.truncateToDouble()) + decimals).toString().length >= 5)
              yResult = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 4));
            else if(((percentage.truncateToDouble()) + decimals).toString().length < 5)
              yResult = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 2));
          }
          listFlSpot.add(FlSpot(xResult, yResult));
        }
      }

      // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
        // Control if there are samples
        List<dynamic> samples = (measurementsMap['docs'][i]['samples']);
        if(samples.isEmpty == false) {
          // Elaborate samples
          var y = (measurementsMap['docs'][i]['samples'][0]['values'][0]);
          if( y is int) y = y.toDouble();
          else if(y is double == false) y = y[0].toDouble();
          else y = y;
          // If this is light graph, divide value by 100, so we can have a range from 0 to 450 instead of 0 45000
          if (widget.measureName == "light") y = (y.toInt()/100).toDouble();
          // if this is moistore graph, convert moisture in %RH
          else if(widget.measureName == "moisture") {
            if(y > 520)
              y = 520;
            else if(y < 260)
              y = 260;
            double percentage = (((y - 520) / (260 - 520)) * 100);
            double decimals = (percentage - (percentage.truncateToDouble())) * 100 ;
            decimals = (decimals.truncateToDouble() / 100);
            if(((percentage.truncateToDouble()) + decimals).toString().length >= 5)
              y = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 4));
            else if(((percentage.truncateToDouble()) + decimals).toString().length < 5)
              y = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 2));
          }
          if(x.day == timeMonthMode.day && i == 0) {
            averageMonthMode = averageMonthMode + y;
            countMeasurementsMonthMode++;
            double yResult = (averageMonthMode/countMeasurementsMonthMode);
            String decimalYResult = ((yResult - yResult.truncateToDouble()).toString());
            int lenghtDecimalString = decimalYResult.length;
            if(lenghtDecimalString <= 4)
              decimalYResult = decimalYResult.substring(0);
            else decimalYResult = decimalYResult.substring(0, 4);  
            double decimalDoubleYResult = double.parse(decimalYResult);
            yResult = yResult.truncateToDouble() + decimalDoubleYResult;
            double xResult = (timeMonthMode.difference(_startDate).inDays).toDouble();
            listFlSpot.add(FlSpot(xResult, yResult));
          }
          else if(x.day == timeMonthMode.day) {
            averageMonthMode = averageMonthMode + y;
            countMeasurementsMonthMode++;
          }
          else if(x.day != timeMonthMode.day) {
            if(averageMonthMode != 0) {
              double yResult = (averageMonthMode/countMeasurementsMonthMode);
              String decimalYResult = ((yResult - yResult.truncateToDouble()).toString());
              int lenghtDecimalString = decimalYResult.length;
              if(lenghtDecimalString <= 4)
                decimalYResult = decimalYResult.substring(0);
              else decimalYResult = decimalYResult.substring(0, 4);  
              double decimalDoubleYResult = double.parse(decimalYResult);
              yResult = yResult.truncateToDouble() + decimalDoubleYResult;
              double xResult = (timeMonthMode.difference(_startDate).inDays).toDouble();
              listFlSpot.add(FlSpot(xResult, yResult));
            }
            timeMonthMode = x;
            averageMonthMode = y;
            countMeasurementsMonthMode = 1;
          }
        }
      }

      // Year Mode
      if(_startDate.add(Duration(days: 31)).isBefore(_endDate)) {
        // Control if there are samples
        List<dynamic> samples = (measurementsMap['docs'][i]['samples']);
        if(samples.isEmpty == false) {
          // Elaborate samples
          var y = (measurementsMap['docs'][i]['samples'][0]['values'][0]);
          if( y is int) y = y.toDouble();
          else if(y is double == false) y = y[0].toDouble();
          else y = y;
          // If this is light graph, divide value by 100, so we can have a range from 0 to 450 instead of 0 45000
          if (widget.measureName == "light") y = (y.toInt()/100).toDouble();
          // if this is moistore graph, convert moisture in %RH
          else if(widget.measureName == "moisture") {
            if(y > 520)
              y = 520;
            else if(y < 260)
              y = 260;
            double percentage = (((y - 520) / (260 - 520)) * 100);
            double decimals = (percentage - (percentage.truncateToDouble())) * 100 ;
            decimals = (decimals.truncateToDouble() / 100);
            if(((percentage.truncateToDouble()) + decimals).toString().length >= 5)
              y = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 4));
            else if(((percentage.truncateToDouble()) + decimals).toString().length < 5)
              y = double.parse(((percentage.truncateToDouble()) + decimals).toString().substring(0, 2));
          }
          if(x.month == timeYearMode.month && i == 0) {
            averageYearMode = averageYearMode + y;
            countMeasurementsYearMode++;
            double yResult = averageYearMode/countMeasurementsYearMode;
            String decimalYResult = ((yResult - yResult.truncateToDouble()).toString());
            int lenghtDecimalString = decimalYResult.length;
            if(lenghtDecimalString <= 4)
              decimalYResult = decimalYResult.substring(0);
            else decimalYResult = decimalYResult.substring(0, 4);
            double decimalDoubleYResult = double.parse(decimalYResult);
            yResult = yResult.truncateToDouble() + decimalDoubleYResult;
            double xResult = ((_startDate.month - timeYearMode.month) + 12 * (_startDate.year - timeYearMode.year)).abs().toDouble();
            listFlSpot.add(FlSpot(xResult, yResult));
          }
          else if(x.month == timeYearMode.month) {
            averageYearMode = averageYearMode + y;
            countMeasurementsYearMode++;
          }
          else if(x.month != timeYearMode.month) {
            if(averageYearMode != 0) {
              double yResult = averageYearMode/countMeasurementsYearMode;
              String decimalYResult = ((yResult - yResult.truncateToDouble()).toString());
              int lenghtDecimalString = decimalYResult.length;
              if(lenghtDecimalString <= 4)
                decimalYResult = decimalYResult.substring(0);
              else decimalYResult = decimalYResult.substring(0, 4);
              double decimalDoubleYResult = double.parse(decimalYResult);
              yResult = yResult.truncateToDouble() + decimalDoubleYResult;
              double xResult = ((_startDate.month - timeYearMode.month) + 12 * (_startDate.year - timeYearMode.year)).abs().toDouble();
              listFlSpot.add(FlSpot(xResult, yResult));
            }
            timeYearMode = x;
            averageYearMode = y;
            countMeasurementsYearMode = 1;
          }
        }
      }
    }

    return listFlSpot;
  }

  // Set markers of x axis
  String setBottomTitles(value) {

    //Day Mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      switch (value.toInt()) {
        case 0: return "00:00";
        //case 4: return "04:00";
        case 7: return "07:00";
        case 14: return "14:00";
        //case 16: return "16:00";
        case 21: return "21:00";

        default: return "";
      }
    }

    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      DateFormat dateFormat = DateFormat('d');
      if(value == 0)
        return dateFormat.format(_startDate);
      if((value % value.truncateToDouble()) == 0) {
        double numberOfDays = (_endDate.difference(_startDate).inDays).toDouble();
        if(numberOfDays <= 9)
          return dateFormat.format(_startDate.add(Duration(days: value.toInt())));
        else {
          double divisor = (numberOfDays/9).ceil().toDouble();
          if(value % divisor == 0)
            return dateFormat.format(_startDate.add(Duration(days: value.toInt())));
        }
      }
    }

    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)) {
      DateFormat dateFormat = DateFormat('MMM');
      if(value == 0)
        return dateFormat.format(_startDate);
      if((value % value.truncateToDouble()) == 0) {
        double years = 0;
        double months = _startDate.month + value; 
        double numberOfMonths = ((_startDate.month - _endDate.month) + 12 * (_startDate.year - _endDate.year)).abs().toDouble();
        if(numberOfMonths <= 7) {
          while(months > 12) {
          months = months - 12;
          years++;
          }
          DateTime date = new DateTime((_startDate.year + years).toInt(), months.toInt());
          return dateFormat.format(date);
        }
        else {
          double divisor = (numberOfMonths/7).ceil().toDouble();
          if(value % divisor == 0) {
            while(months > 12) {
              months = months - 12;
              years++;
            }
          DateTime date = new DateTime((_startDate.year + years).toInt(), months.toInt());
          return dateFormat.format(date);
          }
        }
      }
    }
  }

  // Set markers of y axis
  String setLeftTitles(value) {
    if(widget.measureName == "moisture"){
      switch (value.toInt()) {
        case 0: return "0";
        case 10: return "10";
        case 20: return "20";
        case 30: return "30";
        case 40: return "40";
        case 50: return "50";
        case 60: return "60";
        case 70: return "70";
        case 80: return "80";
        case 90: return "90";
        case 100: return "100";
        default: return "";
      }
    }
    else if(widget.measureName == "humidity"){
      switch (value.toInt()) {
        case 0: return "0";
        case 10: return "10";
        case 20: return "20";
        case 30: return "30";
        case 40: return "40";
        case 50: return "50";
        case 60: return "60";
        case 70: return "70";
        case 80: return "80";
        case 90: return "90";
        case 100: return "100";
        default: return "";
      }
    }
    else if(widget.measureName == "temperature"){
      switch (value.toInt()) {
        case 0: return "0";
        case 3: return "3";
        case 6: return "6";
        case 9: return "9";
        case 12: return "12";
        case 15: return "15";
        case 18: return "18";
        case 21: return "21";
        case 24: return "24";
        case 27: return "27";
        case 30: return "30";
        case 33: return "33";
        case 36: return "36";
        case 39: return "39";
        case 42: return "42";
        case 45: return "45";
        default: return "";
      }
    }
    else if(widget.measureName == "light"){
      switch (value.toInt()) {
        case 0: return "0";
        case 50: return "5k";
        case 100: return "10k";
        case 150: return "15k";
        case 200: return "20k";
        case 250: return "25k";
        case 300: return "30k";
        case 350: return "35k";
        case 400: return "40k";
        case 450: return "45k";
        default: return "";
      }
    }
  }

  // Set text that is shown inside the info cloud when user click on a point
  String setInfoCloudText (LineBarSpot lineBarSpot) {
    String result;
    // Day Mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      int hours = lineBarSpot.x.truncate();
      double minutes = (lineBarSpot.x - hours)*60;
      var y;
      // If this is light graph, multiply by 100, because it sets light in the right value and we want to display value as int
      if(widget.measureName == "light") y = (lineBarSpot.y*100).toInt();
      else y = lineBarSpot.y;
      if(hours < 10 && minutes < 10)
        result = '0' + hours.toString().substring(0, 1) + ':0' + minutes.toString().substring(0, 1) + '\n' + y.toString() + setMeasureUnit();
      else if(hours < 10 && minutes >= 10)
        result = '0' + hours.toString().substring(0, 1) + ':' + minutes.toString().substring(0, 2) + '\n' + y.toString() + setMeasureUnit();  
      else if(hours >= 10 && minutes < 10)
        result = hours.toString().substring(0, 2) + ':0' + minutes.toString().substring(0, 1) + '\n' + y.toString()  + setMeasureUnit();  
      else if(hours >= 10 && minutes >= 10)
        result = hours.toString().substring(0, 2) + ':' + minutes.toString().substring(0, 2) + '\n' + y.toString()  + setMeasureUnit();    
      return result;
    }
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
        DateFormat dateFormat = DateFormat('d MMM');
        var y;
        // If this is light graph, multiply by 100, because it sets light in the right value and we want to display value as int
        if(widget.measureName == "light") y = (lineBarSpot.y*100).toInt();
        else y = lineBarSpot.y;
        result = dateFormat.format(_startDate.add(Duration(days: lineBarSpot.x.toInt()))) + '\n' + y.toString() + setMeasureUnit();
        return result;
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      DateFormat dateFormat = DateFormat('MMM yyyy');
      var y;
      // If this is light graph, multiply by 100, because it sets light in the right value and we want to display value as int
      if(widget.measureName == "light") y = (lineBarSpot.y*100).toInt();
      else y = lineBarSpot.y;
      double years = 0;
      double months = _startDate.month + lineBarSpot.x; 
      while(months > 12) {
        months = months - 12;
        years++;
      }
      DateTime date = new DateTime((_startDate.year + years).toInt(), months.toInt());
      result = dateFormat.format(date) + '\n' + y.toString() + setMeasureUnit();
      return result;
    }
  }

  // Set minimum x value of the chart
  double getMinX() {
    // Always 0 in every mode
    return 0;
  }

  // Set maximum x value of the chart
  double getMaxX() {
    // Day Mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) return 24;
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      double result = _endDate.difference(_startDate).inDays.toDouble();
      return result;
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      bool equal = false;
      double months = 0;
      months = ((_startDate.month - _endDate.month) + 12 * (_startDate.year - _endDate.year)).abs().toDouble();
      return months;
    }
  }
  
  // Set minimum y value of the chart
  double getMinY() {
    if(widget.measureName == "moisture") return 0;
    if(widget.measureName == "humidity") return 0;
    if(widget.measureName == "temperature") return 0;
    if(widget.measureName == "light") return 0;
  }

  // Set maximum y value of the chart
  double getMaxY() {
    if(widget.measureName == "moisture") return 100;
    if(widget.measureName == "humidity") return 100;
    if(widget.measureName == "temperature") return 45;
    if(widget.measureName == "light") return 450;
  }

  //Set the title of x axis 
  String getXAxisTitle() {
    // Day Mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      DateFormat dateFormat = DateFormat('EEEE d MMM yyyy');
      String result = dateFormat.format(_startDate) + "    [Hours]";
      return result;
    }
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      if(_startDate.month == _endDate.month) {
        DateFormat dateFormat = DateFormat('MMMM yyyy');
        String result = dateFormat.format(_startDate) + "    [Days]";
        return result;
      }
      else if(_startDate.month != _endDate.month) {
        DateFormat startDateFormat = DateFormat('MMMM');
        DateFormat endDateFormat = DateFormat('/MMMM yyyy');
        String result = startDateFormat.format(_startDate) + endDateFormat.format(_endDate) + "    [Days]";
        return result;
      }
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      if(_startDate.year == _endDate.year) {
        DateFormat dateFormat = DateFormat('yyyy');
        String result = dateFormat.format(_startDate) + "    [Months]";
        return result;
      }
      else if(_startDate.year != _endDate.year) {
        DateFormat startDateFormat = DateFormat('yyyy');
        DateFormat endDateFormat = DateFormat('/yyyy');
        String result = startDateFormat.format(_startDate) + endDateFormat.format(_endDate) + "    [Months]";
        return result;
      }
    }
  }

  //Set the title of y axis 
  String getYAxisTitle() {
    // Day mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      if(widget.measureName == "moisture") return "Moisture    [%RH]";
      if(widget.measureName == "humidity") return "Humidity    [%RH]";
      if(widget.measureName == "temperature") return "Temperature    [°C]";
      if(widget.measureName == "light") return "Light    [Lux]";
    }
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      if(widget.measureName == "moisture") return "Moisture Daily Average [%RH]";
      if(widget.measureName == "humidity") return "Humidity Daily Average [%RH]";
      if(widget.measureName == "temperature") return "Temperature Daily Average [°C]";
      if(widget.measureName == "light") return "Light Daily Average [Lux]";
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      if(widget.measureName == "moisture") return "Moisture Monthly Average [%RH]";
      if(widget.measureName == "humidity") return "Humidity Monthly Average [%RH]";
      if(widget.measureName == "temperature") return "Temperature Monthly Average [°C]";
      if(widget.measureName == "light") return "Light Monthly Average [Lux]";
    }
  }

  // String that is stamped on the screen if setSpots return no data
  String noDataMessage() {
    // Day mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      DateFormat dateFormat = DateFormat('EEEE dd MMM yyyy');
      return "No datas found for " + dateFormat.format(_startDate);
    }
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      if(_startDate.month == _endDate.month) {
        DateFormat dateFormat = DateFormat('MMMM yyyy');
        return "No datas found for " + dateFormat.format(_startDate);
      }
      else if(_startDate.month != _endDate.month) {
        DateFormat startDateFormat = DateFormat('MMMM');
        DateFormat endDateFormat = DateFormat('/MMMM yyyy');
        return "No datas found for " + startDateFormat.format(_startDate) + endDateFormat.format(_endDate);
      }
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      if(_startDate.year == _endDate.year) {
        DateFormat dateFormat = DateFormat('yyyy');
        return "No datas found for " + dateFormat.format(_startDate);
      }
      else if(_startDate.year != _endDate.year) {
        DateFormat startDateFormat = DateFormat('yyyy');
        DateFormat endDateFormat = DateFormat('/yyyy');
        return "No datas found for " + startDateFormat.format(_startDate) + endDateFormat.format(_endDate);
      }
    }
  }

  TextAlign getXAxisTitleAlignament() {
    // Day Mode
    if(_startDate.day == _endDate.day && _startDate.month == _endDate.month && _startDate.year == _endDate.year) {
      return TextAlign.left;
    }
    // Month Mode
    if(((_startDate.add(Duration(days: 31)).isAfter(_endDate) && _startDate.day != _endDate.day) || (_startDate.add(Duration(days: 31)).day == _endDate.day && _startDate.add(Duration(days: 31)).month == _endDate.month))){
      return TextAlign.center;
    }
    // Year Mode
    if(_startDate.add(Duration(days: 31)).isBefore(_endDate)){
      return TextAlign.center;
    }
  }

  List<HorizontalLine> infoLines() {
    if(widget.measureName == "moisture") {
      return [
        HorizontalLine(
          label: 
          HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: TextStyle(fontSize: 18, color: Colors.brown, fontWeight: FontWeight.bold),
            labelResolver: (HorizontalLine) {return "Dry";}
          ),
          y: 0,
          color: Colors.brown,
          strokeWidth: 3,
          dashArray: [15, 15],
        ),
        HorizontalLine(
          label: 
          HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: TextStyle(fontSize: 18, color: Colors.brown, fontWeight: FontWeight.bold),
            labelResolver: (HorizontalLine) {return "Wet";}
          ),
          y: 34.5,
          color: Colors.brown,
          strokeWidth: 3,
          dashArray: [15, 15],
        ),
        HorizontalLine(
          label: 
          HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: TextStyle(fontSize: 18, color: Colors.brown, fontWeight: FontWeight.bold),
            labelResolver: (HorizontalLine) {return "Very Wet";}
          ),
          y: 65.4,
          color: Colors.brown,
          strokeWidth: 3,
          dashArray: [15, 15],
        ),
      ];
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    return 
      ListView(
        children: [
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0, bottom: 20.0),
          child:  
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
              Container(
                decoration: 
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(width: 2.0, color: Colors.green),
                  ),
                  child:
                  GestureDetector(
                    onTap: () => getDate(date: _startDate, context: context, selection: 0),  
                    child:
                    Padding(padding: EdgeInsets.all(10.0),
                      child:
                      Row(children: <Widget>[
                        Text(
                          _dateFormatDisplay.format(_startDate),
                            style: 
                            TextStyle(
                              fontSize: 18.0,
                              color: Colors.green,
                            ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child:
                          Icon(
                            IconData(Icons.date_range.codePoint, fontFamily: 'MaterialIcons'),
                            color: Colors.green,
                          )
                        ),
                      ],)  
                    ),  
                  ),
                ),
                Container(
                  decoration:
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(width: 2.0, color: Colors.green)
                  ),  
                  child:
                  GestureDetector(
                    onTap: () => getDate(date: _endDate, context: context, selection: 1),  
                    child:
                    Padding(padding: EdgeInsets.all(10.0),
                      child:
                      Row(children: <Widget>[
                        Text(
                          _dateFormatDisplay.format(_endDate),
                          style: 
                          TextStyle(
                            fontSize: 18.0,
                            color: Colors.green,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child:
                          Icon(
                            IconData(Icons.date_range.codePoint, fontFamily: 'MaterialIcons'),
                            color: Colors.green,
                          )
                        ),
                      ],)  
                    ),  
                  ), 
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              padding: EdgeInsets.only(top: 20.0, right: 40.0, left: 10.0, bottom: 10.0),
              height: MediaQuery.of(context).size.height / 3 * 1.82,
              width: MediaQuery.of(context).size.width,
              decoration: 
                BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(width: 2.0, color: Colors.green),
                ),
              child:
              FutureBuilder(
                future: setSpots(), 
                builder:(context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Center(
                        child:
                        CircularProgressIndicator(backgroundColor: Colors.grey[850],)
                      );
                    case ConnectionState.done:
                      if(snapshot.data.isEmpty == true && _startDate.isAfter(_endDate) == false) {
                        return Center(
                          child: Text(
                            noDataMessage(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                        );
                      }
                      if(_startDate.isAfter(_endDate)) {
                        return Center(
                          child: Text(
                            "Left date must be before then right date",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                        );
                      }
                      else {
                        return LineChart(
                          LineChartData(
                            lineTouchData: 
                            LineTouchData(
                              //Set Indicator colors
                              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: Colors.brown,
                                      strokeWidth: 4
                                    ),
                                    FlDotData(
                                      show: true,
                                      dotSize: 8,
                                      strokeWidth: 4,
                                      getStrokeColor: (spot, percent, barData) => Colors.brown,
                                      getDotColor: (spot, percent, barData) {
                                        return Colors.green;
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: 
                              LineTouchTooltipData( 
                                tooltipBgColor: Colors.brown.withOpacity(0.8),
                                //Set text style in the cloud that shows value
                                getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    return LineTooltipItem(
                                      setInfoCloudText(lineBarSpot),
                                      //lineBarSpot.y.toString(),
                                      const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                                    );
                                  }).toList();
                                }
                              ),
                              touchCallback: (LineTouchResponse touchResponse) {},
                              handleBuiltInTouches: true,
                            ),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 12,
                                  textStyle: 
                                  TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  getTitles: (value) => setBottomTitles(value),
                                ),
                                leftTitles: SideTitles(
                                  reservedSize: 20.0,
                                  showTitles: true,
                                  textStyle: 
                                  TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  getTitles: (value) => setLeftTitles(value),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  bottom: BorderSide(
                                    color: Colors.brown,
                                    width: 3,
                                  ),
                                  left: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  right: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  top: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              minX: getMinX(),
                              maxX: getMaxX(),
                              maxY: getMaxY(),
                              minY: getMinY(),
                              extraLinesData: 
                              ExtraLinesData(horizontalLines: infoLines()),
                              lineBarsData: [
                              LineChartBarData(
                                spots: snapshot.data,
                                isCurved: false,
                                colors: [ Colors.green ],
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData( show: true ),
                                belowBarData: BarAreaData( show: false ),
                              )],
                              axisTitleData: 
                              FlAxisTitleData(
                                leftTitle: 
                                AxisTitle(
                                  showTitle: true,  
                                  margin: 10,
                                  titleText: getYAxisTitle(),
                                  textStyle: TextStyle(color: Colors.brown, fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center
                                ),
                                bottomTitle: 
                                AxisTitle(
                                  showTitle: true,
                                  margin: 10,
                                  titleText: getXAxisTitle(),
                                  textStyle: TextStyle(color: Colors.brown, fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: getXAxisTitleAlignament()
                                )
                              ),
                          )
                        );
                      }
                  }
                  
                }
              )
            ),
            ]
          ),
        ),
        ]
      );
  }
}
 