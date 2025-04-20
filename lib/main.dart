import 'package:flutter/material.dart';
import 'pages/eventure_feed.dart';
import 'pages/create_post_start.dart';

void main() {
  runApp(EventureApp());
}

class EventureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventureHome(),
      routes: {'/create': (context) => CreatePostStart()},
    );
  }
}
