set GOOGLE_APPLICATION_CREDENTIALS=admin-credentials.json
set FIREBASE_DATABASE_EMULATOR_HOST=localhost:9000
echo "DID YOU SET INDEX.JS TO USE EMULATED FUNCTIONS?"
firebase emulators:start --inspect-functions
