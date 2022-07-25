import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import '../Services/searchSpotType.dart';
import '../api_url.dart';
import '../media_display.dart';
import '../model/spot_types_entity.dart';
import '../providers/checked_icons_provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50.0,
            ),
            Container(
              child: Text(
                "SEARCH",
                style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: SpotAPI.getData(),
                builder:
                    (context, AsyncSnapshot<List<SpotTypesData>> snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return listItem(context, snapshot.data[index]);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            "Could not load search options. Please try again later"));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
        floatingActionButton:
            Consumer<CheckedIconsProvider>(builder: (context, current, old) {
          if (current.list.isEmpty)
            return Container();
          else
            return RaisedButton(
              color: Color(0xFFF94E0D).withOpacity(0.8),
              textColor: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Apply Filters'),
                  SizedBox(width: 5),
                  Icon(Icons.search),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MediaDisplayPage()));
              },
            );
        }));
  }

  Widget listItem(BuildContext context, SpotTypesData spot) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "${spot.title}",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: spot.types.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1 / 1.15,
          ),
          itemBuilder: (BuildContext context, int index) {
            SpotTypesDataType type = spot.types[index];
            CheckedIconsProvider provider =
                Provider.of<CheckedIconsProvider>(context);
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    color: provider.isChecked(type.id)
                        ? Colors.black45.withOpacity(0.1)
                        : null,
                    child: Transform.scale(
                      scale: provider.isChecked(type.id) ? 0.9 : 1.0,
                      child: ListTile(
                        title: Image.network(
                            ApiUrl.web_image_url + "${type.icon}",
                            height: 70),
                        subtitle: Container(
                          height: 40,
                          child: AutoSizeText(
                            "${type.title}",
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            wrapWords: false,
                          ),
                        ),
                        onTap: () {
                          provider.toggle(type.id);
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: provider.isChecked(type.id),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.check, color: Color(0xFFF94E0D)),
                  ),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
