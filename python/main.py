#!/usr/bin/env python3
#-------------------------------------------------------------------------------
# Name:
# Purpose:       This .py file extracts adjacency lists and detects communities
#                from the corresponding timeslots.
#
# Required libs: python-dateutil, numpy,matplotlib,pyparsing
# Author:        konkonst
#
# Created:       20/08/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import tkinter
from CommunityRanking import communityranking

##root = tkinter.Tk()
##root.withdraw()
##dataset_path = tkinter.filedialog.askdirectory(parent=root,initialdir="f:/Dropbox/ITI/python/community_analysis_framework/",title='Please select a directory')
# User sets json dataset and target folder
#C:/Users/konkonst/Desktop/myDropBox
dataset_path = "d:/Dropbox/ITI/python/community_analysis_framework/budget_UKEcon6"
timeSeg=[600, 900, 1200, 1800, 2700, 3600]
data=communityranking.from_path(dataset_path,timeSeg)
rankedCommunities=data.evol_detect()
##stp1.extraction()
##stp1.step2()



