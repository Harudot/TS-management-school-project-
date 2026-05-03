class Building {
  final String id;
  final String name;
  final String address;
  final String? photoUrl;
  final String? qrCode;
  final int floorCount;
  final List<String> companies;

  Building({
    required this.id,
    required this.name,
    required this.address,
    this.photoUrl,
    this.qrCode,
    this.floorCount = 1,
    this.companies = const [],
  });

  factory Building.fromMap(String id, Map<String, dynamic> m) => Building(
        id: id,
        name: (m['name'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
        qrCode: m['qrCode'] as String?,
        floorCount: (m['floorCount'] ?? 1) as int,
        companies: ((m['companies'] ?? <dynamic>[]) as List).cast<String>(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'photoUrl': photoUrl,
        'qrCode': qrCode,
        'floorCount': floorCount,
        'companies': companies,
      };
}

class FloorDoc {
  final int number;
  final String? floorPlanUrl;
  final double width;
  final double height;

  FloorDoc({
    required this.number,
    this.floorPlanUrl,
    this.width = 1000,
    this.height = 700,
  });

  factory FloorDoc.fromMap(int number, Map<String, dynamic> m) => FloorDoc(
        number: number,
        floorPlanUrl: m['floorPlanUrl'] as String?,
        width: (m['width'] ?? 1000).toDouble(),
        height: (m['height'] ?? 700).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'floorPlanUrl': floorPlanUrl,
        'width': width,
        'height': height,
      };
}
