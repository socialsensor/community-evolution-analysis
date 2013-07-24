#-------------------------------------------------------------------------------  
# Purpose:       parsing data from json files to a form:
#				 author mentioned1,mentioned2,... unixTimestamp + text \n
#                creating as many txt files as there are json files.
#				 This .py file does not present the user with a folder selection dialog.
# Required libs: unidecode
# Author:        konkonst
#
# Created:       31/05/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import json
import os, glob
import codecs, unicodedata
from unidecode import unidecode


# User sets json dataset and target folder
dataset_path = "E:/konkonst/retriever/Journalist jsons/all Journalist Jsons/USElection_tags"

#Parsing commences###
counter=0
for filename in glob.glob(dataset_path+"/*.json"): #json files
    print(filename)
    with open(filename,'r') as f:
        counter+=1
        my_txt=open(dataset_path+"/auth_ment_time_txt_"+str(counter)+".txt","w")#target files
        for line in f:
            encoded_string = line.strip()
            json_line=json.loads(encoded_string)
            if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
                continue
            else:
                if json_line["entities"]["user_mentions"] and json_line["user"]["screen_name"]:
                    len_ment=len(json_line["entities"]["user_mentions"])
                    mentions=[]
                    for i in range(len_ment):
                        mentions.append(json_line["entities"]["user_mentions"][i]["screen_name"])
                    my_text=json_line["text"].replace("\n", "")
                    my_text=unidecode(my_text)
                    my_txt.write(json_line["user"]["screen_name"]+"\t" + ",".join(mentions)+"\t"+"\""+json_line["created_at"]+"\""+"\t"+my_text+"\n")
        else:
            my_txt.close()
			
