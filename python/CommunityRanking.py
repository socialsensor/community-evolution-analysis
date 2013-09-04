#!/usr/bin/env python3
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
import json,codecs,os,glob,time,pickle,tkinter,dateutil.parser,community
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import interactive
# from scipy.sparse import lil_matrix
import networkx as nx

# User sets json dataset and target folder
##root = tkinter.Tk()
##root.withdraw()
##dataset_path = tkinter.filedialog.askdirectory(parent=root,initialdir="f:/Dropbox/ITI/python/community_analysis_framework/",title='Please select a directory')
### dataset_path = "f:/Dropbox/ITI/python/community_analysis_framework/cycling_MensRoad_tagsCopy/"

class communityranking:
    @classmethod
    def from_path(cls,dataset_path,timeSeg):
        '''Make temp folder if non existant'''
        if not os.path.exists(dataset_path+"/data/results/forGephi"):
            os.makedirs(dataset_path+"/data/results/forGephi")

        '''Parse the json files into authors/mentions/alltime lists'''
        authors,mentions,alltime=[],[],[]
        for filename in glob.glob(dataset_path+"/data/json/*.json"):
            print(filename)
            my_file=open(filename,"r")
            read_line=my_file.readline()
            while read_line:
                json_line=json.loads(read_line)
                if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
                    read_line=my_file.readline()
                    continue
                else:
                    if json_line["entities"]["user_mentions"] and json_line["user"]["screen_name"]:
                        len_ment=len(json_line["entities"]["user_mentions"])
                        dt=dateutil.parser.parse(json_line["created_at"])
                        mytime=int(time.mktime(dt.timetuple()))
                        for i in range(len_ment):
                            authors.append(json_line["user"]["screen_name"])
                            mentions.append(json_line["entities"]["user_mentions"][i]["screen_name"])
                            alltime.append(mytime)
                read_line=my_file.readline()
            else:
                my_file.close()
        return cls(authors,mentions,alltime,dataset_path,timeSeg)
    # @classmethod
    # def from_variables(cls,auth_ment_time)

    def __init__(self,authors,mentions,alltime,dataset_path,timeSeg):
        self.authors=authors
        self.mentions=mentions
        self.alltime=alltime
        self.dataset_path=dataset_path
        self.timeSeg=timeSeg
        self.uniqueUsers={}
        self.userPgRnkBag={}
        self.commPgRnkBag={}
        self.commPgRnkBag={}
        self.commStrBag={}
        self.commNumBag={}
        self.rankedCommunities={}

    def extraction(self):
        '''Extract adjacency lists,mats,user and community centrality and communities bags'''

        #Compute the first derivative and the point of timeslot separation
        firstderiv,mentionLimit=self.timeslotselection(self.authors,self.mentions,self.alltime)

        #Split time according to the first derivative of the users' activity#
        sesStart,timeslot=0,0
        for k in range(len(mentionLimit)):
            if firstderiv[k]<0 and firstderiv[k+1]>=0:
                fileNum='{0}'.format(str(timeslot).zfill(2))
                my_txt=open(self.dataset_path+"/data/results/forGephi/usersPairs_"+fileNum+".txt","w")
                print("Forming Timeslot Data "+str(timeslot)+" at point "+str(k))
                sesEnd=int(mentionLimit[k]+1)
                #Write pairs of users to txt file for later use
                usersPair=list(zip(self.authors[sesStart:sesEnd],self.mentions[sesStart:sesEnd]))
                my_txt.write("Source,Target"+"\n")
                for line in usersPair:
                    my_txt.write(",".join(str(x) for x in line) + "\n")
                my_txt.close()


                #Construct networkX graph
                tempDiGraph=nx.DiGraph()
                tempDiGraph.add_edges_from(usersPair)
                tempGraph=nx.Graph()
                tempGraph.add_edges_from(usersPair)

                #Extract the centrality of each user using the PageRank algorithm
                tempUserPgRnk=nx.pagerank(tempDiGraph,alpha=0.85,max_iter=100,tol=0.001)
                maxPGR=max((pgr for k,(pgr) in tempUserPgRnk.items()))
                for k in tempUserPgRnk.items():
                    tempUserPgRnk[k[0]]/=maxPGR
                self.userPgRnkBag[timeslot]=tempUserPgRnk

                #Detect Communities using the louvain algorithm#
                partition = community.best_partition(tempGraph)
                inv_partition = {}
                for k, v in partition.items():
                    inv_partition[v] = inv_partition.get(v, [])
                    inv_partition[v].append(k)
                    inv_partition[v].sort()
                strComms=[inv_partition[x] for x in inv_partition]
                strComms.sort(key=len,reverse=True)

                #Construct Communities of uniqueUsers indices and new community dict with size sorted communities
                numComms,new_partition=[],{}
                for c1,comms in enumerate(strComms):
                    numpart=[]
                    for ids in comms:
                        numpart.extend(self.uniqueUsers[ids])
                        new_partition[ids]=c1
                    numComms.append(numpart)
                newinv_partition = {}
                for k, v in new_partition.items():
                    newinv_partition[v] = newinv_partition.get(v, [])
                    newinv_partition[v].append(k)
                    newinv_partition[v].sort()

                #Construct a graph using the communities as users
                tempCommGraph=community.induced_graph(new_partition,tempDiGraph)

                #Detect the centrality of each community using the PageRank algorithm
                commPgRnk=nx.pagerank(tempCommGraph,alpha=0.85,max_iter=100,tol=0.001)
                maxCPGR=max((cpgr for k,(cpgr) in commPgRnk.items()))
                commPgRnkList=[]
                for key,value in commPgRnk.items():
                    commPgRnkList.append(value/maxCPGR)
                self.commPgRnkBag[timeslot]=commPgRnkList

                '''Construct Community Dictionary'''
                self.commStrBag[timeslot]=strComms
                self.commNumBag[timeslot]=numComms
                sesStart=sesEnd
                timeslot+=1

    def timeslotselection(self,authors,mentions,alltime):
        ###Parsing commences###

        #Extract unique users globally and construct dictionary
        usrs=list(set(np.append(authors,mentions)))
        usrs.sort()
        uniqueUsers,counter1={},0
        for tmpusrs in usrs:
            uniqueUsers[tmpusrs]=[counter1]
            counter1+=1
        self.uniqueUsers=uniqueUsers

        #Find time distance between posts#
        time2=np.append(alltime[0],alltime)
        time2=time2[0:len(time2)-1]
        timeDif=abs(alltime-time2)
        lT=len(alltime)

        ###Extract the first derivative###
        font = {'size'   : 9}
        plt.rc('font', **font)
        fig = plt.figure(figsize=(10,8))
        plotcount,globfirstderiv,globmentionLimit=0,{},{}
        for seg in self.timeSeg:
            curTime,bin,freqStat,mentionLimit=0,0,[0],[]
            for i in range(lT):
                curTime+=timeDif[i]
                if curTime<=seg:
                    freqStat[bin]+=1
                else:
                    curTime=0
                    mentionLimit=np.append(mentionLimit,i)
                    bin+=1
                    freqStat=np.append(freqStat,0)
            mentionLimit=np.append(mentionLimit,i)
            freqStatIni=np.zeros(len(freqStat)+1)
            freqStatMoved=np.zeros(len(freqStat)+1)
            freqStatIni[0:len(freqStat)]=freqStat
            freqStatMoved[1:len(freqStat)+1]=freqStat
            firstderiv=freqStatIni-freqStatMoved
            firstderiv[len(firstderiv)-1]=0

            globfirstderiv[seg]=firstderiv
            globmentionLimit[seg]=mentionLimit

            plotcount+=1
            if seg/3600<1:
                timeNum=seg/60
                timeTitle=" mins"
            elif seg/86400>1:
                timeNum=seg/86400
                timeTitle=" days"
            else:
                timeNum=seg/3600
                timeTitle=" hours"
            plt.subplot(int(np.ceil(len(self.timeSeg)/2)),2,plotcount,autoscale_on=True)
            plt.grid(axis='x')
            plt.plot(freqStat,'b-',hold=True)
            plt.ylabel("User activity (mentions)")
            plt.xlabel("time(sampling period:"+str(timeNum)+timeTitle+")")
            POI=[]
            for k in range(len(mentionLimit)):
                if firstderiv[k]<0 and firstderiv[k+1]>=0:
                    POI=np.append(POI,k)
            POI=np.int32(POI)
            plt.plot(POI,freqStat[POI],'ro',hold=True)
        interactive(True)
        fig.tight_layout()
        fig.show()
        plt.savefig(self.dataset_path+"/data/results/user_activity.eps",bbox_inches='tight',format='eps')
        timeSegInput=int(input("Insert Selected Sampling Time Please: \n" +str(self.timeSeg)))
        plt.close()
        firstderiv=globfirstderiv[timeSegInput]
        mentionLimit=globmentionLimit[timeSegInput]
        return firstderiv,mentionLimit

    def evol_detect(self):
        self.extraction()
        """Construct Community Dictionary"""
        commNumBag2={}
        commSizeBag={}
        timeslots=len(self.commNumBag)
        lC=[] #Number of communities>2people for each timeslot
        for cBlen in range(timeslots):
            commNumBag2[cBlen]=[x for x in self.commNumBag[cBlen] if len(x)>2]
            commSizeBag[cBlen]=[len(x) for x in self.commNumBag[cBlen] if len(x)>2]
            lC.append(len(commNumBag2[cBlen]))

        commIds=[]
        # name the first line of communities
        commIds.append([])
        birthcounter=0
        for j in range(lC[0]):
            # commIds[str(0)+","+str(j)]=str(0)+','+str(j)
            commIds[0].append(str(0)+','+str(j))
            birthcounter+=1
        #Detect any evolution and name the evolving communities
        #uniCommIdsEvol is structured as such {'Id':[rowAppearence],[commCentrality],[commSize],[users]}
        tempUniCommIds,evolcounter,uniCommIdsEvol=[],0,{}
        for rows in range(1,timeslots):
            print('Community similarity search for timeslot: '+str(rows))
##            commIds[rows]=[]
            commIds.append([])
            for clmns in range(lC[rows]):
                idx=str(rows)+","+str(clmns)
                bag1=commNumBag2[rows][clmns]
                tempcommSize=len(bag1)
                if tempcommSize>999:
                    thres=.05
                elif tempcommSize>99:
                    thres=.1
                elif tempcommSize>29:
                    thres=.2
                elif tempcommSize>7:
                    thres=.25
                else:
                    thres=.41
                for invrow in range(1,4):
                    prevrow=rows-invrow
                    tmpsim=[]
                    if prevrow>=0:
                        for prevComms in commNumBag2[prevrow]:
                            if thres>(len(prevComms)/tempcommSize):
                                break
                            elif thres>(tempcommSize/len(prevComms)):
                                tmpsim.append(0)
                                continue
                            else:
                                tmpsim.append(len(list(set(bag1) & set(prevComms)))/len(set(np.append(bag1,prevComms))))
                        if tmpsim:
                            maxval=max(tmpsim)
                        else:
                            maxval=0
                        if maxval>=thres:
                            evolcounter+=1
                            maxIdx=tmpsim.index(maxval)
                            tempUniCommIds.append(commIds[prevrow][maxIdx])
                            if commIds[prevrow][maxIdx] not in uniCommIdsEvol:
                                uniCommIdsEvol[commIds[prevrow][maxIdx]]=[[],[],[],[]]
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][0].append(prevrow)#timeslot num for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][1].append(self.commPgRnkBag[prevrow][maxIdx])#community pagerank for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][2].append(commSizeBag[prevrow][maxIdx])#community size per timeslot for first evolution
                                uniCommIdsEvol[commIds[prevrow][maxIdx]][3].append(self.commStrBag[prevrow][maxIdx])#users in each community for first evolution
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][0].append(rows)#timeslot num
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][1].append(self.commPgRnkBag[rows][clmns])#community pagerank
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][2].append(commSizeBag[rows][clmns])#community size per timeslot
                            uniCommIdsEvol[commIds[prevrow][maxIdx]][3].append(self.commStrBag[rows][clmns])#users in each community
                            commIds[rows].append(commIds[prevrow][maxIdx])
                            break
                if maxval<thres:
                    birthcounter+=1
                    commIds[rows].append(str(rows)+','+str(clmns))
        uniCommIds=list(set(tempUniCommIds))
        uniCommIds.sort()
        # return (jaccdict,maxCommSimPercentage,lC)
        print(str(birthcounter)+" births and "+str(evolcounter)+" evolutions")

        tempcommRanking={}
        #structure: tempcommRanking={Id:[persistence,stability,commCentrality]}
        for Id in uniCommIds:
            timeSlLen=len(set(uniCommIdsEvol[Id][0]))
            tempcommRanking[Id]=[]
            tempcommRanking[Id].append(timeSlLen/timeslots)#persistence
            tempcommRanking[Id].append((sum(np.diff(list(set(uniCommIdsEvol[Id][0])))==1)+1)/(timeslots+1))#stability
            tempcommRanking[Id].append(sum(uniCommIdsEvol[Id][1])/timeSlLen)#commCentrality
        #calculate maxs in for everything
        maxP=max((p for k,(p,s,c) in tempcommRanking.items()))
        maxS=max((s for k,(p,s,c) in tempcommRanking.items()))
        maxC=max((c for k,(p,s,c) in tempcommRanking.items()))
        commRanking={}
        tempcommRankingNorms={}
        for Id in uniCommIds:
            tempcommRankingNorms[Id]=[]
            tempcommRankingNorms[Id].append(tempcommRanking[Id][0]/maxP)#normalized persistence
            tempcommRankingNorms[Id].append(tempcommRanking[Id][1]/maxS)#normalized stability
            tempcommRankingNorms[Id].append(tempcommRanking[Id][2]/maxC)#normalized commCentrality
            commRanking[Id]=np.prod(tempcommRankingNorms[Id])

        rankedCommunities=sorted(commRanking, key=commRanking.get,reverse=True)

        row_labels = list(range(timeslots))
        column_labels= rankedCommunities[0:100]
        commSizeHeatData=np.zeros([len(rankedCommunities),timeslots])
        for rCIdx,comms in enumerate(rankedCommunities[0:100]):
            for sizeIdx,timesteps in enumerate(uniCommIdsEvol[comms][0]):
                if commSizeHeatData[rCIdx,timesteps]!=0:
                    commSizeHeatData[rCIdx,timesteps]=max(uniCommIdsEvol[comms][2][sizeIdx],commSizeHeatData[rCIdx,timesteps])
                else:
                    commSizeHeatData[rCIdx,timesteps]=uniCommIdsEvol[comms][2][sizeIdx]
        fig, ax = plt.subplots()
        heatmap=ax.pcolormesh(commSizeHeatData,cmap=plt.cm.gist_gray_r)
        ax.set_xticks(np.arange(commSizeHeatData.shape[1]), minor=False)
        ax.set_yticks(np.arange(commSizeHeatData.shape[0]), minor=False)
        plt.xlim(xmax=(timeslots))
        plt.ylim(ymax=(len(rankedCommunities[0:100])))
        plt.ylabel("Ranked Communities (1st 100)")
        plt.xlabel('Timeslot',{'verticalalignment':'top'})
        ax.invert_yaxis()
        ax.xaxis.tick_top()
        ax.set_xticklabels(row_labels, minor=False)
        ax.set_yticklabels(column_labels, minor=False)
        plt.tight_layout()
        interactive(False)
        plt.show()
        fig.savefig(self.dataset_path+"/data/results/communitySizeHeatmap.eps",bbox_inches='tight',format='eps')
        plt.close()
        '''Writing ranked communities to json files'''
        rankedCommunitiesFinal={}
        twitterDataFile = open(self.dataset_path+'/data/results/rankedCommunities.json', "w")
        jsondata=dict()
        jsondata["ranked_communities"]=[]
        for rank,rcomms in enumerate(rankedCommunities):
            tmslUsrs=[]
            strRank='{0}'.format(str(rank).zfill(2))
            rankedCommunitiesFinal[strRank]=[rcomms]
            rankedCommunitiesFinal[strRank].append(commRanking[rcomms])
            rankedCommunitiesFinal[strRank].append(uniCommIdsEvol[rcomms][3])
            for tmsl,users in enumerate(uniCommIdsEvol[rcomms][3]):
                uscentr=[]
                for us in users:
                    uscentr.append({us:self.userPgRnkBag[uniCommIdsEvol[rcomms][0][tmsl]][us]})
                tmslUsrs.append({uniCommIdsEvol[rcomms][0][tmsl]:uscentr})
            jsondata["ranked_communities"].append({'community label':rcomms,'rank':rank+1,'timeslot appearance':uniCommIdsEvol[rcomms][0],'persistence:':tempcommRanking[rcomms][0],
            'stability':tempcommRanking[rcomms][1],'community centrality':tempcommRanking[rcomms][2],'community size per slot':uniCommIdsEvol[rcomms][2],'users:centrality for timeslot':tmslUsrs})
        twitterDataFile.write(json.dumps(jsondata, sort_keys=True))
        twitterDataFile.close()
        return rankedCommunitiesFinal
