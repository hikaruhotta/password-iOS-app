set GOOGLE_APPLICATION_CREDENTIALS=admin-credentials.json
echo "DID YOU SET INDEX.JS TO USE EMULATED FUNCTIONS?"
firebase emulators:start --only hosting,functions --inspect-functions
