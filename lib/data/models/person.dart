class Person {
  final String id;
  final String name;
  final String role;
  final String department;
  final String? photoUrl;
  final String buildingId;
  final String? roomId;
  final String? contact;

  Person({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    this.photoUrl,
    required this.buildingId,
    this.roomId,
    this.contact,
  });

  factory Person.fromMap(String id, Map<String, dynamic> m) => Person(
        id: id,
        name: (m['name'] ?? '') as String,
        role: (m['role'] ?? '') as String,
        department: (m['department'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
        buildingId: (m['buildingId'] ?? '') as String,
        roomId: m['roomId'] as String?,
        contact: m['contact'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'department': department,
        'photoUrl': photoUrl,
        'buildingId': buildingId,
        'roomId': roomId,
        'contact': contact,
      };
}
