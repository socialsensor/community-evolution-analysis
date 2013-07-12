#PCI13#
Code and data for paper: K. Konstantinidis, S. Papadopoulos and Y. Kompatsiaris, (2013) "Community Structure, Interaction and Evolution Analysis of Online Social Networks around Real-World Social Phenomena", PCI 2013, Thessaloniki, Greece, to appear.
Due to Twitter's terms and permissions (https://dev.twitter.com/terms/api-terms), the data in the files regarding the paper has been transformed from a _"authorname mentionedname1,mentionedname2,... time text"_ form, to a _"authorID mentionedID1,mentionedID2,... time"_  form,so unfortunately the content of the tweets is not available. The crawler however still returns data in the original form so working on a new dataset is possible.
##Crawler##
The crawling is done though a _jar_ file in the crawler folder using the following command in the command prompt:

    java -jar retriever.jar --mentionet testnet.txt --keywords keywords.txt

In order to retrieve the full json of the tweet type:  

    java -jar retriever.jar --mentionet testnet.txt --keywords keywords.txt -file rawmetadata.json 

The crawler returns a _testnet.txt.0_ file which should be renamed to _increasing\_number.txt_ as well as have all the +0000 from the timestamps removed in order to perform the analysis using the matlab files.

##Evolution analysis (Matlab)##
Any new data to be analysed should be placed in the _../data/_ folder replacing the _1.txt_ file.  
The matlab code consists of 7 files which can either work as standalone scripts, or as functions of the _main.m_ script.  
The only thing that needs changing is a comment of the function line in each of the m-files (instructions are included in the m-files).  
These 7 files are:  
<code>step1\_mentioning\_frequency.m</code>  
    - This .m file extracts the user activity in respect to twitter mentions  
<code>step2\_dyn_adj\_mat_wr.m</code>
    + This .m file extracts the dynamic adjacency matrices for each respective timeslot and save it into a mat format for use with the rest of the code but also in a csv gephi-ready format.
<code>step3\_comm\_detect_louvain.m</code>
    * This .m file detects the communities in each adjacency matrix as well as the sizes of the communities and the modularity for each timeslot using Louvain mentod (V. D. Blondel, J.-L. Guillaume, R. Lambiotte, and E. Lefebvre. Fast unfolding of communities in large networks. Journal of Statistical Mechanics: Theory and Experiment, 2008(10):P10008 (12pp), 2008.).
<code>step4\_comm\_evol_detect.m</code>
    - This .m file detects the evolution of the communities between timeslots.
<code>step5_commRoutes.m</code>
    - This .m file detects the routes created by the evolution of the communities between timeslots.
<code>step6_commIndivCentrality.m</code>
    - This .m file extracts the user centrality of all adjacency matrices in between timeslots using the pagerank algorithm.
<code>step7_commRouteAnal.m</code>
    - This .m file provides an analysis of the communities in respect to their evolution in terms of persistence, stability and user centrality.

There are also 4 assistive functions which are used to extract the position of each user in the adjacency matrix (_pos\_aloc\_of\_\usrs.m_), to create the adjacency matrix (_adj\_mat\_creator.m_), to perform the community detection (_comm\_detect\_louvain.m_) and to extract the centrality of each user using the pagerank algorithm (_mypagerank.m_).

###Results###
The final outcome is a cell array in ../signifComms.mat containing the most significant dynamic communities, their users and the centrality of the users.
_.../commEvol.mat_ and _.../commEvolSize.mat_ are also useful as they present the evolution of the communities and the community sizes respectfully.
A heatmap presenting the evolution and size of all evolving communities is also produced giving the user an idea of the bigger picture.
