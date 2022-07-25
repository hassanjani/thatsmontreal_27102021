import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Stations.dart';
import '../helper/locolizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
class MontrealStationPage extends StatefulWidget {
  @override
  _MontrealStationPageState createState() => _MontrealStationPageState();
}

class _MontrealStationPageState extends State<MontrealStationPage> {
  List<Color> stationColor = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];
  final List<Stations> station = [
    Stations(
      stationsColor: Colors.orange,
      strMetroName: "orange_subway_line",
      stationCount: 30,
    ),
    Stations(
      stationsColor: Colors.blue,
      strMetroName: "blue_subway_line",
      stationCount: 12,
    ),
    Stations(
      stationsColor: Colors.green,
      strMetroName: "green_subway_line",
      stationCount: 25,
    ),
    Stations(
      stationsColor: Colors.yellow,
      strMetroName: "yellow_subway_line",
      stationCount: 2,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: Text(
      //       AppLocalizations.of(context).trans('montreal_station'),
      //     ),
      //     backgroundColor: Colors.black),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width*0.1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            chooseMetroStation(),
            SizedBox(
              height: 5,
            ),
            Divider(
              color: Color(0xFFF94E0D),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(
              height: 15,
            ),
            staggeredStations(),
          ],
        ),
      ),
    );
  }
  Widget chooseMetroStation(){
    return Text(
      AppLocalizations.of(context).trans('choose_a')+" "+AppLocalizations.of(context).trans('metro_station'),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFF94E0D),
        fontSize: 20.0,
        fontWeight: FontWeight.w900,
      ),
    );
  }
  Widget staggeredStations(){
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: station.length,
      mainAxisSpacing: 30.0,
      shrinkWrap: true,
      crossAxisSpacing: 7.0,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => station[index]));
        },
        child: Container(
          height: 140,
            decoration: BoxDecoration(
                color: stationColor[index],
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    "assets/logo_new.png"
                  ),
                ),
                 Spacer(),
                 Container(
                   height: 50,
                   alignment: Alignment.center,
                   margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                   padding: EdgeInsets.only(left: 10, right: 10),
                   decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(10)
                   ),
                   child: Text(
                       AppLocalizations.of(context).trans('${station[index].strMetroName}'),
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Colors.black,
                       fontSize: 17.0,
                       fontWeight: FontWeight.w900,
                     ),
                   ),
                 ),
              ],
            )
        ),
      ),
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }
  Widget listTileStations(){
   return ListView.builder(
      itemCount: station.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => station[index]));
            },
            title: Text(AppLocalizations.of(context).trans('${station[index].strMetroName}')),
          ),
        );
      },
    );
  }
}
