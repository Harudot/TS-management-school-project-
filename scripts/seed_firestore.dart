// Seed script for the Smart Campus dummy building.
//
// USAGE (run once, then comment out the call in main.dart or remove this entry):
//   1. Add to pubspec.yaml under dev_dependencies:
//        firebase_core: ^3.6.0
//        cloud_firestore: ^5.4.4
//   2. Temporarily wire `await seedFirestore();` into main.dart after initFirebase().
//   3. flutter run --dart-define=SEED=true
//   4. After running once, remove the seed call.
//
// Or invoke seedFirestore() from a hidden admin button.

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  const buildingId = 'main';

  // ---- Building ----
  await db.collection('buildings').doc(buildingId).set({
    'name': 'Main Campus Building',
    'address': '1 University Way',
    'photoUrl': null,
    'qrCode': 'campus://$buildingId',
    'floorCount': 4,
    'companies': ['Computer Science', 'Mathematics', 'Library', 'Admin'],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // ---- Floors ----
  for (var i = 1; i <= 4; i++) {
    await db
        .collection('buildings')
        .doc(buildingId)
        .collection('floors')
        .doc('$i')
        .set({
      'floorPlanUrl': null, // Replace with Storage URL after upload
      'width': 1000,
      'height': 700,
    });
  }

  // ---- Rooms (5 per floor) ----
  for (var f = 1; f <= 4; f++) {
    for (var n = 1; n <= 5; n++) {
      final roomNum = '${f}0$n';
      await db
          .collection('buildings')
          .doc(buildingId)
          .collection('rooms')
          .doc('room_$roomNum')
          .set({
        'number': roomNum,
        'floor': f,
        'name': 'Room $roomNum',
        'occupantId': null,
        'type': n == 1 ? 'reception' : (n == 5 ? 'lab' : 'office'),
        'waypointId': 'wp_${f}_room$n',
      });
    }
  }

  // ---- People ----
  final people = [
    {
      'id': 'p_alice',
      'name': 'Alice Chen',
      'role': 'Professor',
      'department': 'Computer Science',
      'buildingId': buildingId,
      'roomId': 'room_304',
      'contact': 'alice@campus.edu',
      'photoUrl': null,
    },
    {
      'id': 'p_bob',
      'name': 'Bob Martin',
      'role': 'Lecturer',
      'department': 'Mathematics',
      'buildingId': buildingId,
      'roomId': 'room_201',
      'contact': 'bob@campus.edu',
      'photoUrl': null,
    },
    {
      'id': 'p_carol',
      'name': 'Carol Davies',
      'role': 'Librarian',
      'department': 'Library',
      'buildingId': buildingId,
      'roomId': 'room_101',
      'contact': 'carol@campus.edu',
      'photoUrl': null,
    },
    {
      'id': 'p_dan',
      'name': 'Dan Park',
      'role': 'Admin',
      'department': 'Admin',
      'buildingId': buildingId,
      'roomId': 'room_405',
      'contact': 'dan@campus.edu',
      'photoUrl': null,
    },
    {
      'id': 'p_eve',
      'name': 'Eve Johnson',
      'role': 'PhD candidate',
      'department': 'Computer Science',
      'buildingId': buildingId,
      'roomId': 'room_305',
      'contact': 'eve@campus.edu',
      'photoUrl': null,
    },
  ];
  for (final p in people) {
    final id = p.remove('id') as String;
    await db.collection('people').doc(id).set(p);
  }

  // ---- Events ----
  final now = DateTime.now();
  final hackathonStart = DateTime(now.year, now.month, now.day, 14);
  final hackathonEnd = DateTime(now.year, now.month, now.day, 18);
  await db.collection('events').doc('e_hackathon').set({
    'title': 'Hackathon — Open to all',
    'description': '24-hour build session. Snacks provided.',
    'buildingId': buildingId,
    'floor': 4,
    'roomId': 'room_304',
    'startTime': Timestamp.fromDate(hackathonStart),
    'endTime': Timestamp.fromDate(hackathonEnd),
    'category': 'event',
    'createdBy': 'seed',
  });
  await db.collection('events').doc('e_lecture').set({
    'title': 'Guest lecture: Distributed Systems',
    'description': 'Auditorium hosts visiting researcher.',
    'buildingId': buildingId,
    'floor': 2,
    'roomId': 'room_201',
    'startTime':
        Timestamp.fromDate(now.add(const Duration(days: 1, hours: 10))),
    'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 12))),
    'category': 'lecture',
    'createdBy': 'seed',
  });

  // ---- Navigation graph ----
  // Hand-authored node grid: each floor has 5 room nodes + a corridor + stairs.
  final nodes = <Map<String, dynamic>>[];
  final edges = <Map<String, dynamic>>[];

  for (var f = 1; f <= 4; f++) {
    nodes.add({'id': 'wp_${f}_corridor', 'floor': f, 'x': 500.0, 'y': 350.0, 'type': 'junction', 'label': 'Corridor F$f'});
    nodes.add({'id': 'wp_${f}_stairs', 'floor': f, 'x': 900.0, 'y': 350.0, 'type': 'stairs', 'label': 'Stairs F$f'});
    for (var n = 1; n <= 5; n++) {
      nodes.add({
        'id': 'wp_${f}_room$n',
        'floor': f,
        'x': 100.0 + (n - 1) * 180.0,
        'y': 150.0,
        'type': 'room',
        'label': 'Room ${f}0$n',
      });
      edges.add({
        'from': 'wp_${f}_room$n',
        'to': 'wp_${f}_corridor',
        'weight': 8.0,
        'instruction': 'Walk to the corridor',
      });
    }
    edges.add({
      'from': 'wp_${f}_corridor',
      'to': 'wp_${f}_stairs',
      'weight': 6.0,
      'instruction': 'Walk to the stairwell',
    });
  }

  // Entrance + cafeteria + elevator on F1
  nodes.add({'id': 'wp_1_entrance', 'floor': 1, 'x': 500.0, 'y': 600.0, 'type': 'entrance', 'label': 'Main Entrance'});
  nodes.add({'id': 'wp_1_cafeteria', 'floor': 1, 'x': 100.0, 'y': 600.0, 'type': 'junction', 'label': 'Cafeteria'});
  nodes.add({'id': 'wp_1_elevator', 'floor': 1, 'x': 900.0, 'y': 600.0, 'type': 'elevator', 'label': 'North Elevator F1'});

  edges.add({'from': 'wp_1_entrance', 'to': 'wp_1_corridor', 'weight': 8.0, 'instruction': 'Walk straight from the entrance'});
  edges.add({'from': 'wp_1_cafeteria', 'to': 'wp_1_corridor', 'weight': 10.0, 'instruction': 'Walk right toward the corridor'});
  edges.add({'from': 'wp_1_elevator', 'to': 'wp_1_corridor', 'weight': 8.0, 'instruction': 'Walk left toward the corridor'});

  // Inter-floor stairs edges
  for (var f = 1; f < 4; f++) {
    edges.add({
      'from': 'wp_${f}_stairs',
      'to': 'wp_${f + 1}_stairs',
      'weight': 12.0,
      'instruction': 'Take the stairs to floor ${f + 1}',
    });
  }
  // Add an elevator on each floor for an alternative path
  for (var f = 2; f <= 4; f++) {
    nodes.add({
      'id': 'wp_${f}_elevator',
      'floor': f,
      'x': 900.0,
      'y': 600.0,
      'type': 'elevator',
      'label': 'North Elevator F$f',
    });
    edges.add({
      'from': 'wp_${f}_elevator',
      'to': 'wp_${f}_corridor',
      'weight': 6.0,
      'instruction': 'Walk left toward the corridor',
    });
  }
  for (var f = 1; f < 4; f++) {
    edges.add({
      'from': 'wp_${f}_elevator',
      'to': 'wp_${f + 1}_elevator',
      'weight': 10.0,
      'instruction': 'Take the elevator to floor ${f + 1}',
    });
  }

  await db.collection('navigation_graph').doc(buildingId).set({
    'nodes': nodes,
    'edges': edges,
  });

  // ---- Start points ----
  await db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .doc('sp_entrance')
      .set({
    'name': 'Main Entrance',
    'floor': 1,
    'waypointId': 'wp_1_entrance',
  });
  await db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .doc('sp_elevator')
      .set({
    'name': 'North Elevator',
    'floor': 1,
    'waypointId': 'wp_1_elevator',
  });
  await db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .doc('sp_cafeteria')
      .set({
    'name': 'Cafeteria',
    'floor': 1,
    'waypointId': 'wp_1_cafeteria',
  });
}
