from flask import Flask
app = Flask(__name__)

# TODO: obfuscate bot word generation time, can be used to cheat

@app.route('/getBotTurn', methods=['POST'])
def hello():
    data = request.get_json()

    targetWords = data['targetWords']
    lastPlayedWord = data['lastPlayedWord']
    
    return "Hello World!"


@app.route('/<name>')
def hello_name(name):
    return "Hello {}!".format(name)

if __name__ == '__main__':
    app.run()