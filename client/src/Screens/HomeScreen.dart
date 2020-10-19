import 'package:flutter/material.dart';
import 'package:plant_monitor/Widgets/PlantPreviewWidget.dart';
import 'package:plant_monitor/Pages/HomeDrawer.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/';

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget _plant0PreviewWidget;
  //GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _plant0PreviewWidget = PlantPreviewWidget();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title:
          Text("Plant Monitor",
            style: TextStyle(color: Colors.black87),
          ),
          leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
            color: Colors.green,),
          onPressed: () => {},
          ),  
          iconTheme: IconThemeData(color: Colors.grey[850]),
        ),
        backgroundColor: Colors.grey[850],
        endDrawer: HomeDrawer(),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: 
            Text(
              "YOUR PLANTS",
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 16.0 ,color: Colors.green),
            ),
          ),
          Expanded(
            child: 
            CustomRefreshIndicator( 
              //key: _refreshIndicatorKey,
              //color: Colors.grey[850],
              //backgroundColor: Colors.green,
              onRefresh: () => _refreshPlants(),
              child:ListView(
                scrollDirection: Axis.vertical, 
                children: [
                  _plant0PreviewWidget
                ]
              ),
              builder: ( BuildContext context, Widget child, IndicatorController _indicatorController) { 
              return AnimatedBuilder(
                animation: _indicatorController,
                builder: (BuildContext context, _) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: 
                  <Widget>[
                    if (!_indicatorController.isIdle)
                      Positioned(
                        top: 35.0 * _indicatorController.value,
                        child: 
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: 
                          CircularProgressIndicator( value: (!_indicatorController.isLoading ? _indicatorController.value.clamp(0.0, 1.0) : null )),
                        ),
                      ),
                    // Move listView down
                    Transform.translate(
                      offset: Offset(0, 100.0 * _indicatorController.value),
                      child: child,
                    ),
                  ],
                );
                }
              );
              }
            ),
          ),
        ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.grey[850],),
          onPressed: () => {},
        ),
      )
    );
  }

   Future<void> _refreshPlants() async {
    Widget plant0PreviewWidget = PlantPreviewWidget();
    setState(() => _plant0PreviewWidget = plant0PreviewWidget);
    return;
  }
}