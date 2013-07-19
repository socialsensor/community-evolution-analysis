#-------------------------------------------------------------------------------
# Name:        json_parser_multifile
# Purpose:     parsing data from a in form author mentioned1,mentioned2,... "timestamp" + text \n
#              creating as many txt files as there are json files.
# Author:      konkonst
#
# Created:     31/05/2013
# Copyright:   (c) ITI (CERTH) 2013
# Licence:     <apache licence 2.0>
#-------------------------------------------------------------------------------
import json
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
counter=0
for filename in glob.glob(dataset_path+"/*.json"): #json files
    print(filename)
    my_file=open(filename,"r")
    counter+=1
    my_txt=open(targetPath+"/auth_ment_time_txt_"+str(counter)+".txt","w")#target files
    read_line=my_file.readline()
    while read_line:
        json_line=json.loads(read_line)##,encoding="cp1252")#.decode('utf-8','replace')
        if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
            read_line=my_file.readline()
            continue
        else:
            if json_line["entities"]["user_mentions"] and json_line["user"]["screen_name"]:
                len_ment=len(json_line["entities"]["user_mentions"])
                mentions=[]
                for i in range(len_ment):
                    mentions.append(json_line["entities"]["user_mentions"][i]["screen_name"])
                # print mentions
                my_text=str(json_line["text"].encode('ascii','replace').replace('\n', '')) #the text message replacing anything that isn't in ascii
                my_txt.write(json_line["user"]["screen_name"]+"\t" + ",".join(mentions)+"\t"+"\""+json_line["created_at"]+"\""+"\t"+my_text + "\n")
        read_line=my_file.readline()
    else:
        my_file.close()
        my_txt.close()
            
