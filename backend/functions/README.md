# Calling Cloud Functions from iOS
See [index.js](./functions/index.js) for cloud function source code.
```swift
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
[See Documentation Here](https://firebase.google.com/docs/functions/callable#call_the_function)
## Handling Errors
Errors will be drawn from this list of possible codes: https://firebase.google.com/docs/reference/js/firebase.functions#functionserrorcode  

See this documentation page for how to handle errors in iOS: https://firebase.google.com/docs/functions/callable#handle_errors_on_the_client

# createLobby
Creates a new lobby, adds the requesting user into it, and creates a new code to access that lobby. Gives the requesting user a hostkey used to start the game, and the generated lobby code so that the client can display the code.
### Input Data:
```json
{
    "user": {
        "username": "username",
        // other fields tbd
    }
}
```
### Returned Data:

```json
{
    "lobbyId": "-M6wTegEBA-yki7X0kKv",
    "hostSecret": "55c8340d12d8774e48443b7bdfad3efa",
    "lobbyCode": "AXDF"
}
```
### Possible Errors:
`invalid-argument`: if missing user information in request  
`internal`: if lobby ids get out of wack  
`resource-exhausted`: if somehow can't find a free lobby code  

# joinLobby
Adds the requesting user into an existing lobby if it is still accepting new players. Gives the requesting client the id of the lobby they joined so they can subscribe to changes to its state.
### Input Data:
```json
{
    "lobbyCode": "AXDF",
    "user": {
        "username": "username",
        // other fields tbd
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
`not-found`: if no lobby associated with submitted lobby code  
`failed-precondition`: if lobby status is not open  
`internal`: if lobby ids get out of wack  

# startGame (WIP)
### Input Data:
```json

```
### Returned Data:
```json

```
### Possible Errors:
# submitWord (WIP)
### Input Data:
```json

```
### Returned Data:
```json

```
### Possible Errors: