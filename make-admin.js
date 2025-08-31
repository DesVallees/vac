// node set-claim.js <UID> [true|false]
const admin = require('firebase-admin');

const uid = process.argv[2];
const value = (process.argv[3] ?? 'true') === 'true';

if (!uid) {
    console.error('Usage: node set-claim.js <UID> [true|false]');
    process.exit(1);
}

admin.initializeApp({
    credential: admin.credential.cert(require('./serviceAccount.json')),
});

(async () => {
    await admin.auth().setCustomUserClaims(uid, { admin: value });
    const user = await admin.auth().getUser(uid);
    console.log(`Admin claim set to ${value} for ${user.uid} (${user.email || 'no-email'})`);
    process.exit(0);
})();