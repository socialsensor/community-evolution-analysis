#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#-------------------------------------------------------------------------------
# Name:
# Purpose:       This .py file extracts adjacency lists and detects communities
#                from the corresponding timeslots.
#
# Required libs: python-dateutil,pyparsing,numpy,matplotlib,networkx
# Author:        konkonst
#
# Created:       20/08/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import json, codecs, os, glob, time, dateutil.parser, collections, datetime, pickle
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import interactive
from operator import itemgetter
import networkx as nx
import re


class communityranking:
    @classmethod
    def from_json(cls, dataset_path, timeSeg, simplify_json, rankIrregularTime, timeMin = 0, timeMax = time.time()):
        '''Make temp folder if non existant'''
        if not os.path.exists(dataset_path + "/data/adaptive/results/forGephi"):
            os.makedirs(dataset_path + "/data/adaptive/results/forGephi")
        if not os.path.exists(dataset_path + "/data/adaptive/results/simplified_json"):
            os.makedirs(dataset_path + "/data/adaptive/results/simplified_json")

        #Get filenames from json dataset path
        files = glob.glob(dataset_path + "/data/json/*.json")
        files.sort(key=os.path.getmtime)

        '''Parse the json files into authors/mentions/alltime/tags/tweetIds/text lists'''
        authors, mentions, alltime, tags, tweetIds, twText, tweetUrls = [], [], [], [], [], [], []
        counter, totTweets, totMentTws, totNonMentTws, totMents, hashes, urlCount = 0, 0, 0, 0, 0, 0, 0
        for filename in files:
            if simplify_json == 1:
                my_txt = codecs.open(dataset_path + "/data/adaptive/results/simplified_json/auth_ment_time_text_" + str(counter) + ".txt","w",'utf-8-sig')#file containing author mentioned time text
                counter += 1
                # print(filename)
            # my_file = open(filename, "r")#, encoding="latin-1")
            with open(filename, "r") as f:
                for line in f:
                    read_line = line.strip().encode('utf-8')
                    json_line = json.loads(read_line.decode('utf-8'))
                    if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
                        continue
                    else:
                        dt = dateutil.parser.parse(json_line["created_at"])
                        mytime = int(time.mktime(dt.timetuple()))
                        if mytime >= timeMin and mytime <= timeMax:
                            if json_line["entities"]["user_mentions"] and json_line["user"]["screen_name"]:
                                totMentTws += 1
                                len_ment = len(json_line["entities"]["user_mentions"])
                                tmpMents = []
                                for i in range(len_ment):
                                    totMents += 1
                                    authors.append(json_line["user"]["screen_name"])
                                    mentions.append(json_line["entities"]["user_mentions"][i]["screen_name"])
                                    alltime.append(mytime)
                                    tmpMents.append(json_line["entities"]["user_mentions"][i]["screen_name"])
                                    tweetIds.append(json_line["id_str"])
                                    twText.append(json_line['text'])
                                    if json_line["entities"]["hashtags"]:
                                        tmp = []
                                        for textIdx in json_line["entities"]["hashtags"]:
                                            hashes += 1
                                            tmp.append(textIdx["text"])
                                        tags.append(tmp)
                                    else:
                                        tags.append([])
                                    if json_line["entities"]["urls"]:
                                        tmp = []
                                        for textIdx in json_line["entities"]["urls"]:
                                            urlCount += 1
                                            tmp.append(textIdx["expanded_url"])
                                        tweetUrls.append(tmp)
                                    else:
                                        tweetUrls.append([])
                                if simplify_json == 1:
                                    my_text = json_line["text"].replace("\n", "")#.replace('\u200F',"").replace('\u2764','').replace('\u2033',"").replace(
                                        #'\u20aa', "").replace('\x92', "").replace('\u200b', "").replace('\u200e', "").replace(
                                        #'\u203c', "").replace('\u2002', "").replace('\u2009', "").replace('\u2049',"").replace('\u200a',"").encode()
                                    my_txt.write(json_line["user"]["screen_name"] + "\t" + ",".join(tmpMents) + "\t" + "\"" + json_line["created_at"] + "\"" + "\t" + str(my_text) + "\n")
                            else:
                                totNonMentTws += 1
                            totTweets += 1
            # else:
            f.close()
            if simplify_json == 1:
                my_txt.close()
        statsfile = open(dataset_path + "/data/adaptive/results/basicstats.txt",'w')
        statement = ('Total # of Tweets= ' + str(totTweets) + '\nTotal # of Tweets with mentions: ' +
            str(totMentTws) + '\nTotal # of Tweets without mentions: ' + str(totNonMentTws) +
            '\nTotal # of edges: ' + str(totMents) +
            '\nTotal # of hashtags: ' + str(hashes) +
            '\nTotal # of urls: ' + str(urlCount) + '\n')
        print(statement)
        statsfile.write(statement)
        statsfile.close()

        if rankIrregularTime==1:
            zippedall=zip(alltime,authors,mentions,twText, tags, tweetIds, twText, tweetUrls)
            zippedall=sorted(zippedall)
            alltime, authors, mentions, twText, tags, tweetIds, twText, tweetUrls=zip(*zippedall)
            alltime, authors, mentions, twText, tags, tweetIds, twText, tweetUrls = list(alltime), list(authors), list(mentions), list(twText), list(tags), list(tweetIds), list(twText), list(tweetUrls)

        return cls(authors, mentions, alltime, tags, tweetIds, twText, tweetUrls, dataset_path, timeSeg)

    @classmethod
    def from_txt(cls, dataset_path, timeSeg):
        '''Make temp folder if non existant'''
        if not os.path.exists(dataset_path + "/data/adaptive/results/forGephi"):
            os.makedirs(dataset_path + "/data/adaptive/results/forGephi")

        #Get filenames from txt dataset path
        files = glob.glob(dataset_path + "/data/adaptive/txt/*.txt")
        files.sort(key=os.path.getmtime)

        '''Parse the txt files into authors/mentions/alltime lists'''
        authors, mentions, alltime, tags = [], [], [], []
        for filename in files:
            print(filename)
            my_file = open(filename, "r")#, encoding="latin-1")
            read_line = my_file.readline()
            while read_line:
                read_line = str(read_line)#, encoding='utf8' )
                splitLine = read_line.split("\t")
                dt = dateutil.parser.parse(splitLine[2], fuzzy="True")
                mytime = int(time.mktime(dt.timetuple()))
                tmp = list(set(part[1:] for part in splitLine[3].split() if part.startswith('#')))
                for tmpmentions in splitLine[1].split(","):
                    authors.append(splitLine[0])
                    mentions.append(tmpmentions)
                    alltime.append(mytime)
                    tags.append(tmp)
                read_line = my_file.readline()
            else:
                my_file.close()
        return cls(authors, mentions, alltime, tags, dataset_path, timeSeg)

    def __init__(self, authors, mentions, alltime, tags, tweetIds, twText, tweetUrls, dataset_path, timeSeg):
        self.authors = authors
        self.mentions = mentions
        self.alltime = alltime
        self.tags = tags
        self.tweetIds = tweetIds
        self.twText = twText
        self.tweetUrls = tweetUrls
        self.dataset_path = dataset_path
        self.timeSeg = timeSeg
        self.uniqueUsers = {}
        self.userPgRnkBag = {}
        self.commPgRnkBag = {}
        self.commStrBag = {}
        self.commNumBag = {}
        self.tagBag = {}
        self.tweetIdBag = {}
        self.tweetTextBag = {}
        self.urlBag = {}
        self.degreeBag = {}
        self.commDegreenessBag = {}
        self.commBetweenessBag = {}

    def extraction(self):
        '''Extract adjacency lists,mats,user and community centrality and communities bags'''
        import community
        #Compute the first derivative and the point of timeslot separation
        firstderiv, mentionLimit = self.timeslotselection(self.authors, self.mentions, self.alltime)

        #Split time according to the first derivative of the users' activity#
        sesStart, timeslot, timeLimit,commCount = 0, 0, [self.alltime[0]],0
        print("Forming timeslots")
        for k in range(len(mentionLimit)):
            if firstderiv[k] < 0 and firstderiv[k + 1] >= 0:
                #make timeslot timelimit array
                timeLimit.append(self.alltime[int(mentionLimit[k])])
                fileNum = '{0}'.format(str(timeslot).zfill(2))
                # print("Forming Timeslot Data "+str(timeslot)+" at point "+str(k))
                sesEnd = int(mentionLimit[k] + 1)

                #Make pairs of users with weights
                usersPair = list(zip(self.authors[sesStart:sesEnd], self.mentions[sesStart:sesEnd]))

                #Create weighted adjacency list
                weighted = collections.Counter(usersPair)
                weighted = list(weighted.items())
                adjusrs, weights = zip(*weighted)
                adjauthors, adjments = zip(*adjusrs)
                adjList = list(zip(adjauthors, adjments, weights))

                #Write pairs of users to txt file for Gephi
                my_txt = open(self.dataset_path + "/data/adaptive/results/forGephi/usersPairs_" + fileNum + ".txt", "w")#
                my_txt.write("Source,Target,Weight" + "\n")
                for line in adjList:
                    my_txt.write(",".join(str(x) for x in line) + "\n")
                my_txt.close()

                #create dictionaries of text per user, of urls per user,
                #of tweet Ids per user and of tags per user
                tmptweetText = self.twText[sesStart:sesEnd]
                self.tweetTextBag[timeslot] = {}
                tmpUrls = self.tweetUrls[sesStart:sesEnd]
                self.urlBag[timeslot] = {}
                tmptweetids = self.tweetIds[sesStart:sesEnd]
                self.tweetIdBag[timeslot] = {}
                tmptags = self.tags[sesStart:sesEnd]
                self.tagBag[timeslot] = {}
                for authIdx, auth in enumerate(self.authors[sesStart:sesEnd]):
                    if auth not in self.tweetTextBag[timeslot]:
                        self.tweetTextBag[timeslot][auth] = []
                    if tmptweetText[authIdx]:
                        self.tweetTextBag[timeslot][auth].append(tmptweetText[authIdx])
                    if auth not in self.urlBag[timeslot]:
                        self.urlBag[timeslot][auth] = []
                    if tmpUrls[authIdx]:
                        for multUrls in tmpUrls[authIdx]:
                            self.urlBag[timeslot][auth].append(multUrls)
                    if auth not in self.tweetIdBag[timeslot]:
                        self.tweetIdBag[timeslot][auth] = []
                    if tmptweetids[authIdx]:
                        self.tweetIdBag[timeslot][auth].append(tmptweetids[authIdx])
                    if auth not in self.tagBag[timeslot]:
                        self.tagBag[timeslot][auth] = []
                    if tmptags[authIdx]:
                        self.tagBag[timeslot][auth].append(tmptags[authIdx])
                for mentIdx, ment in enumerate(self.mentions[sesStart:sesEnd]):
                    if ment not in self.tweetTextBag[timeslot]:
                        self.tweetTextBag[timeslot][ment] = []
                    if tmptweetText[mentIdx]:
                        self.tweetTextBag[timeslot][ment].append(tmptweetText[mentIdx])
                    if ment not in self.tweetIdBag[timeslot]:
                        self.tweetIdBag[timeslot][ment] = []
                    if tmptweetids[mentIdx]:
                        self.tweetIdBag[timeslot][ment].append(tmptweetids[mentIdx])

                #Construct networkX graph
                tempDiGraph = nx.DiGraph()
                tempDiGraph.add_weighted_edges_from(adjList)
                tempDiGraph.remove_edges_from(tempDiGraph.selfloop_edges())
                tempGraph = nx.Graph()
                tempGraph.add_weighted_edges_from(adjList)
                tempGraph.remove_edges_from(tempGraph.selfloop_edges())

                #Extract the centrality of each user using the PageRank algorithm
                tempUserPgRnk = nx.pagerank(tempDiGraph, alpha=0.85, max_iter=100, tol=0.001)
                maxPGR=max((pgr for k,(pgr) in tempUserPgRnk.items()))
                for k in tempUserPgRnk.items():
                    tempUserPgRnk[k[0]]/=maxPGR
                self.userPgRnkBag[timeslot] = tempUserPgRnk

                #Detect Communities using the louvain algorithm#
                partition = community.best_partition(tempGraph)
                inv_partition = {}
                for k, v in partition.items():
                    inv_partition[v] = inv_partition.get(v, [])
                    inv_partition[v].append(k)
                    inv_partition[v].sort()
                strComms = [inv_partition[x] for x in inv_partition]
                strComms.sort(key=len, reverse=True)
                commCount+=len(strComms)

                #Construct Communities of uniqueUsers indices and new community dict with size sorted communities
                numComms, new_partition = [], {}
                for c1, comms in enumerate(strComms):
                    numpart = []
                    for ids in comms:
                        numpart.extend(self.uniqueUsers[ids])
                        new_partition[ids] = c1
                    numpart.sort()
                    numComms.append(numpart)
                newinv_partition = {}
                for k, v in new_partition.items():
                    newinv_partition[v] = newinv_partition.get(v, [])
                    newinv_partition[v].append(k)
                    newinv_partition[v].sort()

                #Construct a graph using the communities as users
                tempCommGraph = community.induced_graph(new_partition, tempDiGraph)
                self.commGraph=tempCommGraph

                #Detect the centrality of each community using the PageRank algorithm
                commPgRnk = nx.pagerank(tempCommGraph, alpha=0.85, max_iter=100, tol=0.001)
                maxCPGR = max((cpgr for k, (cpgr) in commPgRnk.items()))
                commPgRnkList = []
                for key, value in commPgRnk.items():
                    commPgRnkList.append(value/maxCPGR)
                self.commPgRnkBag[timeslot] = commPgRnkList

                #Detect the centrality of each community using the degree centrality algorithm
                commDegreeness = nx.degree_centrality(tempCommGraph)
                maxCDeg = max((cpgr for k, (cpgr) in commDegreeness.items()))
                commDegreenessList = []
                for key, value in commDegreeness.items():
                    commDegreenessList.append(value/maxCDeg)
                self.commDegreenessBag[timeslot] = commDegreenessList

                #Detect the centrality of each community using the betweeness centrality algorithm
                commBetweeness = nx.betweenness_centrality(tempCommGraph)
                maxCBet = max((cpgr for k, (cpgr) in commBetweeness.items()))
                commBetweennessList = []
                for key, value in commBetweeness.items():
                    commBetweennessList.append(value/maxCDeg)
                self.commBetweenessBag[timeslot] = commBetweennessList

                #Extract community degree
                degreelist=[]
                for k in range(len(tempCommGraph.edge)):
                    tmpdeg=tempCommGraph.degree(k)
                    degreelist.append(tmpdeg)
                degreelist=[x/max(degreelist) for x in degreelist]
                self.degreeBag[timeslot]=degreelist

                '''Construct Community Dictionary'''
                self.commStrBag[timeslot] = strComms
                self.commNumBag[timeslot] = numComms
                sesStart = sesEnd
                timeslot += 1

        day_month = [datetime.datetime.fromtimestamp(int(x)).strftime(self.labelstr) for x in timeLimit]
        self.day_month = day_month
        self.timeLimit = [datetime.datetime.fromtimestamp(int(x)).strftime(self.labelstr) for x in timeLimit]
        statement = '\nTotal # of communities is '+str(commCount) + '\n'
        statsfile = open(self.dataset_path + "/data/adaptive/results/basicstats.txt",'a')
        print(statement)
        statsfile.write(statement)
        statsfile.close()

        dataCommPck = open(self.dataset_path + '/data/adaptive/tmp/dataComm_'+str(self.fileTitle)+'.pck','wb')
        pickle.dump(self, dataCommPck , protocol = 2)
        dataCommPck.close()

    def timeslotselection(self, authors, mentions, alltime):
        ###Parsing commences###

        # Create time segments a human can understand
        humanTimeSegs=[]
        for idx,seg in enumerate(self.timeSeg):
            if seg <3600:
                timeNum = seg / 60
                timeTitle = " mins"
                humanTimeSegs.append(str(idx+1)+'> '+str(round(timeNum))+timeTitle)
            elif seg >= 3600 and seg < 86400:
                timeNum = seg / 3600
                timeTitle = " hours"
                humanTimeSegs.append( str(idx+1)+'> '+str(round(timeNum))+timeTitle)
            elif seg >= 86400 and seg < 604800:
                timeNum = seg / 86400
                timeTitle = " days"
                humanTimeSegs.append(str(idx+1)+'> '+str(round(timeNum))+timeTitle)
            elif seg / 86400 == 1:
                timeTitle = " day"
                humanTimeSegs.append(str(idx+1)+'> '+str(round(timeNum))+timeTitle)
            elif seg >= 604800 and seg < 2592000:
                timeNum = seg / 604800
                timeTitle = " weeks"
                humanTimeSegs.append(str(idx+1)+'> '+str(round(timeNum))+timeTitle)
            else:
                timeNum = seg / 2592000
                timeTitle = " months"
                humanTimeSegs.append(str(idx+1)+'> '+str(round(timeNum))+timeTitle)

        #Extract unique users globally and construct dictionary
        # usrs = list(set(np.append(authors, mentions)))
        usrs = authors.copy()
        usrs.extend(mentions)
        usrs = list(set(usrs))
        usrs.sort()
        uniqueUsers, counter1 = {}, 0
        for tmpusrs in usrs:
            uniqueUsers[tmpusrs] = [counter1]
            counter1 += 1
        self.uniqueUsers = uniqueUsers
        statement = "Total # of unique users: "+ str(len(uniqueUsers)) + '\n'
        statsfile = open(self.dataset_path + "/data/adaptive/results/basicstats.txt",'a')
        print(statement)
        statsfile.write(statement)
        statsfile.close()

        #Find time distance between posts#
        time2 = np.append(alltime[0], alltime)
        time2 = time2[0:len(time2) - 1]
        timeDif = alltime - time2
        lT = len(alltime)

        '''Extract the first derivative'''
        font = {'size': 14}
        plt.rc('font', **font)
        fig = plt.figure()#figsize=(10,8)
        plotcount, globfirstderiv, globmentionLimit = 0, {}, {}
        for seg in self.timeSeg:

            if seg <3600:
                timeNum = seg / 60
                timeTitle = " mins"
                labelstr = '%Hh/%d'
            elif seg >= 3600 and seg < 86400:
                timeNum = seg / 3600
                timeTitle = " hours"
                labelstr = '%Hh/%d'
            elif seg >= 86400 and seg < 604800:
                timeNum = seg / 86400
                timeTitle = " days"
                labelstr = '%d/%b'
            elif seg / 86400 == 1:
                timeTitle = " day"
                labelstr = '%d/%b'
            elif seg >= 604800 and seg < 2592000:
                timeNum = seg / 604800
                timeTitle = " weeks"
                labelstr = '%b/%y'
            else:
                timeNum = seg / 2592000
                timeTitle = " months"
                labelstr = '%b/%y'

            curTime, bin, freqStat, mentionLimit, timeLabels = 0, 0, [0], [], []
            for i in range(lT):
                curTime += timeDif[i]
                if curTime <= seg:
                    freqStat[bin] += 1
                else:
                    curTime = 0
                    mentionLimit = np.append(mentionLimit, i)
                    timeLabels = np.append(timeLabels, datetime.datetime.fromtimestamp(alltime[i]).strftime(labelstr))
                    bin += 1
                    freqStat = np.append(freqStat, 0)
            mentionLimit = np.append(mentionLimit, i)
            timeLabels = np.append(timeLabels, datetime.datetime.fromtimestamp(alltime[-1]).strftime(labelstr))
            freqStatIni = np.zeros(len(freqStat) + 1)
            freqStatMoved = np.zeros(len(freqStat) + 1)
            freqStatIni[0:len(freqStat)] = freqStat
            freqStatMoved[1:len(freqStat) + 1] = freqStat
            firstderiv = freqStatIni - freqStatMoved
            firstderiv[len(firstderiv) - 1] = 0

            globfirstderiv[seg] = firstderiv
            globmentionLimit[seg] = mentionLimit

            plotcount += 1

            if len(self.timeSeg) < 3:
                ax = fig.add_subplot(2, int(np.ceil(len(self.timeSeg) / 2)), plotcount, autoscale_on=True)
            else:
                ax = fig.add_subplot(int(np.ceil(len(self.timeSeg) / 2)), 2, plotcount, autoscale_on=True)
            plt.grid(axis='x')
            plt.plot(freqStat, 'b-', hold=True)
            plt.ylabel("User activity (mentions)")
            plt.xlabel("Init. time: " + datetime.datetime.fromtimestamp(int(self.alltime[0])).strftime('%d/%m/%y')+ ", Last point:"+ datetime.datetime.fromtimestamp(int(self.alltime[-1])).strftime('%d/%m/%y') + " (Ts:" + str(round(timeNum)) + timeTitle + ")")
            poi = []
            for k in range(len(mentionLimit)):
                if firstderiv[k] < 0 <= firstderiv[k + 1]:
                    poi = np.append(poi, k)
            poi = np.int32(poi)
            plt.plot(poi, freqStat[poi], 'ro', hold=True)
            pertick=np.ceil(len(freqStat)/self.xLablNum)
            ax.set_xticks(np.arange(0, len(freqStat), pertick))#, minor=False)
            ax.set_xticklabels(timeLabels[0:-1:pertick], minor=False, fontsize = 14, rotation = 35)
            plt.xlim(xmax=(len(freqStat)))
        mng = plt.get_current_fig_manager()
        mng.resize(*mng.window.maxsize())
        interactive(True)
        plt.show()
        plt.savefig(self.dataset_path + "/data/adaptive/results/user_activity_mentions.pdf", bbox_inches='tight', format='pdf')
        timeSegInput = int(input("Please select sampling time: \n" + str(humanTimeSegs)))
        timeSegInput=self.timeSeg[timeSegInput-1]
        plt.close()
        del(fig,self.timeSeg)
        if timeSegInput < 3600:
            timeNum = timeSegInput / 60
            timeTitle = "per" + str(int(timeNum)) + "mins"
            labelstr = '%Hh/%d'
        elif timeSegInput >= 3600 and timeSegInput < 86400:
            timeNum = timeSegInput / 3600
            timeTitle = "per" + str(int(timeNum)) + "hours"
            labelstr = '%Hh/%d'
        elif timeSegInput >= 86400 and timeSegInput < 604800:
            timeNum = timeSegInput / 86400
            timeTitle = "per" + str(int(timeNum)) + "days"
            labelstr = '%d/%b'
        elif timeSegInput>= 604800 and timeSegInput < 2592000:
            timeNum = timeSegInput / 604800
            timeTitle = "per" + str(int(timeNum)) + "weeks"
            labelstr = '%b/%y'
        else:
            timeNum = timeSegInput / 2592000
            timeTitle = "per" + str(int(timeNum)) + "months"
            labelstr = '%b/%y'

        self.fileTitle = timeTitle
        self.labelstr = labelstr
        firstderiv = globfirstderiv[timeSegInput]
        mentionLimit = globmentionLimit[timeSegInput]
        return firstderiv, mentionLimit

    def evol_detect(self, prevTimeslots, xLablNum):
        self.xLablNum=xLablNum
        self.extraction()

        """Construct Community Dictionary"""
        commNumBag2 = {}
        commSizeBag = {}
        timeslots = len(self.commNumBag)
        self.timeslots=timeslots
        lC = [] #Number of communities>2people for each timeslot
        for cBlen in range(timeslots):
            commNumBag2[cBlen] = [x for x in self.commNumBag[cBlen] if len(x) > 2]
            commSizeBag[cBlen] = [len(x) for x in self.commNumBag[cBlen] if len(x) > 2]
            lC.append(len(commNumBag2[cBlen]))

        self.commPerTmslt=lC

        commIds = []
        # name the first line of communities
        commIds.append([])
        for j in range(lC[0]):
            # commIds[str(0)+","+str(j)]=str(0)+','+str(j)
            commIds[0].append(str(0) + ',' + str(j))
        #Detect any evolution and name the evolving communities
        #uniCommIdsEvol is structured as such {'Id':[rowAppearence],[commCentrality],[commSize],[users]}
        tempUniCommIds, evolcounter, uniCommIdsEvol, commCntr= [], 0, {}, 0
        print('Community similarity search for each timeslot: ')
        for rows in range(1, timeslots):
        # print('Community similarity search for timeslot: '+str(rows))
            commIds.append([])
            for clmns in range(lC[rows]):
                idx = str(rows) + "," + str(clmns)
                bag1 = commNumBag2[rows][clmns]
                tempcommSize = len(bag1)
                if tempcommSize <= 7 and tempcommSize > 2:
                    thres = .41
                elif tempcommSize <= 11 and tempcommSize > 7:
                    thres = .27
                elif tempcommSize <= 20 and tempcommSize > 11:
                    thres = .2
                elif tempcommSize <= 49 and tempcommSize > 20:
                    thres = .15
                elif tempcommSize <= 79 and tempcommSize > 49:
                    thres = .125
                elif tempcommSize <= 499 and tempcommSize > 79:
                    thres = .1
                else:
                    thres = .05
                for invrow in range(1, prevTimeslots + 1):
                    prevrow = rows - invrow
                    tmpsim = []
                    if prevrow >= 0:
                        for prevComms in commNumBag2[prevrow]:
                            if thres > (len(prevComms) / tempcommSize):
                                break
                            elif thres > (tempcommSize / len(prevComms)):
                                tmpsim.append(0)
                                continue
                            else:
                                tmpsim.append(len(list(set(bag1) & set(prevComms))) / len(set(np.append(bag1, prevComms))))
                        if tmpsim:
                            maxval = max(tmpsim)
                        else:
                            maxval = 0
                        if maxval >= thres:
                            evolcounter += 1
                            maxIdx = tmpsim.index(maxval)
                            tempUniCommIds.append(commIds[prevrow][maxIdx])
                            if commIds[prevrow][maxIdx] not in uniCommIdsEvol:
                                uniCommIdsEvol[commIds[prevrow][maxIdx]] = [[], [], [], [], [], [], [], []]
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][0].append(prevrow)#timeslot num for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][1].append(self.commPgRnkBag[prevrow][maxIdx])#community pagerank for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][2].append(commSizeBag[prevrow][maxIdx])#community size per timeslot for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][3].append(self.commStrBag[prevrow][maxIdx])#users in each community for first evolution
                                # uniCommIdsEvol[commIds[prevrow][maxIdx]][4].append(self.degreeBag[prevrow][maxIdx])#community degree for first evolution
                                # uniCommIdsEvol[commIds[prevrow][maxIdx]][5].append(self.commDegreenessBag[prevrow][maxIdx])#community degree centrality for first evolution
                                # uniCommIdsEvol[commIds[prevrow][maxIdx]][6].append(self.commBetweenessBag[prevrow][maxIdx])#community betweeness centrality for first evolution
								#uniCommIdsEvol[commIds[prevrow][maxIdx]][7].append(0)
                                commCntr+=1
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][0].append(rows)#timeslot num
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][1].append(self.commPgRnkBag[rows][clmns])#community pagerank per timeslot
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][2].append(commSizeBag[rows][clmns])#community size per timeslot
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][3].append(self.commStrBag[rows][clmns])#users in each community
                            # uniCommIdsEvol[commIds[prevrow][maxIdx]][4].append(self.degreeBag[rows][clmns])#community degree per timeslot
                            # uniCommIdsEvol[commIds[prevrow][maxIdx]][5].append(self.commDegreenessBag[rows][clmns])#community degree centrality per timeslot
                            # uniCommIdsEvol[commIds[prevrow][maxIdx]][6].append(self.commBetweenessBag[rows][clmns])#community betweeness centrality per timeslot
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][7].append(maxval)#similarity between the two communities in evolving timesteps
                            commIds[rows].append(commIds[prevrow][maxIdx])
                            commCntr+=1
                            break
                if maxval < thres:
                    commIds[rows].append(str(rows) + ',' + str(clmns))
        uniCommIds = list(set(tempUniCommIds))
        uniCommIds.sort()

        self.uniCommIds,self.uniCommIdsEvol=uniCommIds,uniCommIdsEvol

        del(commIds,self.alltime,self.authors,self.mentions,self.commStrBag,self.commNumBag,self.commBetweenessBag,self.commDegreenessBag,commSizeBag,self.degreeBag)#,self.commPgRnkBag)

        statement = (str(evolcounter) + " evolutions and " + str(len(uniCommIds)) + " dynamic communities and " + str(commCntr)+" evolving communities" + '\n')
        statsfile = open(self.dataset_path + "/data/adaptive/results/basicstats.txt",'a')
        print(statement)
        statsfile.write(statement)
        statsfile.close()
        return self

    def commRanking(self,numTopComms, prevTimeslots,xLablNum):
        import itertools, tfidf 
        # from pymongo import MongoClient
        # from nltk.corpus import stopwords
        from wordcloud import  make_wordcloud
        from PIL import Image

        '''Detect the evolving communities'''
        uniCommIdsEvol=self.uniCommIdsEvol
        timeslots=self.timeslots

        tempcommRanking = {}
        #structure: tempcommRanking={Id:[persistence,stability,commCentrality,degreeness]}
        commRanking,fluctuation,lifetime = {},{},0
        for Id in self.uniCommIds:
            uniqueTimeSlLen = len(set(uniCommIdsEvol[Id][0]))
            timeSlLen=len(uniCommIdsEvol[Id][0])
            tempcommRanking[Id] = []
            tempcommRanking[Id].append(uniqueTimeSlLen / timeslots)#persistence
            tempcommRanking[Id].append((sum(np.diff(list(set(uniCommIdsEvol[Id][0]))) == 1) + 1) / (timeslots + 1))#stability
            tempcommRanking[Id].append(product([x+1 for x in uniCommIdsEvol[Id][1]]) / uniqueTimeSlLen)#commCentrality
            # tempcommRanking[Id].append(sum(uniCommIdsEvol[Id][4]) / timeslots)#Degreeness
            # tempcommRanking[Id].append(sum(uniCommIdsEvol[Id][5])/timeSlLen)#degree centrality
            # tempcommRanking[Id].append(sum(uniCommIdsEvol[Id][6])/timeSlLen)#betweeness centrality
            # '''Checking Theseus Ship'''
            # theseus=1+len(list(set(uniCommIdsEvol[Id][3][0]) & set(uniCommIdsEvol[Id][3][-1]))) / len(set(np.append(uniCommIdsEvol[Id][3][0], uniCommIdsEvol[Id][3][-1])))
            # tempcommRanking[Id].append(theseus)
            commRanking[Id] = np.prod(tempcommRanking[Id])

            #Construct average jaccardian between timeslots for each dyn comm
            if timeSlLen not in fluctuation:
                fluctuation[timeSlLen]=[(sum(uniCommIdsEvol[Id][7])/(timeSlLen-1))] #[1-sum(np.diff(list(set(uniCommIdsEvol[Id][0]))) == 1)/(lifetime-1)]
            else:
                fluctuation[timeSlLen].append((sum(uniCommIdsEvol[Id][7])/(timeSlLen-1)))#1-sum(np.diff(list(set(uniCommIdsEvol[Id][0]))) == 1)/(lifetime-1))
            lifetime=max(lifetime,timeSlLen)

        '''All the communities ranked in order of importance'''
        rankedCommunities = sorted(commRanking, key=commRanking.get, reverse=True)
        if numTopComms>len(rankedCommunities):
            numTopComms=len(rankedCommunities)

        '''Jaccardian for lifespans which appear only once are discarded (outliers)'''
        flux=[]
        for lifeT in range(lifetime+1):
            if lifeT in fluctuation and len(fluctuation[lifeT])>1:
                flux.append(sum(fluctuation[lifeT])/len(fluctuation[lifeT]))
            else:
                flux.append(0)

        '''Constructing community size heatmap data'''
        commSizeHeatData = np.zeros([numTopComms, timeslots])
        for rCIdx, comms in enumerate(rankedCommunities[0:numTopComms]):
            for sizeIdx, timesteps in enumerate(uniCommIdsEvol[comms][0]):
                if commSizeHeatData[rCIdx, timesteps] != 0:
                    commSizeHeatData[rCIdx, timesteps] = max(np.log(uniCommIdsEvol[comms][2][sizeIdx]),commSizeHeatData[rCIdx, timesteps])
                else:
                    commSizeHeatData[rCIdx, timesteps] = np.log(uniCommIdsEvol[comms][2][sizeIdx])
        normedHeatdata = commSizeHeatData/commSizeHeatData.max()

        '''Writing ranked communities to json files + MongoDB'''
        dataset_name=self.dataset_path.split('/')
        dataset_name=dataset_name[-1]
        rankedCommunitiesFinal = {}
        twitterDataFile = open(self.dataset_path + '/data/adaptive/results/rankedCommunities.json', "w")#, encoding="utf-8-sig")
        jsondata = dict()
        jsondata["ranked_communities"] = []

        '''Create corpus and stopwords'''
        # stop = stopwords.words('english')
        stop = []
        definiteStop = ['gt','amp','rt','via']
        stop.extend(definiteStop)
        if not os.path.exists(self.dataset_path + "/data/adaptive/tmp/datasetCorpus.pck"):
            idf = self.corpusExtraction(rankedCommunities[:numTopComms])
        else:
            idf = pickle.load(open(self.dataset_path + "/data/adaptive/tmp/datasetCorpus.pck", 'rb'))
            print('loaded corpus from file')
        #-------------------------
        regex1 = re.compile("(?:\@|#|https?\://)\S+",re.UNICODE)
        regex2 = re.compile("\w+'?\w",re.UNICODE)

        width,height = 400,200
        blank_image = Image.new("RGB", (timeslots*width, (numTopComms*2+2)*height),(255,255,255)) #make blank for colage
        for tmptime in range(timeslots):
            timeimage = make_wordcloud([self.timeLimit[tmptime],'the date'],[10,2], width=width, height=height)
            blank_image.paste(timeimage, (tmptime*width,height))

        for rank, rcomms in enumerate(rankedCommunities[:numTopComms]):
            tmslUsrs, tmpTags, tmptweetids, commTwText, tmpUrls, topic, tmpkeywrds = [], [], [], [], [], [], []
            strRank = '{0}'.format(str(rank).zfill(2))
            rankedCommunitiesFinal[strRank] = [rcomms]
            rankedCommunitiesFinal[strRank].append(commRanking[rcomms])
            rankedCommunitiesFinal[strRank].append(uniCommIdsEvol[rcomms][3])
            timeSlotApp = [self.timeLimit[x] for x in uniCommIdsEvol[rcomms][0]]

            '''make and save wordclouds'''
            if not os.path.exists(self.dataset_path + "/data/adaptive/results/wordclouds/"+self.fileTitle+'/'+str(rank)):
                os.makedirs(self.dataset_path + "/data/adaptive/results/wordclouds/"+self.fileTitle+'/'+str(rank))

            for tmsl, users in enumerate(uniCommIdsEvol[rcomms][3]):
                uscentr, tmptweetText = [], []
                for us in users:
                    uscentr.append([us, self.userPgRnkBag[uniCommIdsEvol[rcomms][0][tmsl]][us]])
                    # uscentr = sorted(uscentr, key=itemgetter(1), reverse=True)
                    if us in self.tagBag[uniCommIdsEvol[rcomms][0][tmsl]]:
                        tmpTags.extend(self.tagBag[uniCommIdsEvol[rcomms][0][tmsl]][us])
                    if us in self.urlBag[uniCommIdsEvol[rcomms][0][tmsl]]:
                        tmpUrls.append(self.urlBag[uniCommIdsEvol[rcomms][0][tmsl]][us])
                    if us in self.tweetIdBag[uniCommIdsEvol[rcomms][0][tmsl]]:
                        tmptweetids.extend(self.tweetIdBag[uniCommIdsEvol[rcomms][0][tmsl]][us])
                    if us in self.tweetTextBag[uniCommIdsEvol[rcomms][0][tmsl]]:
                        tmptweetText.extend(self.tweetTextBag[uniCommIdsEvol[rcomms][0][tmsl]][us])
                uscentr = sorted(uscentr, key=itemgetter(1), reverse=True)
                tmslUsrs.append({str(uniCommIdsEvol[rcomms][0][tmsl]): uscentr})
                tmptweetText = [i.replace("\n", "").replace('\t',' ') for i in tmptweetText]
                seen = set()
                seen_add = seen.add
                tmptweetText2 = [x for x in tmptweetText if x not in seen and not seen_add(x)]
                commTwText.append({timeSlotApp[tmsl]: tmptweetText2})
                #topic extraction
                topicList = " ".join(tmptweetText2)
                topicList = topicList.lower()
                topicList = regex1.sub('', topicList)
                topicList = regex2.findall(topicList)
                topicList = collections.Counter(topicList)
                tmpkeys = topicList.keys()
                if len(topicList)>5:
                    for i in list(tmpkeys):
                            if not i or i in stop or i.startswith(('htt','(@','t.co')) or len(i)<=2:
                                del topicList[i]
                else:
                    for i in list(tmpkeys):
                        if i in definiteStop or not i:
                            del topicList[i]

                timeSlLen=len(uniCommIdsEvol[Id][0])
                tmpTopic=tfidf.comm_tfidf(topicList,idf,10)
                topic.append({timeSlotApp[tmsl]: tmpTopic})
                # tmpTopic = [x[0] for x in tmpTopic]
                '''wordcloud image'''
                popkeys = [x[0] for x in tmpTopic]
                popvals = [x[1] for x in tmpTopic]
                if len(popvals)<2:
                    try:
                        if popvals[0]<1:
                            popvals[0]=1
                    except:
                        pass
                '''Create intermediate image'''
                position = (rank+1)*2
                backgroundcolor = int((1-(normedHeatdata[rank,uniCommIdsEvol[rcomms][0][tmsl]]))*255)
                locimage = make_wordcloud(popkeys,popvals, width=width, height=height,backgroundweight=backgroundcolor)#, fname=self.dataset_path + '/data/adaptive/results/wordclouds/'+self.fileTitle+'/'+str(rank)+'/'+timeSlotApp[tmsl]+'.pdf'
                blank_image.paste(locimage, (uniCommIdsEvol[rcomms][0][tmsl]*width,position*height))
                popusers = [x[0] for x in uscentr[:10]]
                popcentr = [x[1]*100 for x in uscentr[:10]]
                locimage = make_wordcloud(popusers,popcentr, width=width, height=height,backgroundweight=backgroundcolor)#, fname=self.dataset_path + '/data/adaptive/results/wordclouds/'+self.fileTitle+'/'+str(rank)+'/'+timeSlotApp[tmsl]+'usrs.pdf'
                blank_image.paste(locimage, (uniCommIdsEvol[rcomms][0][tmsl]*width,(position+1)*height))
                # tmpkeywrds.extend(tmpTopic)

            if tmpTags:
                popTags = [x.lower() for x in list(itertools.chain.from_iterable(tmpTags))]
                popTags = collections.Counter(popTags)
                popTags = popTags.most_common(10)
            else:
                popTags=[]
            if tmpUrls:
                if tmpUrls[0]:
                    tmpUrls=[x.lower() for x in list(itertools.chain.from_iterable(tmpUrls)) if x]
                    popUrls = collections.Counter(tmpUrls)
                    popUrls = popUrls.most_common(10)
                else:
                    popUrls=[]
            else:
                    popUrls=[]
            commTweetIds = list(set(tmptweetids))
            # popKeywords = collections.Counter(tmpkeywrds)
            # popKeywords = popKeywords.most_common(10)
            # popkeys = [x[0] for x in popKeywords]
            # popvals = [x[1] for x in popKeywords]
            # make_wordcloud(popkeys,popvals,self.dataset_path + '/data/adaptive/results/wordclouds/'+self.fileTitle+'/'+str(rank)+'.pdf')
            dycco={'community label': rcomms, 'rank': rank, 'timeslot appearance': timeSlotApp,# 'text': commTwText,
                 'persistence:': tempcommRanking[rcomms][0],'total score':commRanking[rcomms],'topic': topic,
                 'stability': tempcommRanking[rcomms][1],'community centrality': tempcommRanking[rcomms][2],
                 'community size per slot': uniCommIdsEvol[rcomms][2], 'users:centrality per timeslot': tmslUsrs,
                 'popTags': popTags, 'popUrls': popUrls}
            jsondycco=dycco.copy()
            # dyccos.insert(dycco)
            jsondata["ranked_communities"].append(jsondycco)
        twitterDataFile.write(json.dumps(jsondata, sort_keys=True))#,ensure_ascii=False).replace("\u200f",""))
        twitterDataFile.close()

        for tmptime in range(timeslots):
            timeimage = make_wordcloud([self.timeLimit[tmptime],'the date'],[10,2])
            blank_image.paste(timeimage, (tmptime*width,(position+2)*height))
        imsize=blank_image.size
        blank_image = blank_image.resize((round(imsize[0]/2),round(imsize[1]/2)),Image.ANTIALIAS)
        blank_image.save(self.dataset_path + "/data/adaptive/results/wordclouds/"+self.fileTitle+'_collage.pdf', quality=50)

        makefigures(commSizeHeatData,flux,self.fileTitle,self.day_month,commRanking,numTopComms,timeslots,uniCommIdsEvol,rankedCommunities,self.commPerTmslt,self.uniCommIds,prevTimeslots,self.dataset_path,self.xLablNum)
        return rankedCommunitiesFinal

    def corpusExtraction(self,rankedCommunities):
        # from nltk.corpus import stopwords
        from math import log

        print('Extracting dataset corpus')
        uniCommIdsEvol=self.uniCommIdsEvol

        # stop = stopwords.words('english')
        stop = ['gt','amp','rt','via']
        textList=[]
        # cntr=0
        regex1 = re.compile("(?:\@|#|https?\://)\S+",re.UNICODE)
        regex2 = re.compile("\w+'?\w",re.UNICODE)
        fullText = [i.replace("\n", " ").replace('\t',' ') for i in self.twText]
        seen = set()
        seen_add = seen.add
        fullText2 = [x for x in fullText if x not in seen and not seen_add(x)]
        for tweets in fullText2:
            tmpTopicCC=[]
            # cntr+=1
            topicList = tweets.lower()
            topicList = regex1.sub('', topicList)
            topicList = regex2.findall(topicList)
            for i in topicList:
                if not i or i.startswith(('htt','(@','t.co')) or len(i)<=1 or i in stop:# 
                    continue
                else:
                    tmpTopicCC.append(i)
            textList.append(tmpTopicCC)
                # print(cntr)
        allWords=set(sum(textList,[]))
        dictTokens={}
        for word in allWords:
            wordCount=0
            for tmptextlist in textList:
                if word in tmptextlist:
                    wordCount+=1
            dictTokens[word]=log(len(fullText2)/(1+wordCount))

        # dictTokens['documentPopulation']=cntr
        dictTokensPck = open(self.dataset_path + "/data/adaptive/tmp/datasetCorpus.pck", "wb") # store the dictionary, for future reference
        pickle.dump(dictTokens, dictTokensPck)
        dictTokensPck.close()
        return dictTokens

def makefigures(commSizeHeatData,flux,fileTitle,day_month,commRanking,numTopComms,timeslots,uniCommIdsEvol,rankedCommunities,commPerTmslt,uniCommIds,prevTimeslots,dataset_path,xLablNum):

    '''Label parameters'''
    pertick=int(np.ceil(timeslots/xLablNum))
    if numTopComms>len(rankedCommunities):
        numTopComms=len(rankedCommunities)
    row_labels = day_month#(range(timeslots))
    column_labels = list(range(numTopComms))
    column_labels2 = rankedCommunities[:numTopComms]

    '''Jaccardian fluctuation/persistance'''
    fig1 = plt.figure()
    plt.stem(flux, linefmt='b-', markerfmt='bo')
    xmin, xmax = plt.xlim()
    plt.xlim( 1, xmax+1 )
    plt.ylabel("Jaccardian Average Fluctuation")
    plt.xlabel('Persistance')
    plt.tight_layout()
    fig1 = plt.gcf()
    plt.draw()
    fig1.savefig(dataset_path + "/data/adaptive/results/jaccardianFlux_prev" + str(prevTimeslots) + fileTitle + ".pdf",bbox_inches='tight', format='pdf')
    plt.close()
    del(fig1)
    print('Finished with flactuation fig')

    '''Number of communities/timeslot'''
    fig3, ax3 = plt.subplots()
    ax3.plot(commPerTmslt, 'b-')
    ax3.set_xticks(np.arange(0,len(commPerTmslt),pertick), minor=False)
    ax3.set_xticklabels(row_labels[0:-1:pertick], minor=False, fontsize=7, rotation = 30)
    for tick in ax3.yaxis.get_major_ticks():
        tick.label.set_fontsize(7)
    xmin, xmax = plt.xlim()
    plt.xlim( 1, xmax+1 )
    plt.ylabel("Community Number Fluctuation")
    plt.xlabel('Timeslots')
    plt.tight_layout()
    fig3 = plt.gcf()
    plt.draw()
    fig3.savefig(dataset_path + "/data/adaptive/results/commNumberFlux_prev" + str(prevTimeslots) + fileTitle + ".pdf",bbox_inches='tight', format='pdf')
    plt.close()
    del(fig3)
    print('Finished with number of communities\' fluctuation fig')

    '''Make community size evolution heatmap'''
    fig2, ax = plt.subplots()
    heatmap = ax.pcolormesh(commSizeHeatData, cmap=plt.cm.gist_gray_r)
    ax.set_xticks(np.arange(0,commSizeHeatData.shape[1],pertick), minor=False)
    plt.xlim(xmax=timeslots)
    ax.xaxis.tick_top()
    ax.set_xticklabels(row_labels[0:-1:pertick], minor=False,fontsize=8)
    ax.set_yticks(np.arange(commSizeHeatData.shape[0]), minor=False)
    plt.ylim(ymax=numTopComms)
    ax.invert_yaxis()
    ax.set_yticklabels(column_labels, minor=False, fontsize=7)
    plt.ylabel("Ranked Communities (Best " + str(numTopComms) + ")")
    ax2 = ax.twinx()
    ax2.set_yticks(np.arange(commSizeHeatData.shape[0]), minor=False)
    plt.ylim(ymax=numTopComms)
    ax2.invert_yaxis()
    ax2.set_yticklabels(column_labels2, minor=False, fontsize=7)
    plt.xlabel('Timeslot', {'verticalalignment': 'top'})

    if numTopComms < 101:
        plt.grid(axis='y')
    fig2 = plt.gcf()
    plt.tight_layout()
    mng = plt.get_current_fig_manager()
    mng.resize(*mng.window.maxsize())
    plt.show()
    fig2.savefig(dataset_path + "/data/adaptive/results/communitySizeHeatmap_prev" + str(prevTimeslots) + fileTitle + ".pdf",bbox_inches='tight', format='pdf')
    plt.close()
    print('Finished with heat map fig')

    '''CommCentrality flux'''
    font = {'size': 12}
    plt.rc('font', **font)
    fig4, ax4 = plt.subplots()
    colormap = plt.cm.gist_ncar
    plt.gca().set_color_cycle([colormap(i) for i in np.linspace(0, 0.9, len(uniCommIds))])
    for Id in uniCommIds:
        commCentr = [0]*timeslots
        myxaxis=[]
        for idx,timesteps in enumerate(uniCommIdsEvol[Id][0]):
            if not commCentr[timesteps]:
                commCentr[timesteps] = (uniCommIdsEvol[Id][1][idx])
                myxaxis.append(timesteps)
            else:
                commCentr[timesteps] = max((uniCommIdsEvol[Id][1][idx]),commCentr[timesteps])
        commCentrNew=[]
        for x in commCentr:
            if x:
                commCentrNew.append(x)
        # plt.xlim(uniCommIdsEvol[Id][0][0],uniCommIdsEvol[Id][0][-1])

        plt.plot(myxaxis,commCentrNew)#, hold=True)

    ax4.set_xticks(np.arange(0,len(commPerTmslt),pertick), minor=False)
    ax4.set_xticklabels(row_labels[0:-1:pertick], minor=False, fontsize=12, rotation = 30)
    # for tick in ax4.yaxis.get_major_ticks():
    #     tick.label.set_fontsize(7)
    plt.ylabel("Community Centrality")
    plt.xlabel('Timeslots')
    plt.tight_layout()
    fig4 = plt.gcf()
    plt.draw()
    fig4.savefig(dataset_path + "/data/adaptive/results/commCentralityFlux_prev" + str(prevTimeslots) + fileTitle + ".pdf",bbox_inches='tight', format='pdf')
    plt.close()
    del(fig4)
    print('Finished with community centrality fluctuation fig')

def product(list):
    p = 1
    for i in list:
        p *= i
    return p