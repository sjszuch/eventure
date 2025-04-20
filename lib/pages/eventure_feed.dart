// Updated EventureHome with shared FlippableEventCard widget
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'saved_posts_page.dart';
import 'create_post_start.dart';
import '../widgets/flippable_event_card.dart';

class EventureHome extends StatefulWidget {
  @override
  _EventureHomeState createState() => _EventureHomeState();
}

class _EventureHomeState extends State<EventureHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    EventureFeedPage(),
    Center(child: Text('Search')),
    Container(),
    SavedPostsPage(),
    Center(child: Text('Profile')),
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
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
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

class EventureFeedPage extends StatefulWidget {
  @override
  _EventureFeedPageState createState() => _EventureFeedPageState();
}

class _EventureFeedPageState extends State<EventureFeedPage> {
  final List<String> flyerImageUrls = [
    'https://images.unsplash.com/photo-1551963831-b3b1ca40c98e',
    'https://images.unsplash.com/photo-1522770179533-24471fcdba45',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
  ];

  final List<String> flyerDescriptions = [
    "This is an epic community gathering with food, music, and games. Happening this Saturday from 12–6 PM at Highland Park!",
    "Join us for an unforgettable night of jazz with local legends. Doors open at 7PM. BYOB!",
    "Art Walk returns! Explore over 40 local artists, vendors, and performers along Liberty Avenue. Family friendly and free to attend.",
  ];

  final List<String> flyerDates = [
    "April 30, 2025",
    "May 5, 2025",
    "May 12, 2025",
  ];

  final List<String> flyerLocations = [
    "Highland Park",
    "Downtown Jazz Club",
    "Liberty Avenue",
  ];

  Color _backgroundColor = Colors.black;
  PageController _pageController = PageController(viewportFraction: 0.92);
  Map<int, Color> _cachedColors = {};

  @override
  void initState() {
    super.initState();
    _precacheAllImages().then((_) {
      _updateBackgroundColor(0);
    });
  }

  Future<void> _precacheAllImages() async {
    for (var url in flyerImageUrls) {
      await precacheImage(NetworkImage(url), context);
    }
  }

  Future<void> _updateBackgroundColor(int index) async {
    if (_cachedColors.containsKey(index)) {
      setState(() {
        _backgroundColor = _cachedColors[index]!;
      });
      return;
    }

    try {
      final imageProvider = NetworkImage(flyerImageUrls[index]);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: Size(200, 300),
      );
      final color = paletteGenerator.dominantColor?.color ?? Colors.black;
      _cachedColors[index] = color;
      setState(() {
        _backgroundColor = color;
      });
    } catch (e) {
      print('Error generating palette: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: flyerImageUrls.length,
        onPageChanged: (index) {
          _updateBackgroundColor(index);
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: FlippableEventCard(
                event: {
                  'image': flyerImageUrls[index],
                  'title': "Event Title ${index + 1}",
                  'author': "Author Name",
                  'description': flyerDescriptions[index],
                  'date': flyerDates[index],
                  'time': '7:00 PM',
                  'location': flyerLocations[index],
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
