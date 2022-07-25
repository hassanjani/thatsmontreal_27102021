import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:thats_montreal/helper/locolizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingControllerUrl = new TextEditingController();
  TextEditingController textEditingControllerId = new TextEditingController();

  @override
  initState() {
    super.initState();
  }

  void playYoutubeVideo() {
    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "AIzaSyDvZIHkuGXv5Wo2Ww1973wI0eiQ7c7guhk",
      videoUrl: "https://www.youtube.com/watch?v=wgTBLj7rMPM",
    );
  }

  void playYoutubeVideoEdit() {
    FlutterYoutube.onVideoEnded.listen((onData) {
      //perform your action when video playing is done
    });

    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "AIzaSyDvZIHkuGXv5Wo2Ww1973wI0eiQ7c7guhk",
      videoUrl: textEditingControllerUrl.text,
    );
  }

  void playYoutubeVideoIdEdit() {
    FlutterYoutube.onVideoEnded.listen((onData) {
      //perform your action when video playing is done
    });

    FlutterYoutube.playYoutubeVideoById(
      apiKey: "AIzaSyDvZIHkuGXv5Wo2Ww1973wI0eiQ7c7guhk",
      videoId: textEditingControllerId.text,
    );
  }

  void playYoutubeVideoIdEditAuto() {
    FlutterYoutube.onVideoEnded.listen((onData) {
      //perform your action when video playing is done
    });

    FlutterYoutube.playYoutubeVideoById(
        apiKey: "AIzaSyDvZIHkuGXv5Wo2Ww1973wI0eiQ7c7guhk",
        videoId: textEditingControllerId.text,
        autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(AppLocalizations.of(context).trans('youtube_player')),
        ),
        body: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new TextField(
                  controller: textEditingControllerUrl,
                  decoration:
                      new InputDecoration(labelText: AppLocalizations.of(context).trans('enter_youtube_url')),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text(AppLocalizations.of(context).trans('play_video_by_url')),
                    onPressed: playYoutubeVideoEdit),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text(AppLocalizations.of(context).trans('play_default_video')),
                    onPressed: playYoutubeVideo),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new TextField(
                  controller: textEditingControllerId,
                  decoration: new InputDecoration(
                      labelText: AppLocalizations.of(context).trans('youtube_video_id')+" (wgTBLj7rMPM)"),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text(AppLocalizations.of(context).trans('play_video_by_id')),
                    onPressed: playYoutubeVideoIdEdit),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text(AppLocalizations.of(context).trans('auto_play_video_by_id')),
                    onPressed: playYoutubeVideoIdEditAuto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

