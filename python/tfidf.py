#!/usr/bin/env python3
import math

def comm_tfidf(topicList,idfDict,topWordsNum):
    scores = {word: tfidf(word, topicList, idfDict) for word in topicList}
    word_ranking = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    myDict=word_ranking[:topWordsNum]
    return myDict

def tf(word, topicList):
    return topicList[word] / len(topicList)

def idf(word, idfDict):
    if word in idfDict:
        idfScore=idfDict[word]
    else:
        idfScore=0
    return idfScore

def tfidf(word, topicList, idfDict):
    return tf(word, topicList) * idf(word, idfDict)

