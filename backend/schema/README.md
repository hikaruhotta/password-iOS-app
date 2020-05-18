See [schema.json](./schema.json) for the full example database file.

# A player's turn begins:
A turn object is appended to the list:
```json
turns: [
    {
        "player" : "sNbbJ6hAdQbINVVeJLG9nW6irLv1"
    }
]
```
You can watch for this event in Swift with the `FIRDataEventTypeChildAdded` listener on the turn list.  
See this realtime database documentation page for info: https://firebase.google.com/docs/database/ios/lists-of-data#listen_for_child_events

# Current player submits a word:
This is done through the `submitWord` cloud function.
## If it's someone else's target word:
*The turn is over*. Turn is immediately updated like this:
```json
turns: [
    {
        "player" : "$uid",
        "submittedWord" : "other player's target word",
        "wasOthersWord": true,
        "otherId": "$otheruid"
    }
]
```


## If it's not someone else's target word:
The current turn is updated so that submittedWord is no longer `null`:
```json
turns: [
    {
        "player" : "$uid",
        "submittedWord" : "pizza"
    }
]
```
You can watch for these update events in Swift with the `FIRDataEventTypeChildChanged` listener on the turn list.  
See this realtime database documentation page for info: https://firebase.google.com/docs/database/ios/lists-of-data#listen_for_child_events

# Voting begins:
The client displays the submitted word and gives the player the option to challenge it, with a countdown timer.  
Each client sends either a `CHALLENGE` or `TIMEOUT` response to some backend endpoint TBD, and the server waits until **one** player sends a `CHALLENGE` or it has received a `TIMEOUT` from **all** players.

## No players challenged:
```json
turns: [
    {
        "player" : "$uid",
        "submittedWord" : "pizza",
        "wasChallenged": false,
        "wasSubmittersWord": true or false
    }
]
```
## A player challenged:
```json
turns: [
    {
        "player" : "$uid",
        "submittedWord" : "pizza",
        "wasChallenged": true,
        "challengerId": "$challengerId",
        "wasSubmittersWord": true or false
    }
]
```
# Wait for ready up:

I am considering making it so that the next turn object is not added to the turn list until all players have seen the "outcome" of the turn (was other's word, was challenged or accepted, then was submitter's word) and then *sent some kind of ready response* to the server.  
This would give the client time to update UI in response to the turn outcome before needing to update UI in response to the next turn starting.  
So in the above example, the game would be "paused" with the state like this until everyone has readied up:
```json
turns: [
    {
        "player" : "$uid",
        "submittedWord" : "other player's target word",
        "wasOthersWord": true,
        "otherId": "$otheruid"
    }
]
```
Philip and Hikaru, does this sound like it would be helpful to you? Or should I just immediately add the new turn object? Seems like doing so could make your handler logic kind of tricky.