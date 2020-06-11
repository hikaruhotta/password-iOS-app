import time

from bot import PasswordBot
from flask import Flask, request, jsonify

app = Flask(__name__)
bot = PasswordBot()

@app.route('/getBotTurn', methods=['POST'])
def getBotTurn():
    # obfuscate bot word generation time; otherwise you'd know the bot
    # was using a word on its word list if it took its turn quickly.
    # midway word generation took about 16 seconds on my i7-5730K.
    startTime = time.time()
    
    data = request.get_json()
    targetWords = data['targetWords']
    previousWord = data['previousWord']
    word = bot.play_turn(targetWords, previousWord)

    timeTaken = time.time() - startTime

    if timeTaken < 18:
        time.sleep(18 - timeTaken)

    return jsonify(word=word)


@app.route('/getBotVote', methods=['POST'])
def getBotVote():
    data = request.get_json()
    previousWord = data['previousWord']
    submittedWord = data['submittedWord']
    challenge = bot.vote_on_other_turn(previousWord, submittedWord)

    return jsonify(challenge=challenge)

if __name__ == '__main__':
    app.run()