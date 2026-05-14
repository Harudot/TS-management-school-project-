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
  final List<String> occupantIds;
  final RoomType type;
  final String waypointId;

  RoomDoc({
    required this.id,
    required this.number,
    required this.floor,
    required this.name,
    this.occupantIds = const [],
    this.type = RoomType.office,
    required this.waypointId,
  });

  factory RoomDoc.fromMap(String id, Map<String, dynamic> m) {
    // Read new shape, fall back gracefully to legacy single occupantId.
    final ids = (m['occupantIds'] as List?)?.cast<String>() ??
        (m['occupantId'] is String && (m['occupantId'] as String).isNotEmpty
            ? <String>[m['occupantId'] as String]
            : <String>[]);
    return RoomDoc(
      id: id,
      number: (m['number'] ?? '') as String,
      floor: (m['floor'] ?? 1) as int,
      name: (m['name'] ?? '') as String,
      occupantIds: ids,
      type: RoomType.parse(m['type'] as String?),
      waypointId: (m['waypointId'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'floor': floor,
        'name': name,
        'occupantIds': occupantIds,
        'type': type.name,
        'waypointId': waypointId,
      };

  RoomDoc copyWith({
    String? number,
    int? floor,
    String? name,
    List<String>? occupantIds,
    RoomType? type,
    String? waypointId,
  }) =>
      RoomDoc(
        id: id,
        number: number ?? this.number,
        floor: floor ?? this.floor,
        name: name ?? this.name,
        occupantIds: occupantIds ?? this.occupantIds,
        type: type ?? this.type,
        waypointId: waypointId ?? this.waypointId,
      );
}
