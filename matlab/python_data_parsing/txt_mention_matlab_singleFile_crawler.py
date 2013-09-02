#-------------------------------------------------------------------------------
# Purpose:       parsing data straight from the crawler's txt files to a form:
#                author1 mentioned1 unixTimestamp\n
#                author1 mentioned2,... unixTimestamp\n
#                creating a single file without the text content to render the
#                matlab functions more efficient.
# Required libs: wxPython GUI toolkit, python-dateutil
# Author:        konkonst
#
# Created:       31/05/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import glob
import wx
import dateutil.parser
import time

# User selects dataset folder
app = wx.PySimpleApp()
datasetPath = 'E:/konkonst/retriever/crawler_temp/'
dialog = wx.DirDialog(None, "Please select your dataset folder:",defaultPath=datasetPath)
if dialog.ShowModal() == wx.ID_OK:
    dataset_path= dialog.GetPath()
dialog.Destroy()
#User selects target folder
targetPath = 'E:/konkonst/retriever/crawler_temp/'
dialog = wx.DirDialog(None, "Please select your target folder:",defaultPath=targetPath)
if dialog.ShowModal() == wx.ID_OK:
    target_path= dialog.GetPath()
dialog.Destroy()
###Parsing commences###
my_txt=open(target_path+"/authors_mentions_time.txt","w")
for filename in sorted(glob.glob(dataset_path+"/testnet.txt.*"),reverse=True):
    print(filename)
    with open(filename,'r') as f:
        for line in f:
            read_line = line.strip()
            splitLine=read_line.split("\t")
            dt=dateutil.parser.parse(splitLine[2],fuzzy="True")
            mytime=int(time.mktime(dt.timetuple()))
            for mentions in splitLine[1].split(","):
                my_txt.write(splitLine[0]+"\t"+mentions+"\t"+str(mytime)+"\n") #author singlemention time
my_txt.close()
