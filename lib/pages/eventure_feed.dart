import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:confetti/confetti.dart';

import '../services/saved_events_service.dart';
import 'saved_posts_page.dart';
import 'create_post_start.dart';

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
              child: _FlippableCard(
                frontImageUrl: flyerImageUrls[index],
                eventTitle: "Event Title ${index + 1}",
                author: "Author Name",
                description: flyerDescriptions[index],
                eventDate: flyerDates[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlippableCard extends StatefulWidget {
  final String frontImageUrl;
  final String eventTitle;
  final String author;
  final String description;
  final String eventDate;

  const _FlippableCard({
    required this.frontImageUrl,
    required this.eventTitle,
    required this.author,
    required this.description,
    required this.eventDate,
  });

  @override
  State<_FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<_FlippableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  double _dragStartValue = 0.0;
  bool isSaved = false;

  final savedService = SavedEventsService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
      value: 0,
    );
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    isSaved = savedService.isSaved(_toEvent());
  }

  Map<String, String> _toEvent() => {
    'title': widget.eventTitle,
    'date': widget.eventDate,
    'time': '7:00 PM',
    'description': widget.description,
    'image': widget.frontImageUrl,
    'author': widget.author,
  };

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    final shouldFlipForward = _controller.value < 0.5;
    HapticFeedback.mediumImpact();
    if (shouldFlipForward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartValue = _controller.value;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final dragAmount = delta / context.size!.width;
    _controller.value = (_controller.value - dragAmount).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    _toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = pi * _controller.value;
          final isBack = _controller.value >= 0.5;
          final transform =
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child:
                isBack
                    ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: _buildBack(context),
                    )
                    : _buildFront(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.frontImageUrl, fit: BoxFit.cover),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.eventTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.author,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          color: Color(0xFFFFF8E1),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "${widget.eventDate} @ 7:00 PM",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                "Highland Park",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.description,
                    style: TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "- ${widget.author}",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: -pi / 2,
                        emissionFrequency: 0.6,
                        numberOfParticles: 20,
                        maxBlastForce: 10,
                        minBlastForce: 5,
                        shouldLoop: false,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isSaved = !isSaved;
                              if (isSaved) {
                                savedService.save(_toEvent());
                                _confettiController.play();
                              } else {
                                savedService.unsave(_toEvent());
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      icon: Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        Share.share(
                          "Check out this event: ${widget.eventTitle}\nLink: https://eventure.app/event/123",
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.white),
                      onPressed: () {
                        final event = Event(
                          title: widget.eventTitle,
                          description: widget.description,
                          location: 'Event Location',
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(Duration(hours: 2)),
                        );
                        Add2Calendar.addEvent2Cal(event);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
