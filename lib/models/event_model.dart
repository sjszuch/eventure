class Event {
  final String title;
  final String description;
  final String author;
  final String image;
  final String date;
  final String time;
  final String location;

  Event({
    required this.title,
    required this.description,
    required this.author,
    required this.image,
    required this.date,
    required this.time,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'image': image,
      'date': date,
      'time': time,
      'location': location,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      author: map['author'] ?? '',
      image: map['image'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      location: map['location'] ?? '',
    );
  }
}
