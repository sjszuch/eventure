import 'dart:math';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/saved_events_service.dart';

class FlippableEventCard extends StatefulWidget {
  final Map<String, String> event;

  const FlippableEventCard({Key? key, required this.event}) : super(key: key);

  @override
  State<FlippableEventCard> createState() => _FlippableEventCardState();
}

class _FlippableEventCardState extends State<FlippableEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  final savedService = SavedEventsService();
  bool isSaved = false;
  double dragStartX = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
      value: 0,
    );
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    isSaved = savedService.isSaved(widget.event);
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleCard({bool? flipForward}) {
    final shouldFlipForward = flipForward ?? (_controller.value < 0.5);
    HapticFeedback.mediumImpact();
    if (shouldFlipForward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    dragStartX = details.globalPosition.dx;
  }

  void _handleDragEnd(DragEndDetails details) {
    final dragEndX = details.velocity.pixelsPerSecond.dx;
    final velocityThreshold = 300;
    final isSwipeRight = dragEndX > velocityThreshold;
    final isSwipeLeft = dragEndX < -velocityThreshold;

    if (isSwipeLeft || isSwipeRight) {
      _toggleCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      onHorizontalDragStart: _handleDragStart,
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
            Image.network(widget.event['image']!, fit: BoxFit.cover),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event['title']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.event['author']!,
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
                widget.event['title']!,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "${widget.event['date']} @ ${widget.event['time']}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                widget.event['location']!,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.event['description']!,
                    style: TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "- ${widget.event['author']!}",
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
                                savedService.save(widget.event);
                                _confettiController.play();
                              } else {
                                savedService.unsave(widget.event);
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
                          '''Check out this event: ${widget.event['title']}
Link: https://eventure.app/event/123''',
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
                          title: widget.event['title']!,
                          description: widget.event['description']!,
                          location: widget.event['location']!,
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
