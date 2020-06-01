See [schema.json](./schema.json) for the full example database file.

# A player's turn begins:
A turn object is appended to the list:
```json
turns: [
    {
        "created" : 1589236047060,
        "player" : "sNbbJ6hAdQbINVVeJLG9nW6irLv1"
    }
]
```
In Swift, you can watch for this modifications to the turn list with the `FIRDataEventTypeValue` event listener.  
See this realtime database documentation page for info: https://firebase.google.com/docs/database/ios/read-and-write#listen_for_value_events

# Current player submits a word:
This is done through the `submitWord` cloud function.
## If it's someone else's target word:
*The turn is over*. Turn is immediately updated like this:
```json
turns: [
    {
        "created" : 1589236047060,
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
        "created" : 1589236047060,
        "player" : "$uid",
        "submittedWord" : "pizza"
    }
]
```

# Voting:
The client displays the submitted word and gives the player the option to challenge it, with a countdown timer.  
Each client sends a `{ "challenge": true or false }` response to the `voteOnWord` endpoint, and the server waits until all players have voted.  
Eventually we can implement client-side code that automatically sends `{ "challenge": false }` after 5 seconds as a timer on voting.

## After all votes received:
Whether the word was the submitter's word or not is revealed and the votes are revealed.  
The backend automatically updates each player's score in `/public/players/$uid/score`.
```json
turns: [
    {
        "created" : 1589236047060,
        "player" : "$uid",
        "submittedWord" : "pizza",
        "wasSubmittersWord": true or false,
        "votes": [
            "$voterId1": true or false,
            ...
        ]
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
        "created" : 1589236047060,
        "player" : "$uid",
        "submittedWord" : "other player's target word",
        "wasOthersWord": true,
        "otherId": "$otheruid"
    }
]
```
Philip and Hikaru, does this sound like it would be helpful to you? Or should I just immediately add the new turn object? Seems like doing so could make your handler logic kind of tricky.