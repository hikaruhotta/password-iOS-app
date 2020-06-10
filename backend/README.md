# Backend
### This directory contains the Firebase Project for the backend of the game.


## /functions/

This folder houses code for Firebase Cloud Functions, which constitute the majority of the backend code.  

**See the [folder's readme](./functions) for the most complete reference for interacting with the backend as a client.**  
This also contains information specific to iOS clients.

## /schema/
This folder contains `schema.json`, a full example of how a game lobby object in our Firebase Realtime Database instance will look after a game has been played.  

See the [folder's readme](./schema) for a more detailed explanation of how updates to the database occur as clients make calls to the backend.
## /Public/

Any files in this folder will be hosted by Firebase when you run `firebase deploy`.  
Hosting is at this link: https://password-b77bd.web.app/

It currently includes a 'developer console' where you can send requests to the backend as a client via a simple HTML page + Javascript. Errors are displayed in the browser console.

There's no readme for this folder.