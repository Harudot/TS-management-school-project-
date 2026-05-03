const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const QRCode = require('qrcode');

admin.initializeApp();

// 1) Push a notification to topic `building_<id>` whenever a new event is added.
exports.notifyOnEventCreate = onDocumentCreated('events/{eventId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const buildingId = data.buildingId;
  const topic = `building_${buildingId}`;
  const start = data.startTime?.toDate?.();
  const when = start ? start.toLocaleString() : '';
  await admin.messaging().send({
    topic,
    notification: {
      title: data.title || 'New event',
      body: `Floor ${data.floor}${data.roomId ? ' · ' + data.roomId : ''}${when ? ' · ' + when : ''}`,
    },
    data: {
      type: 'event',
      eventId: event.params.eventId,
      buildingId,
    },
  });
});

// 2) Generate a QR PNG for a building and store it in Storage; cache URL on the building doc.
exports.generateBuildingQr = onDocumentWritten('buildings/{buildingId}', async (event) => {
  const after = event.data?.after?.data();
  if (!after) return;
  const buildingId = event.params.buildingId;
  // Skip if QR already cached and matches
  if (after.qrCode && after.qrCode === `campus://${buildingId}`) {
    if (after.qrUrl) return;
  }
  const png = await QRCode.toBuffer(`campus://${buildingId}`, { width: 512 });
  const bucket = admin.storage().bucket();
  const file = bucket.file(`buildings/${buildingId}/qr.png`);
  await file.save(png, { contentType: 'image/png' });
  await file.makePublic();
  const url = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
  await admin.firestore().collection('buildings').doc(buildingId).set(
    { qrCode: `campus://${buildingId}`, qrUrl: url },
    { merge: true },
  );
});

// 3) Callable to set / unset the admin custom claim on a user (caller must already be admin).
exports.setAdminClaim = onCall(async (req) => {
  const callerToken = req.auth?.token;
  if (!callerToken || callerToken.role !== 'admin') {
    throw new HttpsError('permission-denied', 'Caller is not an admin.');
  }
  const { uid, isAdmin } = req.data;
  if (!uid) throw new HttpsError('invalid-argument', 'uid required');
  await admin.auth().setCustomUserClaims(uid, isAdmin ? { role: 'admin' } : {});
  await admin.firestore().collection('users').doc(uid).set(
    { role: isAdmin ? 'admin' : 'user' },
    { merge: true },
  );
  return { ok: true };
});

// 4) Bootstrap: callable that lets you mark the FIRST user as admin
//    (only works while no admin exists in the system).
exports.bootstrapFirstAdmin = onCall(async (req) => {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Sign in first.');
  const list = await admin.auth().listUsers(1000);
  const hasAdmin = list.users.some((u) => u.customClaims?.role === 'admin');
  if (hasAdmin) {
    throw new HttpsError('failed-precondition', 'An admin already exists.');
  }
  await admin.auth().setCustomUserClaims(req.auth.uid, { role: 'admin' });
  await admin.firestore().collection('users').doc(req.auth.uid).set(
    { role: 'admin' },
    { merge: true },
  );
  return { ok: true };
});
