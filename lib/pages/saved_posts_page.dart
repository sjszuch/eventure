import 'dart:math';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/saved_events_service.dart';

class SavedPostsPage extends StatefulWidget {
  @override
  _SavedPostsPageState createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  Map<String, String>? selectedEvent;

  void _openFlyer(Map<String, String> event) {
    setState(() {
      selectedEvent = event;
    });
  }

  void _closeFlyer() {
    setState(() {
      selectedEvent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedEvents = SavedEventsService().savedEvents;

    return Scaffold(
      appBar: AppBar(title: Text('Saved Events')),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: savedEvents.length,
            itemBuilder: (context, index) {
              final event = savedEvents[index];
              return GestureDetector(
                onTap: () => _openFlyer(event),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('${event['date']} @ ${event['time']}'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                final e = Event(
                                  title: event['title']!,
                                  description: event['description']!,
                                  location: 'Event Location',
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now().add(
                                    Duration(hours: 2),
                                  ),
                                );
                                Add2Calendar.addEvent2Cal(e);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                Share.share(
                                  'Check out this event: ${event['title']}\nLink: https://eventure.app/event/123',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (selectedEvent != null) ...[
            GestureDetector(
              onTap: _closeFlyer,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              color: Color(0xFFFFF8E1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    selectedEvent!['image']!,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedEvent!['title']!,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '${selectedEvent!['date']} @ ${selectedEvent!['time']}',
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Highland Park',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          selectedEvent!['description']!,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '- ${selectedEvent!['author']}',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _closeFlyer,
                          child: CircleAvatar(
                            backgroundColor: Colors.black87,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
