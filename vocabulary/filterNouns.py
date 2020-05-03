from nltk.corpus import wordnet as wn
from nltk.stem import PorterStemmer
from collections import OrderedDict

wn_nouns = {x.name().split('.', 1)[0] for x in wn.all_synsets('n')}
common_nouns = []
seen_stems = set()
ps = PorterStemmer()

with open("googleWordFrequencies.txt") as f:
    with open("nounsByFrequency.txt", "w") as out:
        for line in f.readlines():
            rank, word = line.strip().split(",")
            if len(word) > 2 and word in wn_nouns:
                stem = ps.stem(word)
                if stem in seen_stems:
                    continue
                seen_stems.add(stem)
                out.write(line)