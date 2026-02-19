import 'package:url_launcher/url_launcher.dart';

/// Google Calendar URL scheme service for adding lucky days
class GoogleCalendarService {
  GoogleCalendarService._();

  /// Open Google Calendar in browser with pre-filled event
  static Future<void> addEvent({
    required String title,
    required DateTime date,
    String? description,
  }) async {
    final url = createEventUrl(
      title: title,
      date: date,
      description: description,
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// Generate a Google Calendar URL for adding an event
  static Uri createEventUrl({
    required String title,
    required DateTime date,
    String? description,
  }) {
    final dateStr = _formatDate(date);
    final nextDay = _formatDate(date.add(const Duration(days: 1)));

    final params = <String, String>{
      'action': 'TEMPLATE',
      'text': title,
      'dates': '$dateStr/$nextDay',
    };
    if (description != null) {
      params['details'] = description;
    }

    return Uri.https('calendar.google.com', '/calendar/render', params);
  }

  static String _formatDate(DateTime d) {
    return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }
}
