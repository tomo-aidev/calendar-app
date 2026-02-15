import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/anniversary_event.dart';
import '../services/storage_service.dart';

final anniversaryProvider =
    StateNotifierProvider<AnniversaryNotifier, List<AnniversaryEvent>>((ref) {
  return AnniversaryNotifier();
});

class AnniversaryNotifier extends StateNotifier<List<AnniversaryEvent>> {
  static const _uuid = Uuid();
  static const _boxKey = 'anniversaries';

  AnniversaryNotifier() : super([]);

  void loadAnniversaries() {
    try {
      final storage = StorageService.instance;
      final dataList = storage.getSetting<List>(_boxKey);
      if (dataList != null) {
        state = dataList
            .map((d) => _fromMap(Map<String, dynamic>.from(d as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load anniversaries: $e');
      state = [];
    }
  }

  List<AnniversaryEvent> getAnniversariesForDate(DateTime date) {
    return state.where((a) {
      if (!a.showOnCalendar) return false;
      if (a.showEveryYear) {
        return a.date.month == date.month && a.date.day == date.day;
      }
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList();
  }

  Future<void> addAnniversary({
    required DateTime date,
    required String personName,
    required AnniversaryType type,
    String? customTypeName,
    String? memo,
    bool showEveryYear = true,
    bool showOnCalendar = true,
  }) async {
    final now = DateTime.now();
    final event = AnniversaryEvent(
      id: _uuid.v4(),
      date: date,
      personName: personName,
      type: type,
      customTypeName: customTypeName,
      memo: memo,
      showEveryYear: showEveryYear,
      showOnCalendar: showOnCalendar,
      createdAt: now,
      updatedAt: now,
    );

    state = [...state, event];
    await _saveAll();
  }

  Future<void> updateAnniversary(AnniversaryEvent event) async {
    final updated = event.copyWith(updatedAt: DateTime.now());
    state = [
      for (final e in state)
        if (e.id == event.id) updated else e,
    ];
    await _saveAll();
  }

  Future<void> deleteAnniversary(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveAll();
  }

  Future<void> _saveAll() async {
    final data = state.map((e) => _toMap(e)).toList();
    await StorageService.instance.saveSetting(_boxKey, data);
  }

  Map<String, dynamic> _toMap(AnniversaryEvent event) {
    return {
      'id': event.id,
      'date': event.date.toIso8601String(),
      'personName': event.personName,
      'type': event.type.index,
      'customTypeName': event.customTypeName,
      'memo': event.memo,
      'showEveryYear': event.showEveryYear,
      'showOnCalendar': event.showOnCalendar,
      'createdAt': event.createdAt.toIso8601String(),
      'updatedAt': event.updatedAt.toIso8601String(),
    };
  }

  AnniversaryEvent _fromMap(Map<String, dynamic> data) {
    return AnniversaryEvent(
      id: data['id'] as String,
      date: DateTime.parse(data['date'] as String),
      personName: data['personName'] as String,
      type: AnniversaryType.values[data['type'] as int? ?? 0],
      customTypeName: data['customTypeName'] as String?,
      memo: data['memo'] as String?,
      showEveryYear: data['showEveryYear'] as bool? ?? true,
      showOnCalendar: data['showOnCalendar'] as bool? ?? true,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
