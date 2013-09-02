#-------------------------------------------------------------------------------
# Purpose:       parsing data straight from the crawler's txt files to a form:
#                author1 mentioned1 unixTimestamp\n
#                author1 mentioned2,... unixTimestamp\n
#                creating a single file without the text content to render the
#                matlab functions more efficient.
#		         This .py file does not present the user with a folder selection dialog.
# Required libs: python-dateutil
# Author:        konkonst
#
# Created:       31/05/2013
# Copyright:     (c) ITI (CERTH) 2013
# Licence:       <apache licence 2.0>
#-------------------------------------------------------------------------------
import glob
import dateutil.parser
import time

# User sets json dataset and target folder
dataset_path = "E:/konkonst/retriever/crawler_temp/"

###Parsing commences###
my_txt=open(dataset_path+"/authors_mentions_time.txt","w")
for filename in sorted(glob.glob(dataset_path+"/testnet.txt.*"),reverse=True):
    print(filename)
    with open(filename,'r') as f:
        #print str(counter)
        for line in f:
            read_line = line.strip()
            splitLine=read_line.split("\t")
            dt=dateutil.parser.parse(splitLine[2],fuzzy="True")
            mytime=int(time.mktime(dt.timetuple()))
            #print splitLine[1].split(",")
            for mentions in splitLine[1].split(","):
                my_txt.write(splitLine[0]+"\t"+mentions+"\t"+str(mytime)+"\n") #author singlemention time
my_txt.close()

