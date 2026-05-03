const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.cert(require('../service-account.json')),
});

const email = process.argv[2];
if (!email) { console.error('Usage: node check-admin.js <email>'); process.exit(1); }

(async () => {
  try {
    const user = await admin.auth().getUserByEmail(email);
    console.log(`UID:          ${user.uid}`);
    console.log(`Email:        ${user.email}`);
    console.log(`Display name: ${user.displayName ?? '(none)'}`);
    console.log(`Disabled:     ${user.disabled}`);
    console.log(`Custom claims:`, user.customClaims ?? '(none)');
    console.log(`Provider IDs: ${user.providerData.map(p => p.providerId).join(', ')}`);
    if (user.customClaims?.role === 'admin') {
      console.log('\n✓ This user IS admin.');
    } else {
      console.log('\n✗ This user is NOT admin. Run grant-admin.js to fix.');
    }
  } catch (e) {
    console.error('Error:', e.message);
    process.exit(1);
  }
  process.exit(0);
})();
