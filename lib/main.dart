import 'package:flutter/material.dart';
import 'pages/eventure_feed.dart';
import 'pages/create_post_start.dart';
import 'pages/saved_posts_page.dart';

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

class EventureHome extends StatefulWidget {
  @override
  _EventureHomeState createState() => _EventureHomeState();
}

class _EventureHomeState extends State<EventureHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    EventureFeedPage(),
    Center(child: Text("Search")),
    Container(), // Create is handled separately
    SavedPostsPage(),
    Center(child: Text("Profile")),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreatePostStart()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Eventure'), centerTitle: true),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
