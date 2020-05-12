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

Firebase anonymous users are separate from the user information that we send up with the createLobby and joinLobby requests (the display name and emoji index). Basically all we're using from that firebase user is their id, which we can use to give separate read permissions within the lobby.

## Handling Errors
Errors will be drawn from this list of possible codes: https://firebase.google.com/docs/reference/js/firebase.functions#functionserrorcode  

See this documentation page for how to handle errors in iOS: https://firebase.google.com/docs/functions/callable#handle_errors_on_the_client

# Cloud Function Descriptions
## See [index.js](index.js) for source code and [schema.json](schema.json) for database schema.

## createLobby
Creates a new lobby, adds the requesting user into it, and creates a new code to access that lobby. Gives the requesting user the generated lobby code so that the client can display something like `"Send this code to your friends: AXDF"`.
### Input Data:
```json
{
    "user": {
        "username": "username",
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
`unauthenticated`: if not signed in as firebase user  
`invalid-argument`: if missing user information in request  
`resource-exhausted`: if somehow can't find a free lobby code  
`internal`: if something fails in an unexpected way in the backend  
___

## joinLobby
Adds the requesting user into an existing lobby if it is still accepting new players. Gives the requesting client the id of the lobby they joined so they can subscribe to changes to its state.
### Input Data:
```json
{
  "lobbyCode": "AXDF",
    "user": {
      "username": "username",
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
`unauthenticated`: if not signed in as firebase user
`invalid-argument`: if missing user information or lobby code in request  
`not-found`: if no lobby associated with submitted lobby code or code resolves to lobby id for missing lobby  
`failed-precondition`: if lobby status is not open  
`internal`: if something fails in an unexpected way in the backend  
___


## startGame (WIP)
This sets the lobby status to `"GAME"` and generates dummy word lists for players in their `lobbies/$lobbyid/private/$uid` directory.

**Additional functionality TBD**, such as creating real word lists, assigning the starting player, perhaps generating a start word.

### Input Data:
```json
{
  "lobbyId": "-M6wTegEBA-yki7X0kKv"
}
```
### Returned Data:
```json
null
```
### Possible Errors:
`unauthenticated`: if not signed in as firebase user  
`invalid-argument`: if missing lobby id in request  
`not-found`: if lobby with given id not found  
`failed-precondition`: if lobby status is not open  
`permission-denied`: if you aren't the firebase user that created the lobby
`internal`: if something fails in an unexpected way in the backend   
___

## submitWord (WIP)
### Input Data:
```json

```
### Returned Data:
```json

```
### Possible Errors:
