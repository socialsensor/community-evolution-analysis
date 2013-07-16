#-------------------------------------------------------------------------------
# Name:        authorMentionTimeParser
# Purpose:     parsing in form author1 mentioned1 "timestamp"\n author1 mentioned2,... "timestamp" creating
# a single file without the text content from a form of author1 mentioned1,mentioned2,... "timestamp" text \n
# to make the matlab functions more efficient
# Author:      konkonst
#
# Created:     31/05/2013
# Copyright:   (c) ITI (CERTH) 2013
# Licence:     <apache licence 2.0>
#-------------------------------------------------------------------------------

import os, glob
import codecs

!!! Must create a user input asking for the path of the folder in interest

my_txt=open("F:\\Dropbox\\ΙΠΤΗΛ\\MATLAB\\iran_elections\\txts\\authors_mentions_time.txt","w")
for filename in glob.glob("F:\\Dropbox\\ΙΠΤΗΛ\\MATLAB\\iran_elections\\txts\\authors_mentions_time_txt.txt"):
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
