import 'package:cloud_firestore/cloud_firestore.dart';

const eventCategories = <String>[
  'general',
  'lecture',
  'workshop',
  'pitch',
  'career-fair',
];

class CampusEvent {
  final String id;
  final String title;
  final String description;
  final String buildingId;
  final int floor;
  final String? roomId;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final bool featured;
  final String? createdBy;

  CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.buildingId,
    required this.floor,
    this.roomId,
    required this.startTime,
    required this.endTime,
    this.category = 'general',
    this.featured = false,
    this.createdBy,
  });

  factory CampusEvent.fromMap(String id, Map<String, dynamic> m) => CampusEvent(
        id: id,
        title: (m['title'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        buildingId: (m['buildingId'] ?? '') as String,
        floor: (m['floor'] ?? 1) as int,
        roomId: m['roomId'] as String?,
        startTime: (m['startTime'] as Timestamp).toDate(),
        endTime: (m['endTime'] as Timestamp).toDate(),
        category: (m['category'] ?? 'general') as String,
        featured: (m['featured'] ?? false) as bool,
        createdBy: m['createdBy'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'buildingId': buildingId,
        'floor': floor,
        'roomId': roomId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'category': category,
        'featured': featured,
        'createdBy': createdBy,
      };

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
