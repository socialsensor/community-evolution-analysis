#-------------------------------------------------------------------------------
# Name:        authorMentionTimeParser
# Purpose:     parsing data from a txt file having a form of:
#              author1 mentioned1,mentioned2,... "timestamp" text \n
#              to a form:
#              author1 mentioned1 "timestamp"\n
#              author1 mentioned2 "timestamp"\n
#              thus creating a single file without the text content in order to render
#              the matlab functions more efficient.
# Author:      konkonst
#
# Created:     31/05/2013
# Copyright:   (c) ITI (CERTH) 2013
# Licence:     <apache licence 2.0>
#-------------------------------------------------------------------------------

import os, glob
import codecs
import wx

# User selects dataset folder
app = wx.PySimpleApp()
datasetPath = 'F:/konkonst/retriever_backup/Journalist jsons'
dialog = wx.DirDialog(None, "Please select your dataset folder:",defaultPath=datasetPath)
if dialog.ShowModal() == wx.ID_OK:
    dataset_path= dialog.GetPath()
dialog.Destroy()
#User selects target folder
targetPath = 'F:/konkonst/retriever_backup/Journalist jsons'
dialog = wx.DirDialog(None, "Please select your target folder:",defaultPath=targetPath)
if dialog.ShowModal() == wx.ID_OK:
    target_path= dialog.GetPath()
dialog.Destroy()
#Parsing commences
my_txt=open(target_path+"/authors_mentions_time.txt","w")
for filename in glob.glob(dataset_path+"authors_mentions_time_txt.txt"):
    print(filename)
    my_file=open(filename,"r")
    #print str(counter)
    read_line=my_file.readline()#.decode('utf-8','replace')
    while read_line:
        splitLine=read_line.split("\t")
        #print splitLine[1].split(",")
        for mentions in splitLine[1].split(","):
            my_txt.write(splitLine[0]+"\t" + mentions+"\t"+splitLine[2]+"\n") #author singlemention time
        read_line=my_file.readline()
    my_file.close()
my_txt.close()
