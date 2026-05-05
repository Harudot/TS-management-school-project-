const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.cert(require('../service-account.json')),
});

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

const buildingId = 'main';

async function seed() {
  await db.collection('buildings').doc(buildingId).set({
    name: 'Main Campus Building',
    address: '1 University Way',
    photoUrl: null,
    qrCode: `campus://${buildingId}`,
    floorCount: 4,
    companies: ['Computer Science', 'Mathematics', 'Library', 'Admin'],
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  for (let i = 1; i <= 4; i++) {
    await db.collection('buildings').doc(buildingId)
      .collection('floors').doc(String(i))
      .set({ floorPlanUrl: null, width: 1000, height: 700 });
  }

  for (let f = 1; f <= 4; f++) {
    for (let n = 1; n <= 5; n++) {
      const roomNum = `${f}0${n}`;
      await db.collection('buildings').doc(buildingId)
        .collection('rooms').doc(`room_${roomNum}`)
        .set({
          number: roomNum,
          floor: f,
          name: `Room ${roomNum}`,
          occupantId: null,
          type: n === 1 ? 'reception' : (n === 5 ? 'lab' : 'office'),
          waypointId: `wp_${f}_room${n}`,
        });
    }
  }

  const people = [
    { id: 'p_alice', name: 'Alice Chen',     role: 'Professor',     department: 'Computer Science', buildingId, roomId: 'room_304', contact: 'alice@campus.edu', photoUrl: null },
    { id: 'p_bob',   name: 'Bob Martin',     role: 'Lecturer',      department: 'Mathematics',      buildingId, roomId: 'room_201', contact: 'bob@campus.edu',   photoUrl: null },
    { id: 'p_carol', name: 'Carol Davies',   role: 'Librarian',     department: 'Library',          buildingId, roomId: 'room_101', contact: 'carol@campus.edu', photoUrl: null },
    { id: 'p_dan',   name: 'Dan Park',       role: 'Admin',         department: 'Admin',            buildingId, roomId: 'room_405', contact: 'dan@campus.edu',   photoUrl: null },
    { id: 'p_eve',   name: 'Eve Johnson',    role: 'PhD candidate', department: 'Computer Science', buildingId, roomId: 'room_305', contact: 'eve@campus.edu',   photoUrl: null },
  ];
  for (const p of people) {
    const id = p.id;
    const { id: _, ...data } = p;
    await db.collection('people').doc(id).set(data);
  }

  const now = new Date();
  const today = (h) => new Date(now.getFullYear(), now.getMonth(), now.getDate(), h);
  const inDays = (d, h) => { const t = new Date(now); t.setDate(t.getDate() + d); t.setHours(h, 0, 0, 0); return t; };

  await db.collection('events').doc('e_hackathon').set({
    title: 'Hackathon — Open to all',
    description: '24-hour build session. Snacks provided.',
    buildingId, floor: 4, roomId: 'room_304',
    startTime: Timestamp.fromDate(today(14)),
    endTime: Timestamp.fromDate(today(18)),
    category: 'event', createdBy: 'seed',
  });
  await db.collection('events').doc('e_lecture').set({
    title: 'Guest lecture: Distributed Systems',
    description: 'Auditorium hosts visiting researcher.',
    buildingId, floor: 2, roomId: 'room_201',
    startTime: Timestamp.fromDate(inDays(1, 10)),
    endTime: Timestamp.fromDate(inDays(1, 12)),
    category: 'lecture', createdBy: 'seed',
  });

  const nodes = [];
  const edges = [];
  for (let f = 1; f <= 4; f++) {
    nodes.push({ id: `wp_${f}_corridor`, floor: f, x: 500.0, y: 350.0, type: 'junction', label: `Corridor F${f}` });
    nodes.push({ id: `wp_${f}_stairs`,   floor: f, x: 900.0, y: 350.0, type: 'stairs',   label: `Stairs F${f}` });
    for (let n = 1; n <= 5; n++) {
      nodes.push({
        id: `wp_${f}_room${n}`, floor: f,
        x: 100.0 + (n - 1) * 180.0, y: 150.0,
        type: 'room', label: `Room ${f}0${n}`,
      });
      edges.push({ from: `wp_${f}_room${n}`, to: `wp_${f}_corridor`, weight: 8.0, instruction: 'Walk to the corridor' });
    }
    edges.push({ from: `wp_${f}_corridor`, to: `wp_${f}_stairs`, weight: 6.0, instruction: 'Walk to the stairwell' });
  }

  nodes.push({ id: 'wp_1_entrance',  floor: 1, x: 500.0, y: 600.0, type: 'entrance', label: 'Main Entrance' });
  nodes.push({ id: 'wp_1_cafeteria', floor: 1, x: 100.0, y: 600.0, type: 'junction', label: 'Cafeteria' });
  nodes.push({ id: 'wp_1_elevator',  floor: 1, x: 900.0, y: 600.0, type: 'elevator', label: 'North Elevator F1' });

  edges.push({ from: 'wp_1_entrance',  to: 'wp_1_corridor', weight: 8.0,  instruction: 'Walk straight from the entrance' });
  edges.push({ from: 'wp_1_cafeteria', to: 'wp_1_corridor', weight: 10.0, instruction: 'Walk right toward the corridor' });
  edges.push({ from: 'wp_1_elevator',  to: 'wp_1_corridor', weight: 8.0,  instruction: 'Walk left toward the corridor' });

  for (let f = 1; f < 4; f++) {
    edges.push({ from: `wp_${f}_stairs`, to: `wp_${f + 1}_stairs`, weight: 12.0, instruction: `Take the stairs to floor ${f + 1}` });
  }
  for (let f = 2; f <= 4; f++) {
    nodes.push({ id: `wp_${f}_elevator`, floor: f, x: 900.0, y: 600.0, type: 'elevator', label: `North Elevator F${f}` });
    edges.push({ from: `wp_${f}_elevator`, to: `wp_${f}_corridor`, weight: 6.0, instruction: 'Walk left toward the corridor' });
  }
  for (let f = 1; f < 4; f++) {
    edges.push({ from: `wp_${f}_elevator`, to: `wp_${f + 1}_elevator`, weight: 10.0, instruction: `Take the elevator to floor ${f + 1}` });
  }

  await db.collection('navigation_graph').doc(buildingId).set({ nodes, edges });

  await db.collection('start_points').doc(buildingId).collection('points').doc('sp_entrance')
    .set({ name: 'Main Entrance', floor: 1, waypointId: 'wp_1_entrance' });
  await db.collection('start_points').doc(buildingId).collection('points').doc('sp_elevator')
    .set({ name: 'North Elevator', floor: 1, waypointId: 'wp_1_elevator' });
  await db.collection('start_points').doc(buildingId).collection('points').doc('sp_cafeteria')
    .set({ name: 'Cafeteria', floor: 1, waypointId: 'wp_1_cafeteria' });
}

seed().then(() => { console.log('Seed complete.'); process.exit(0); })
      .catch((e) => { console.error('Seed failed:', e); process.exit(1); });
