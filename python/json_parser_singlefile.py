#-------------------------------------------------------------------------------
# Name:        json_parser_singlefile
# Purpose:     parsing in form author1 mentioned1 "timestamp"\n author1 mentioned2,... "timestamp" creating a single file without the text content
# to make the matlab functions more efficient
# Author:      konkonst
#
# Created:     31/05/2013
# Copyright:   (c) ITI (CERTH) 2013
# Licence:     <apache licence 2.0>
#-------------------------------------------------------------------------------
import json
import codecs
import os,glob

!!! Must create a user input asking for the path of the folder in interest

my_txt=open("E:\\konkonst\\retriever\\Journalist jsons\\budget_UKEcon6\\authors_mentions_time.txt","w")
for filename in glob.glob("E:\\konkonst\\retriever\\Journalist jsons\\cycling_WomensRoad/*.json"):
    print(filename)
    my_file=open(filename,"r")
    read_line=my_file.readline()
    while read_line:
        json_line=json.loads(read_line)##,encoding="cp1252")#.decode('utf-8','replace')
        if "delete" or "scrub_geo" or "limit" in json_line:
            read_line=my_file.readline()
            continue
        else:
            if json_line["entities"]["user_mentions"]:
                len_ment=len(json_line["entities"]["user_mentions"])
                for i in range(len_ment):##mentions.append(json_line["entities"]["user_mentions"][i]["screen_name"]) ##my_text=str(json_line["text"].encode('ascii','replace').replace('\n', ''))
                    my_txt.write(json_line["user"]["screen_name"]+"\t" + json_line["entities"]["user_mentions"][i]["screen_name"]+"\t"+"\""+json_line["created_at"]+"\""+"\n")
        read_line=my_file.readline()
    else:
        my_file.close()
my_txt.close()

