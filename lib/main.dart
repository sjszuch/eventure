import 'package:flutter/material.dart';
import 'pages/eventure_feed.dart'; // Make sure this path is correct
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
      home: EventureHome(), // this class must be in eventure_feed.dart
      routes: {'/create': (context) => CreatePostStart()},
    );
  }
}
