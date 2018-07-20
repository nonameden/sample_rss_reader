import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sample_rss_reader/rss_reader.dart';
import 'package:webfeed/webfeed.dart';

class PlatformSpecificApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android)
      return _buildMaterialApp();
    else
      return _buildCupertinoApp();
  }

  Widget _buildMaterialApp() {
    return new MaterialApp(
      title: 'Rss reader',
      theme: new ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: new MyHomePage(title: 'Rss reader'),
    );
  }

  Widget _buildCupertinoApp() {
    return new CupertinoApp(
      title: 'Rss reader',
      color: Colors.purple,
      home: new MyHomePage(title: 'Rss reader'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<RssFeed>(
      future: getFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _showList(snapshot.data);
        } else if (snapshot.hasError) {
          return _showError();
        } else {
          return _showProgress();
        }
      },
    );

    if (Theme.of(context).platform == TargetPlatform.android) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: body,
      );
    } else {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
        ),
        child: body,
      );
    }
  }

  Widget _showList(RssFeed rss) {
    return Material(
      child: ListView.builder(
        itemCount: rss.items.length,
        itemBuilder: (context, index) {
          final rssItem = rss.items[index];
          final imageUrl = rssItem.content.images?.first;
          return ListTile(
            onTap: () {},
            title: Text(rssItem.title),
            subtitle: Text(rssItem.pubDate),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Container(
                width: 64.0,
                height: 64.0,
                child: imageUrl == null
                    ? null
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showError() {
    return Center(
      child: Text("Error has occured"),
    );
  }

  Widget _showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
