import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoNavigationBar;
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

class MixedApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MixedAppState createState() {
    return MixedAppState();
  }
}

class MixedAppState extends State<MixedApp> {
  TargetPlatform _platform;

  @override
  void initState() {
    super.initState();
    _platform = defaultTargetPlatform;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rss news',
      theme: new ThemeData(
        platform: _platform,
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(
        title: 'Rss news',
        platform: _platform,
        onPlatformChange: _onPlatformChange,
      ),
    );
  }

  void _onPlatformChange(TargetPlatform platform) {
    setState(() {
      _platform = platform;
    });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.platform,
    this.onPlatformChange,
  }) : super(key: key);

  final String title;
  final TargetPlatform platform;
  final ValueChanged<TargetPlatform> onPlatformChange;

  @override
  _MyHomePageState createState() => _MyHomePageState(platform);
}

class _MyHomePageState extends State<MyHomePage> {
  TargetPlatform _platform;
  bool get isCupertino => _platform == TargetPlatform.iOS;

  _MyHomePageState(this._platform);

  @override
  Widget build(BuildContext context) {
    Widget appBar;
    if (isCupertino)
      appBar = CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: _buildPlatformSwitch(),
      );
    else
      appBar = AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          _buildPlatformSwitch(),
        ],
      );

    return new Scaffold(
      appBar: appBar,
      body: FutureBuilder<RssFeed>(
        future: getRss(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildList(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Container(color: Colors.red);
          } else {
            return Container(color: Colors.yellow);
          }
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, RssFeed feed) {
    final children = feed.items.map((item) {
      final imageUrl = item.content.images.first;
      return ListTile(
        title: Text(item.title),
        subtitle: Text(item.pubDate),
        leading: NewsImage(imageUrl: imageUrl),
        onTap: () => _showSnackbar(item.title),
      );
    }).toList();
    return ListView(
      children: children,
    );
  }

  void _showSnackbar(String title) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("You pressed: $title"),
      ),
    );
  }

  Widget _buildPlatformSwitch() {
    return Switch(
      value: isCupertino,
      onChanged: (value) {
        setState(() {
          _platform = value ? TargetPlatform.iOS : TargetPlatform.android;
        });
        widget.onPlatformChange(_platform);
      },
    );
  }
}

class NewsImage extends StatelessWidget {
  const NewsImage({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      elevation: 6.0,
      child: Container(
        width: 64.0,
        height: 64.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

Future<RssFeed> getRss() {
  return http.Client()
      .get("https://www.ccn.com/yahoo-rss-feed/")
      .then((response) => RssFeed.parse(response.body));
}
