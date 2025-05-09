import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/saved_events_service.dart';
import '../widgets/flippable_event_card.dart';

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
                                  location:
                                      event['location'] ?? 'Event Location',
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
                                  '''Check out this event: ${event['title']}
Link: https://eventure.app/event/123''',
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
                        onTap: () {}, // prevent tap propagation
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: FlippableEventCard(
                            key: ValueKey(selectedEvent!['image']),
                            event: selectedEvent!,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 30,
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
