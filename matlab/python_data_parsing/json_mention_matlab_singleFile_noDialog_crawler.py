#-------------------------------------------------------------------------------
# Name:          
# Purpose:       parsing data from a json file to a form:
#                author1 mentioned1 unixTimestamp\n
#                author1 mentioned2,... unixTimestamp\n
#                creating a single file without the text content to render the
#                matlab functions more efficient.
#				 This .py file does not present the user with a folder selection dialog.
# Required libs: python-dateutil
# Author:        konkonst
#
# Created:       31/05/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import json
import codecs
import os,glob
import dateutil.parser
import time

# User sets json dataset and target folder
dataset_path = "E:/konkonst/retriever/Journalist jsons/all Journalist Jsons/USElection_tags"

###Parsing commences###
my_txt=open(dataset_path+"/authors_mentions_time.txt","w")
for filename in sorted(glob.glob(dataset_path+"/rawmetadata.json.*"),reverse=True):
    print(filename)
    my_file=open(filename,"r")
    read_line=my_file.readline()
    ustr_to_load = unicode(read_line, 'iso-8859-15')
    while read_line:
        json_line=json.loads(ustr_to_load)
        if "delete" in json_line or "scrub_geo" in json_line or "limit" in json_line:
            read_line=my_file.readline()
            ustr_to_load = unicode(read_line, 'iso-8859-15')
            continue
        else:     
            if json_line["entities"]["user_mentions"]:
                len_ment=len(json_line["entities"]["user_mentions"])
                dt=dateutil.parser.parse(json_line["created_at"])
                mytime=int(time.mktime(dt.timetuple()))
                for i in range(len_ment):
                    my_txt.write(json_line["user"]["screen_name"]+"\t" + json_line["entities"]["user_mentions"][i]["screen_name"]+"\t"+str(mytime)+"\n")            
        read_line=my_file.readline()
        ustr_to_load = unicode(read_line, 'iso-8859-15')
    else:
        my_file.close()
my_txt.close()

