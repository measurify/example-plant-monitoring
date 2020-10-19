import 'package:flutter/material.dart';
import 'package:plant_monitor/Pages/HomeDrawer.dart';
import 'package:plant_monitor/Pages/PlantTabPage.dart';
import 'package:plant_monitor/Widgets/DialogChangePlantName.dart';
import 'package:plant_monitor/Utils/StoreData.dart';

class PlantScreen extends StatefulWidget {
  static const String routeName = '/plantScreen';


  PlantScreen({Key key}) : super(key: key);

  @override
  _PlantScreenState createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> with SingleTickerProviderStateMixin {

  TabController _tabController;
  String _plantName;
  bool _newPlantName = false;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      
    _plantName = ModalRoute.of(context).settings.arguments;
    PlantTabPage plantTabMoisture =  new PlantTabPage(measureName: "moisture");
    PlantTabPage plantTabHumidity = new PlantTabPage(measureName: "humidity");
    PlantTabPage plantTabTemperature = new PlantTabPage(measureName:"temperature");
    PlantTabPage plantTabLight = new PlantTabPage(measureName: "light");

    return SafeArea(
      child:Scaffold(
        appBar: 
        PreferredSize(
          preferredSize: Size.fromHeight(135.0),
          child:
          AppBar( 
            title: Row(
              children: [
              FutureBuilder(
                future: _loadPlantName(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Text("        ", style: TextStyle(color: Colors.green));
                    case ConnectionState.done:
                    if(_newPlantName == false) {
                    return Text(_plantName,
                      style: TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    );
                    }
                    else if(_newPlantName == true) {
                      _plantName = snapshot.data;
                      _newPlantName = false;
                      return Text(_plantName,
                        style: TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                      );
                    }
                  }
                }
              ),
              IconButton(
                padding: EdgeInsets.only(left: 10),
                icon: Icon(Icons.border_color,
                color: Colors.grey[850],),
                //With then and set state, it reloads the page when dialog is closed
                onPressed: () => DialogChangePlantName(_plantName, context).dialogShow().then((_) => setState(() {}))
              ),
              ]
            ),
            iconTheme: IconThemeData(color: Colors.grey[850]),  
            leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
              color: Colors.grey[850],),
            onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorPadding: EdgeInsets.only(bottom: 32.0),
              indicatorColor: Colors.black87,
              indicatorWeight: 4.0,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.opacity, color: Colors.grey[850], size: 30.0,),
                  child: 
                  Text(
                    "Moisture",
                    style: TextStyle(
                      color: Colors.black87)
                  ),
                ),
                Tab(
                  //icon: Icon(Icons.cloud_queue),
                  icon: Icon(Icons.filter_drama, color: Colors.grey[850], size: 30.0,),
                  child: 
                  Text(
                    "Humidity",
                    style: TextStyle(
                      color: Colors.black87)
                  ),
                ),
                Tab(
                  icon: Icon(Icons.colorize, color: Colors.grey[850], size: 30.0,),
                  child: 
                  Text(
                    "Temperature",
                    style: TextStyle(
                      color: Colors.black87)
                  ),
                ),
                Tab(
                  icon: Icon(Icons.wb_sunny, color: Colors.grey[850], size: 30.0,),
                  child: 
                  Text(
                    "Light",
                    style: TextStyle(
                      color: Colors.black87)
                  ),
                ), 
              ],
            ),
          ),  
        ),  
        endDrawer: HomeDrawer(),
        backgroundColor: Colors.grey[850],
        body: 
        TabBarView(
          controller: _tabController,
          children: <Widget>[
            plantTabMoisture,
            plantTabHumidity,
            plantTabTemperature,
            plantTabLight,
          ],
        ),
      ),  
    );
  }

  Future<String> _loadPlantName() async {
    _newPlantName = true;
    return await StoreData().loadStringAsynchronous(key: "plant0Name");
  }
}