import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:webfeed/webfeed.dart';

Future<RssFeed> getFeed() {
  return http
      .get("https://www.ccn.com/yahoo-rss-feed/")
      .then((response) => RssFeed.parse(response.body));
}
