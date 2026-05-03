enum RoomType {
  office,
  meeting,
  classroom,
  lab,
  reception,
  cafeteria,
  restroom,
  storage,
  other;

  static RoomType parse(String? v) =>
      RoomType.values.firstWhere((e) => e.name == v, orElse: () => RoomType.other);
}

class RoomDoc {
  final String id;
  final String number;
  final int floor;
  final String name;
  final String? occupantId;
  final RoomType type;
  final String waypointId;

  RoomDoc({
    required this.id,
    required this.number,
    required this.floor,
    required this.name,
    this.occupantId,
    this.type = RoomType.office,
    required this.waypointId,
  });

  factory RoomDoc.fromMap(String id, Map<String, dynamic> m) => RoomDoc(
        id: id,
        number: (m['number'] ?? '') as String,
        floor: (m['floor'] ?? 1) as int,
        name: (m['name'] ?? '') as String,
        occupantId: m['occupantId'] as String?,
        type: RoomType.parse(m['type'] as String?),
        waypointId: (m['waypointId'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'number': number,
        'floor': floor,
        'name': name,
        'occupantId': occupantId,
        'type': type.name,
        'waypointId': waypointId,
      };
}
