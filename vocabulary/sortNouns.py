lengthSets = {}
maxLen = 3
with open("nounsByFrequency.txt") as f:
    for line in f.readlines():
        pair = line.strip().split(",")
        rank, word = pair
        
        lengthSet = lengthSets.get(len(word), [])
        lengthSet.append(pair)
        lengthSets[len(word)] = lengthSet

        maxLen = max(maxLen, len(word))


with open("nounsByLengthAndFrequency.txt", "w") as out:
    for i in range(3, maxLen+1):
        for pair in lengthSets[i]:
            rank, word = pair

            out.write(rank.zfill(4) + ", " + word + "\n")