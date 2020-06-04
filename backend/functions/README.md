# Calling Cloud Functions from iOS
```swift
Auth.auth().signInAnonymously() { (authResult, error) in
    // 
}

functions.httpsCallable("addMessage").call(["text": inputField.text]) { (result, error) in
    if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
        }
        // ...
    }
    if let text = (result?.data as? [String: Any])?["text"] as? String {
        self.resultField.text = text
    }
}
```
Create a new anonymous user: https://firebase.google.com/docs/auth/ios/anonymous-auth  
Get current anonymous user information: https://firebase.google.com/docs/auth/ios/manage-users  
Calling cloud functions documentation: https://firebase.google.com/docs/functions/callable#call_the_function

Firebase anonymous users are separate from the player information that we send up with the createLobby and joinLobby requests (the display name and emoji index). Basically all we're using from that firebase user is their user id, which we associate with a player and use to keep track of them and grant them database read permissions.

## Handling Errors
Errors will be drawn from this list of possible codes: https://firebase.google.com/docs/reference/js/firebase.functions#functionserrorcode  

See this documentation page for how to handle errors in iOS: https://firebase.google.com/docs/functions/callable#handle_errors_on_the_client

# Cloud Function Descriptions
## See [index.js](index.js) for source code and [schema.json](../schema/schema.json) for database schema.
**Note:** all functions will return `Error: unauthenticated` if not signed in as an anonymous firebase user as described above.

## createLobby
Creates a new lobby, adds the requesting user into it, and creates a new code to access that lobby. Gives the requesting user the generated lobby code so that the client can display something like `"Send this code to your friends: AXDF"`.
### Input Data:
```json
{
    "player": {
        "displayName": "Kate",
        "colorNumber": 2,
        "emojiNumber": 4
    }
}
```
### Returned Data:

```json
{
    "lobbyId": "-M6wTegEBA-yki7X0kKv",
    "lobbyCode": "AXDF"
}
```
### Possible Errors:

`invalid-argument`: if missing user information in request  
`resource-exhausted`: if somehow can't find a free lobby code  
___

## joinLobby
Adds the requesting user into an existing lobby if it is still accepting new players. Gives the requesting client the id of the lobby they joined so they can subscribe to changes to its state.
### Input Data:
```json
{
    "lobbyCode": "AXDF",
    "player": {
        "displayName": "Nick",
        "colorNumber": 2,
        "emojiNumber": 4
    }
}
```
### Returned Data:
```json
{
    "lobbyId": "-M6wTegEBA-yki7X0kKv",
}
```
### Possible Errors:
`invalid-argument`: if missing user information or lobby code in request  
`not-found`: if no lobby associated with submitted lobby code or code resolves to lobby id for missing lobby  
`failed-precondition`: if lobby status is not open  
___


## startGame
This does the following:
* Generates word lists for players in their `lobbies/$lobbyId/private/$uid` directory.  
* Generates a random starting word and places it at `lobbies/$lobbyId/public/startWord`.  
* Chooses a random player order and adds the first turn object to the turn list for the first player.
* Sets the lobby's internal status to `"SUBMISSION"`. 

Because of the way these properties are set, this function should be suitable to start a new game with the same players in an existing lobby in the `DONE` state. But right now it throws an error if you try to start a game in any state other than `LOBBY`.
### Input Data:

Game settings:
```json
{
    "gameSettings": {
        "numRounds": 8,
        "wordBankSize": 6
    }
}
```
**If you don't include any data in your request, defaults will be used.** The above example submission represents those defaults.  
More settings TBD.
### Returned Data:
```json
null
```
### Possible Errors:
`failed-precondition`: if lobby status is not open  
`permission-denied`: if you aren't the firebase user that created the lobby  
`invalid-argument`: if you included gameSettings but messed up one of the fields  
___

## submitWord
### Input Data:
```json
{
    "word": "pizza"
}
```
The submitted word is expected to contain only alphabet letters or an error will be returned.
### Returned Data:
```json
null
```
### Possible Errors:
`invalid-argument`: if missing or invalid word in request  
`failed-precondition`: if lobby status is not `SUBMISSION` or it's not your turn  
___

## voteOnWord
### Input Data:
```json
{
    "challenge": true or false
}
```
### Returned Data:
```json
null
```
### Possible Errors:
`invalid-argument`: if missing or invalid vote in request  
`failed-precondition`: 
* if the lobby status is not `VOTING`
* if you try to vote on your own word
* if you already voted
___

## requestNewWords
### Input Data:
```json
null
```
### Returned Data:
```json
null
```
### Possible Errors:
`failed-precondition`: if you're not allowed to request new words right now. For example game hasn't started yet, or you've submitted a word and you're waiting for votes to come in. We don't want the player to reroll words then, seems weird to be able to do that.