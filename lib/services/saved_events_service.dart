class SavedEventsService {
  static final SavedEventsService _instance = SavedEventsService._internal();

  factory SavedEventsService() => _instance;

  SavedEventsService._internal();

  final List<Map<String, String>> _savedEvents = [];

  List<Map<String, String>> get savedEvents => _savedEvents;

  void save(Map<String, String> event) {
    if (!_savedEvents.any((e) => e['title'] == event['title'])) {
      _savedEvents.add(event);
    }
  }

  void unsave(Map<String, String> event) {
    _savedEvents.removeWhere((e) => e['title'] == event['title']);
  }

  bool isSaved(Map<String, String> event) {
    return _savedEvents.any((e) => e['title'] == event['title']);
  }
}
