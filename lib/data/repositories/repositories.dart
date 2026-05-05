import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/app_user.dart';
import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';

final firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

// USERS ----------------------------------------------------------------------
class UsersRepository {
  UsersRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Stream<AppUser?> watch(String uid) =>
      _col.doc(uid).snapshots().map((s) => s.exists ? AppUser.fromMap(uid, s.data()!) : null);

  Future<AppUser?> get(String uid) async {
    final s = await _col.doc(uid).get();
    return s.exists ? AppUser.fromMap(uid, s.data()!) : null;
  }

  Future<void> upsert(AppUser u) =>
      _col.doc(u.uid).set(u.toMap(), SetOptions(merge: true));

  Future<void> updateFcmToken(String uid, String token) =>
      _col.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));

  Future<void> updateThemePreference(String uid, String pref) =>
      _col.doc(uid).set({'themePreference': pref}, SetOptions(merge: true));

  Future<void> followBuilding(String uid, String buildingId) =>
      _col.doc(uid).set({
        'followedBuildings': FieldValue.arrayUnion([buildingId])
      }, SetOptions(merge: true));

  Future<void> unfollowBuilding(String uid, String buildingId) =>
      _col.doc(uid).set({
        'followedBuildings': FieldValue.arrayRemove([buildingId])
      }, SetOptions(merge: true));
}

final usersRepositoryProvider =
    Provider<UsersRepository>((ref) => UsersRepository(ref.watch(firestoreProvider)));

// BUILDINGS ------------------------------------------------------------------
class BuildingsRepository {
  BuildingsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('buildings');

  Stream<List<Building>> watchAll() => _col.snapshots().map(
      (q) => q.docs.map((d) => Building.fromMap(d.id, d.data())).toList());

  Future<Building?> get(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? Building.fromMap(id, s.data()!) : null;
  }

  Future<void> upsert(Building b) =>
      _col.doc(b.id).set(b.toMap(), SetOptions(merge: true));

  Future<void> delete(String id) => _col.doc(id).delete();

  Stream<List<FloorDoc>> watchFloors(String buildingId) =>
      _col.doc(buildingId).collection('floors').orderBy(FieldPath.documentId).snapshots().map(
          (q) => q.docs
              .map((d) => FloorDoc.fromMap(int.parse(d.id), d.data()))
              .toList());

  Future<void> upsertFloor(String buildingId, FloorDoc f) => _col
      .doc(buildingId)
      .collection('floors')
      .doc(f.number.toString())
      .set(f.toMap(), SetOptions(merge: true));

  Stream<List<RoomDoc>> watchRooms(String buildingId) =>
      _col.doc(buildingId).collection('rooms').snapshots().map(
          (q) => q.docs.map((d) => RoomDoc.fromMap(d.id, d.data())).toList());

  Future<List<RoomDoc>> rooms(String buildingId) async {
    final s = await _col.doc(buildingId).collection('rooms').get();
    return s.docs.map((d) => RoomDoc.fromMap(d.id, d.data())).toList();
  }

  Future<void> upsertRoom(String buildingId, RoomDoc r) => _col
      .doc(buildingId)
      .collection('rooms')
      .doc(r.id)
      .set(r.toMap(), SetOptions(merge: true));

  Future<void> deleteRoom(String buildingId, String roomId) =>
      _col.doc(buildingId).collection('rooms').doc(roomId).delete();
}

final buildingsRepositoryProvider = Provider<BuildingsRepository>(
    (ref) => BuildingsRepository(ref.watch(firestoreProvider)));

// PEOPLE ---------------------------------------------------------------------
class PeopleRepository {
  PeopleRepository(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('people');

  Stream<List<Person>> watchAll() => _col.snapshots().map(
      (q) => q.docs.map((d) => Person.fromMap(d.id, d.data())).toList());

  Future<Person?> get(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? Person.fromMap(id, s.data()!) : null;
  }

  Future<void> upsert(Person p) => _col.doc(p.id).set(p.toMap(), SetOptions(merge: true));
  Future<void> delete(String id) => _col.doc(id).delete();
}

final peopleRepositoryProvider = Provider<PeopleRepository>(
    (ref) => PeopleRepository(ref.watch(firestoreProvider)));

// EVENTS ---------------------------------------------------------------------
class EventsRepository {
  EventsRepository(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('events');

  Stream<List<CampusEvent>> watchAll() => _col.orderBy('startTime').snapshots().map(
      (q) => q.docs.map((d) => CampusEvent.fromMap(d.id, d.data())).toList());

  Stream<List<CampusEvent>> watchForBuilding(String buildingId) => _col
      .where('buildingId', isEqualTo: buildingId)
      .orderBy('startTime')
      .snapshots()
      .map((q) => q.docs.map((d) => CampusEvent.fromMap(d.id, d.data())).toList());

  Future<void> upsert(CampusEvent e) =>
      _col.doc(e.id).set(e.toMap(), SetOptions(merge: true));
  Future<void> delete(String id) => _col.doc(id).delete();
}

final eventsRepositoryProvider = Provider<EventsRepository>(
    (ref) => EventsRepository(ref.watch(firestoreProvider)));

// NAVIGATION GRAPH + START POINTS -------------------------------------------
class NavigationRepository {
  NavigationRepository(this._db);
  final FirebaseFirestore _db;

  Future<NavigationGraph?> getGraph(String buildingId) async {
    final s = await _db.collection('navigation_graph').doc(buildingId).get();
    return s.exists ? NavigationGraph.fromMap(s.data()!) : null;
  }

  Future<void> setGraph(String buildingId, NavigationGraph g) =>
      _db.collection('navigation_graph').doc(buildingId).set(g.toMap());

  Stream<List<StartPoint>> watchStartPoints(String buildingId) => _db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .snapshots()
      .map((q) =>
          q.docs.map((d) => StartPoint.fromMap(d.id, d.data())).toList());

  Future<List<StartPoint>> startPoints(String buildingId) async {
    final s = await _db
        .collection('start_points')
        .doc(buildingId)
        .collection('points')
        .get();
    return s.docs.map((d) => StartPoint.fromMap(d.id, d.data())).toList();
  }

  Future<void> upsertStartPoint(String buildingId, StartPoint sp) => _db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .doc(sp.id)
      .set(sp.toMap(), SetOptions(merge: true));

  Future<void> deleteStartPoint(String buildingId, String id) => _db
      .collection('start_points')
      .doc(buildingId)
      .collection('points')
      .doc(id)
      .delete();
}

final navigationRepositoryProvider = Provider<NavigationRepository>(
    (ref) => NavigationRepository(ref.watch(firestoreProvider)));
