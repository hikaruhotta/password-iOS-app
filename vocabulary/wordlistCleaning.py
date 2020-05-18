#!/usr/bin/env python
# coding: utf-8

# In[22]:


from nltk.tag import pos_tag
from nltk.stem import PorterStemmer
from collections import OrderedDict
import random


# In[5]:


words_to_use = []
seen_stems = set()
ps = PorterStemmer()

#remove same stem words
with open("googleWordFrequencies.txt") as f:
    for line in f.readlines():
        rank, word = line.strip().split(",")
        if len(word) > 2:
            stem = ps.stem(word)
            if stem in seen_stems:
                continue
            seen_stems.add(stem)
            words_to_use.append(word)


# In[13]:


tagged_words = pos_tag(words_to_use)


# In[26]:


#filter for non-proper nouns, no verbs, adjectives
words_to_use = [word for word,pos in tagged_words if (pos == 'JJ' or pos == 'JJR' or pos == 'JJS' or pos=='NN' or pos=='NNS' and pos != 'NNP')]
                                                     #or pos== 'VB' or pos=='VBD' or pos=='VBG' or pos=='VBM' or pos=='VBP'
                                                     #or pos=='VBZ')]


# In[28]:


def get_game_words (num_players):
    total_words = 10*num_players
    return random.sample (words_to_use, total_words)


# In[ ]:




