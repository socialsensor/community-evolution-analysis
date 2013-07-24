#-------------------------------------------------------------------------------       
# Purpose:       parsing data from the crawler's "rawmetadata.json.#" json files to a form:
#			 	 author mentioned1,mentioned2,... unixTimestamp + text \n
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

# User selects dataset folder
dataset_path = "E:/konkonst/retriever/crawler_temp/"

#Parsing commences###
counter=0
for filename in sorted(glob.glob(dataset_path+"/rawmetadata.json.*"),reverse=True):#json files
    print(filename)
    my_file=open(filename,"r")
    counter+=1
    my_txt=open(dataset_path+"/auth_ment_time_txt_"+str(counter)+".txt","w")#target files
    read_line=my_file.readline()
    ustr_to_load = unicode(read_line, 'iso-8859-15')
    while read_line:
        json_line=json.loads(ustr_to_load)##,encoding="cp1252")#.decode("utf-8","replace")
        if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
            read_line=my_file.readline()
            ustr_to_load = unicode(read_line, 'iso-8859-15')
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
        read_line=my_file.readline()
        ustr_to_load = unicode(read_line, 'iso-8859-15')
    else:        
        my_file.close()
        my_txt.close()
			
