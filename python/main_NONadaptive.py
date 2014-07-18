#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#-------------------------------------------------------------------------------
# Name:
# Purpose:       This .py file is the main Framework file
#                It uses a straightforward timeslot partitioning algorithm
#
# Required libs: python-dateutil, numpy,matplotlib,pyparsing
# Author:        konkonst
#
# Created:       20/08/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import time,os,pickle
from CommunityRanking_NONadaptive import communityranking

'''PARAMETERS'''
# User sets json dataset folder 
dataset_path = "./goldendawn_json_origin"
#Construct the data class from scratch: 1-yes / 2-only the evolution / 3-perform only the ranking
dataextract = 3
#User sets desired number of displayed top communities
numTopComms = 10
#User sets how many timeslots back the framework should search
prevTimeslots = 7
#Number of labels on the x-axis of the activity distribution
xLablNum = 20
#User decides whether to simplify the jsons into readable txts:  1-on / 0-off (time consuming)
simplify_json = 0
#If json files have irregular timestamps, set rankIrregularTime to 1 in order to order them chronologically
rankIrregularTime = 0
print(dataset_path)
#User sets desired time intervals if applicable. Else the whole dataset is considered
if dataset_path == "./us_elections":
    timeSeg = [900,1200,1800, 2700]
    titlenum=0
if dataset_path == "./royal_baby":
    timeSeg = [900, 1800, 2700, 3600]
    timeMin = 1374458400 #07/22/13 00:00:00
    timeMax = 1374703200 #07/25/13 00:00:00
    titlenum=2
if dataset_path == "./golden_dawn" or dataset_path == "./goldendawn_json_origin": 
    timeSeg = [3600*3,3600*6,3600*12,86400]
    timeMin = 1379289600-7200 #05/09/2013 00:00
    timeMax = 1381104000-7200 #07/10/2013 00:00
    titlenum=3
if dataset_path == "./sherlock":
    timeSeg = [3600*3,3600*6,3600*12,86400]
    timeMin = 1388448000-7200 #31/12/2013 00:00
    timeMax = 1389657600-7200 #14/12/2014 00:00
    titlenum=3

'''Functions'''
t = time.time()

if dataextract==1:#If the basic data(authors, mentions, time) has NOT been created
    if not os.path.exists(dataset_path + "/data/nonadaptive/results/"):
        os.makedirs(dataset_path + "/data/nonadaptive/tmp/")
        os.makedirs(dataset_path + "/data/nonadaptive/results/")
    try:
        timeMin
        data = communityranking.from_json(dataset_path, timeSeg, simplify_json,rankIrregularTime,timeMin=timeMin,timeMax=timeMax)
    except NameError:
        data = communityranking.from_json(dataset_path, timeSeg, simplify_json,rankIrregularTime)
    dataPck = open(dataset_path + "/data/nonadaptive/tmp/data.pck", "wb")
    pickle.dump(data, dataPck, protocol = 2)
    dataPck.close()
    elapsed = time.time() - t
    print('Stage 1: %.2f seconds' % elapsed)
    dataEvol=data.evol_detect(prevTimeslots, xLablNum)
    del(data)
    dataEvolPck = open(dataset_path + "/data/nonadaptive/tmp/dataEvol_prev"+str(prevTimeslots)+dataEvol.fileTitle+".pck", "wb")
    pickle.dump(dataEvol, dataEvolPck, protocol = 2)
    dataEvolPck.close()
    elapsed = time.time() - t - elapsed
    print('Stage 2: %.2f seconds' % elapsed)
elif dataextract==2:#If the basic data (authors, mentions, time) has been created
    if not os.path.exists(dataset_path + '/data/nonadaptive/tmp/dataComm_'+fileTitle+'.pck'):
        data = pickle.load(open(dataset_path + "/data/nonadaptive/tmp/data.pck", 'rb'))
    else:
        data = pickle.load(open(dataset_path + '/data/nonadaptive/tmp/dataComm_'+fileTitle+'.pck', "rb"))
    data.dataset_path=dataset_path
    dataEvol=data.evol_detect(prevTimeslots, xLablNum)
    del(data)
    dataEvolPck = open(dataset_path + "/data/nonadaptive/tmp/dataEvol_prev"+str(prevTimeslots)+dataEvol.fileTitle+".pck", "wb")
    pickle.dump(dataEvol, dataEvolPck, protocol = 2)
    dataEvolPck.close()
    elapsed = time.time() - t
    print('Stage 2: %.2f seconds' % elapsed)
else:#Only ranking and heat map creation beyond this point
    fileTitle=["per20mins","per12hours","per45mins","per6hours","per3hours"]
    dataEvol = pickle.load(open(dataset_path + "/data/nonadaptive/tmp/dataEvol_prev"+str(prevTimeslots)+fileTitle[titlenum]+".pck", 'rb'))
    dataEvol.dataset_path=dataset_path

print("Ranking Commences")
rankedCommunities = dataEvol.commRanking(numTopComms, prevTimeslots, xLablNum)
elapsed = time.time() - t
print('Elapsed: %.2f seconds' % elapsed)
