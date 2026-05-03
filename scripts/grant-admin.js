const admin = require('firebase-admin');
  admin.initializeApp({
    credential: admin.credential.cert(require('../service-account.json')),
  });

  const email = process.argv[2];
  if (!email) { console.error('Usage: node grant-admin.js <email>'); process.exit(1); }

  (async () => {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(user.uid, { role: 'admin' });
    await admin.firestore().collection('users').doc(user.uid)
      .set({ role: 'admin' }, { merge: true });
    console.log(`Granted admin to ${email} (uid=${user.uid})`);
    process.exit(0);
  })();