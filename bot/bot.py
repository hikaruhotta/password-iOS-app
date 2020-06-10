import numpy as np
import random
import string
from scipy import spatial
from nltk.stem import PorterStemmer

def hasNumbers(inputString):
    return any(char.isdigit() for char in inputString)

def hasPunctuation(inputString):
    return any(char in string.punctuation for char in inputString)

class PasswordBot:
    def __init__(self, target_dist_threshold=6.0, challenge_threshold=7.0):
        self.ps = PorterStemmer()

        print("Loading word embeddings for bot...")
        self.embeddings = {}
        with open("data/glove.6B.50d.txt", 'r', encoding="utf-8") as f:
            for line in f:
                values = line.split()
                word = values[0]
                vector = np.asarray(values[1:], "float32")
                self.embeddings[word] = vector
        
        # clean out digits and punctuation
        toRemove = []
        for word in self.embeddings.keys():
            if hasNumbers(word) or hasPunctuation(word):
                toRemove.append(word)
        for word in toRemove:
            self.embeddings.pop(word)
        
        # see self.vote_on_other_turn for details
        self.challenge_threshold = challenge_threshold
        
        # see self.play_turn for details
        self.target_dist_threshold = target_dist_threshold

    # return all words sorted by their distance to target_vec in the embedding space
    def words_by_distance(self, target_vec):
        return sorted(self.embeddings.keys(),
            key=lambda word: spatial.distance.cosine(self.embeddings[word], target_vec))

    # plays closest word to the target word+other word combo
    # There are many ways to tweak this strategy a little 
    def play_turn(self, target_words, previous_word):
        print("Generating turn for previous word {}.".format(previous_word))
        last_word_vec = self.embeddings[previous_word]

        # calculate paths to target words from the last played word, and sort them by length
        options = []
        for target_word in target_words:
            target_word_vec = self.embeddings[target_word]
            path = target_word_vec - last_word_vec
            distance = np.linalg.norm(path)
            options.append((target_word, path, distance))
        options = sorted(options, key=lambda option: option[2])

        # log distances to target words
        print("target word distances:")
        print([(o[0], o[2]) for o in options])

        # choose our specific target to be the closest target word. if it's nearby, play it.
        target_word, path, dist = options[0]
        if dist < self.target_dist_threshold:
            print("'{}' within threshold, returning".format(target_word))
            return target_word

        # otherwise find the closest words to the halfway point between them.
        print("midway word options for {}:".format(target_word))
        halfway_point = last_word_vec + (path / 2.0)
        nearby_words = self.words_by_distance(halfway_point)[:10]

        # remove words with the same word stem as the last word and the target word,
        # as these will often be the closest words to the midpoint.
        # for example, closest words to midpoint between 'campaign' and 'rebel'
        # might be ['campaign', 'rebel', 'rebels', 'fight']. we want to choose 'fight'.
        filtered = []
        for word in nearby_words:
            stem = self.ps.stem(word)
            if stem == self.ps.stem(target_word) or stem == self.ps.stem(previous_word):
                continue
            filtered.append(word)

        print(filtered)
        print("returning {}.".format(filtered[0]))

        return filtered[0]
    
    # returns a boolean of whether to reject the played word
    def vote_on_other_turn(self, previous_word, submitted_word):
        last_word_vec = self.embeddings[previous_word]
        played_word_vec = self.embeddings[submitted_word]
        distance = np.linalg.norm(played_word_vec - last_word_vec)
        print(distance)
        print("played word {} has distance {:0.2f} to {}.".format(submitted_word, distance, previous_word))

        # if we don't do this we return a numpy "bool_" type
        return bool(distance >= self.challenge_threshold)