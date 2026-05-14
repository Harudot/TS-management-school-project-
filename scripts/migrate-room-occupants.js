// Usage: node scripts/migrate-room-occupants.js
//
// Walks every building's `rooms` subcollection. For each doc that does NOT
// already have an `occupantIds` array, writes:
//   occupantIds = [occupantId]  (or [] if no legacy field)
// and clears the legacy `occupantId` field. Idempotent.

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(require('../service-account.json')),
});

(async () => {
  const db = admin.firestore();
  const buildings = await db.collection('buildings').listDocuments();
  let migrated = 0, skipped = 0;
  for (const b of buildings) {
    const rooms = await b.collection('rooms').get();
    for (const r of rooms.docs) {
      const data = r.data();
      if (Array.isArray(data.occupantIds)) { skipped++; continue; }
      const legacy = typeof data.occupantId === 'string' && data.occupantId.length
        ? [data.occupantId]
        : [];
      await r.ref.update({
        occupantIds: legacy,
        occupantId: admin.firestore.FieldValue.delete(),
      });
      migrated++;
    }
  }
  console.log(`Migrated ${migrated} rooms (${skipped} already in new shape).`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
