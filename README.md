#PCI13#
Code and data for paper: K. Konstantinidis, S. Papadopoulos and Y. Kompatsiaris, (2013) "Community Structure, Interaction and Evolution Analysis of Online Social Networks around Real-World Social Phenomena", PCI 2013, Thessaloniki, Greece, to appear.
Due to Twitter's terms and permissions (https://dev.twitter.com/terms/api-terms), the data in the files regarding the paper has been transformed from a "authorname mentionedname1,mentionedname2,... time text" form, to a "authorID mentioneID1,mentionedID2,... time"  form,so unfortunately the content of the tweets is not available. The crawler however still returns data in the original form so working on a new dataset is possible.

##Crawler##
The crawling is done though a jar file in the crawler folder using the following command in the command prompt:

    java -jar retriever.jar --mentionet testnet.txt --keywords keywords.txt

In order to retrieve the full json of the tweet type:

    java -jar retriever.jar --mentionet testnet.txt --keywords keywords.txt -file rawmetadata.json 

The crawler returns a testnet.txt.0 file which should be renamed to <increasing number>.txt as well as have all the +0000 from the timestamps removed in order to perform the analysis using the matlab files.

##Evolution analysis (Matlab)##
Any new data to be analysed should be placed in the ../data/ folder replacing the "1.txt" file.  
The matlab code consists of 7 files which can either work as standalone scripts, or as functions of the main.m script.  
The only thing that needs changing is a comment of the function line in each of the m-files (instructions are included in the m-files).  
These 7 files are:  
* step1\_mentioning\_frequency.m  
	- This .m file extracts the user activity in respect to twitter mentions  
* step2\_dyn_adj\_mat_wr.m  
	- This .m file extracts the dynamic adjacency matrices for each respective timeslot and save it into a mat format for use with the rest of the code but also in a csv gephi-ready format.
* step3\_comm\_detect_louvain.m  
	- This .m file detects the communities in each adjacency matrix as well as the sizes of the communities and the modularity for each timeslot using Louvain mentod (V. D. Blondel, J.-L. Guillaume, R. Lambiotte, and E. Lefebvre. Fast unfolding of communities in large networks. Journal of Statistical Mechanics: Theory and Experiment, 2008(10):P10008 (12pp), 2008.).
* step4\_comm\_evol_detect.m  
	- This .m file detects the evolution of the communities between timeslots.
* step5_commRoutes.m  
	- This .m file detects the routes created by the evolution of the communities between timeslots.
* step6_commIndivCentrality.m  
	- This .m file extracts the user centrality of all adjacency matrices in between timeslots using the pagerank algorithm.
* step7_commRouteAnal.m  
	- This .m file provides an analysis of the communities in respect to their evolution in terms of persistence, stability and user centrality.

There are also 4 assistive functions which are used to extract the position of each user in the adjacency matrix (pos\_aloc\_of\_\usrs.m), to create the adjacency matrix (adj\_mat\_creator.m), to perform the community detection (comm\_detect\_louvain.m) and to extract the centrality of each user using the pagerank algorithm (mypagerank.m).

###Results###
The final outcome is a cell array in ../signifComms.mat containing the most significant dynamic communities, their users and the centrality of the users.
.../commEvol.mat and .../commEvolSize are also useful as they present the evolution of the communities and the community sizes respectfully.
A heatmap presenting the evolution and size of all evolving communities is also produced giving the user an idea of the bigger picture.
