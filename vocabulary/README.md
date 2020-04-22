# Nouns
**TODO: Remove proper nouns**  
The `nouns` files in this directory contain common nouns sorted by frequency of use in English. One idea is to pull some number of words from the list (maybe of different lengths) and use the frequencies as a rough heuristic of how difficult they'll be for players to navigate towards.  

## Data

`googleWordFrequencies.txt` is sourced from a Google corpus. Specifically, the file `google-10000-english-usa-no-swears.txt` in [this repo](https://github.com/first20hours/google-10000-english).

## Processing
Scripts were run with Python 3.8.  
I used NLTK to filter out all non-nouns and remove redundant words derived from the same "word stem". For example if we see 'apples' and 'apple' we take the more frequently used word and discard the other.