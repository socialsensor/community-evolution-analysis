#!/usr/bin/env python3
#-------------------------------------------------------------------------------
# Name:
# Purpose:       This .py file is the main Framework file
#
# Required libs: python-dateutil, numpy,matplotlib,pyparsing
# Author:        konkonst
#
# Created:       20/08/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import tkinter,time
from CommunityRanking import communityranking

'''PARAMETERS'''
# User is prompted to enter json dataset and target folder
##root = tkinter.Tk()
##root.withdraw()
##dataset_path = tkinter.filedialog.askdirectory(parent=root,initialdir="f:/Dropbox/ITI/python/community_analysis_framework/",title='Please select a directory')
# User manually sets json dataset and target folder
dataset_path = "d:/Dropbox/ITI/python/community_analysis_framework/pci13"

#User sets desired time intervals
# timeSeg=[900, 1200, 1800, 2700, 3600, 5400] # For short datasets (time is in seconds)
timeSeg=[3600,7200,10800,21600,43200,86400] # For medium datasets (time is in seconds)
# timeSeg=[86400,172800,604800,1209600]#,2592000,5184000] # For long datasets (time is in seconds)

#User sets desired number of displayed top communities
numTopComms=50

#User decides whether to simplify the jsons into readable txts:  1-on / 0-off (time consuming)
simplify_json=0

'''Functions'''
t = time.time()
# Uncomment the next line for json handling (twitter json format)
data=communityranking.from_json(dataset_path,timeSeg,simplify_json)
# Uncomment the next line for txt handling (author mentioneduser1,mentioneduser2 "date" tweeted text)
# data=communityranking.from_txt(dataset_path,timeSeg)
rankedCommunities=data.evol_detect(numTopComms)
elapsed = time.time() - t
print ('Elapsed: %.2f seconds'% elapsed)


