community-evolution-analysis
============================

###A framework for the analysis of social interaction networks (e.g. induced by Twitter mentions) in time.
We make available a Twitter interaction network collector and a set of Matlab and Python scripts that enable the analysis of social interaction networks with the goal of uncovering evolving communities. More specifically, the interaction network collector forms a network between Twitter users based on the mentions in the set of monitored tweets (using the Streaming API). The network of interactions is adaptively partitioned into snapshot graphs based on the frequency of interactions. Then, each graph snapshot is partitioned into communities using the Louvain method [2]. Dynamic communities are extracted by matching the communities of the current graph snapshot to communities of previous snapshot. Finally, these dynamic communities are ranked and presented to the user in accordance to three factors; stability, persistence and community centrality. The user can browse through these communities in which the users are also ranked in accordance to their own specific snapshot centrality. The PageRank algorithm [3] is used to measure the feature of centrality.

* The master branch of this repository contains ongoing matlab and python files which form the current stable version of the framework. 
* The _"pci13"_ branch contains all the code and data needed to replicate the experiments performed in [1].
* The _"dev"_ branch contains more advanced but unstable versions of the framework.

[1] K. Konstandinidis, S. Papadopoulos, Y. Kompatsiaris. "Community Structure, Interaction and Evolution Analysis of Online Social Networks around Real-World Social Phenomena". In Proceedings of PCI 2013, Thessaloniki, Greece (to be presented in September).  
[2] V. Blondel, J.-L. Guillaume, R. Lambiotte, E. Lefebvre. "Fast unfolding of communities in large networks". In Journal of Statistical Mechanics: Theory and Experiment (10), P10008, 2008  
[3] S. Brin and L. Page. "The anatomy of a large-scale hypertextual web search engine". Comput. Netw. ISDN Syst., 30(1-7):107{117}, Apr. 1998.

##Distribution Information##
This distribution contains the following:  
* a readme.txt file with instructions on how to use the different parts of the framework;
* a set of Python scripts (in the /python folder) that are used to conduct community evolution analysis.
* a set of Matlab scripts (in the /matlab folder) that are used to conduct community evolution analysis and a set of Python scripts (in the /matlab/python_data_parsing folder) that are used to parse the json files retrieved by the data collector in a "Matlab friendly" form.

##Evolution analysis using Python##

Any new data (json files) to be analysed should be placed in the _../data/json/_ folder.
In order for the python files to work, the data should be in a json twitter-like form  (the "entities", "user" and "created\_at" keys and paths should be identical with twitter's).

###Code###
The python code consists of 3 files containing friendly user scripts for performing Community Evolution Analysis from json and txt files acquired from the Twitter social network.
The framework was implemented using Python 3.3 and the 3rd party libraries required for the framework to work are _dateutil_ (requires _pyparsing_), _numpy_, _matplotlib_ and _networkx_ (http://www.lfd.uci.edu/~gohlke/pythonlibs/). 

The python folder contains 3 files:
* <code>main.py</code>  
    This .py file is used to provide a guideline to the user as to how to use the framework (CommunityRanking.py file).
* <code>community.py</code>  
    This is a copy of Aynaud's implementation of the Louvain community detection algorithm.
* <code>CommunityRanking.py</code>  
    This .py file contains the Evolution Analysis Framework.

###Python Results###
The framework provides the user with 5 pieces of resulting data in the _../data/results/_ folder: a) the user_activity.eps file which presents the user mentioning activity according to the selected sampling interval, b) usersPairs_(num).txt files which can be used with the Gephi visualization software in order to view the praphs, c) the rankedcommunities variable (from main.py) which contains all the communities (and their users) which evolved ranked in accordance to the persistence, stability and community centrality triplet, d) the community size heatmap (communitySizeHeatmap.eps) which provides a visualization of the sizes of the 100 most important communities (ranked from top to bottom) and e) the rankedCommunities.json file which contains all the ranked communities along with all the information regarding the specific timeslot of evolution for each community, the persistence, stability and community centrality values and all the users in each community accompanied by their own centrality measure. As such, the framework can be used to discover the most important communities along with the most important users inside those communities.

##Evolution analysis using Matlab##

Any new data to be analysed should be placed in the _../data/_ folder 
In the case where the user has data from a different source, in order for the python files to work, the data should either be in a json twitter-like form  (the "entities", "user" and "created\_at" keys and paths should be identical with twitter's) or in a txt file of the form:

    user1 \TAB user2,user3... \TAB "created_at_timestamp" \TAB text \newline  

###Step1: json Parsing (Python)###
The python parsing code consists of 8 files containing user friendly scripts for parsing the required data from json files. There are 4 files to be used with jsons from any other Twitter API dependant source.  
More specifically, they are used to create txt files which contain the mentions entries between twitter users as well as the time at which these mentions were made and the context in which they were included.  

The json_mention_multifile* files provide as many txt files as there are json files. 
They contain all the information required from the tweet in a readable form:

    user1 \TAB user2,user3... \TAB "created_at_timestamp" \TAB text \newline

The json_mention_matlab_singleFile* files provide a single file which contains only the data
required to perform the community analysis efficiently. They contain information in a "Matlab friendly" form:

    user1 \TAB user2 \TAB unix_timestamp \TAB \newline
    user1 \TAB user3 \TAB unix_timestamp \TAB \newline

This folder contains 6 files:
* <code>json\_mention\_multifile\_parser.py & json\_mention\_matlab\_singleFile_parser.py</code>  
    These files are used when the user has *.json files.
* <code>json\_mention\_multifile\_noDialog\_parser.py & json\_mention\_matlab\_singleFile\_noDialog_parser.py</code>  
    These are similar to the previous files but the dataset folder path has to be inserted manually (Does not require the wxPython GUI toolkit).
* <code>txt\_mention\_matlab\_singleFile\_parser.py & txt\_mention\_matlab\_singleFile\_noDialog\_parser.py</code>  
    These files are used when the user has *.txt files from another source.  

The resulting authors\_mentions\_time.txt file should be added to the _../data/_ folder.

###Step2: Evolution Analysis (Matlab)###
The matlab code consists of 13 files which can either work as standalone scripts, or as functions of the _main.m_ script. 
The only thing that needs changing is a comment of the function line in each of the m-files (instructions are included in the m-files).  
These 13 files are:  
* <code>step1\_mentioning\_frequency.m</code>  
    This .m file extracts the user activity in respect to twitter mentions  
* <code>step2\_dyn_adj\_mat_wr.m</code>  
    This .m file extracts the dynamic adjacency matrices for each respective timeslot and save it into a mat format for use with the rest of the code but also in a csv gephi-ready format.  
* <code>step3\_comm\_detect_louvain.m</code>  
    This .m file detects the communities in each adjacency matrix as well as the sizes of the communities and the modularity for each timeslot using Louvain mentod (V. D. Blondel, J.-L. Guillaume, R. Lambiotte, and E. Lefebvre. Fast unfolding of communities in large networks. Journal of Statistical Mechanics: Theory and Experiment, 2008(10):P10008 (12pp), 2008.).  
* <code>step4\_comm\_evol_detect.m</code>  
    This .m file detects the evolution of the communities between timeslots.  
* <code>step5_commRoutes.m</code>  
    This .m file detects the routes created by the evolution of the communities between timeslots.  
* <code>step6\_usrCentrality.m</code>  
    This .m file extracts the user centrality of all adjacency matrices in between timeslots using the pagerank algorithm.  
* <code>step7\_comm\_dyn\_adj\_mat\_wr.m</code>  
    This .m file extracts the community adjacency matrix in between timeslots (in this case, the communities are treated as users). The commAdjMats are written in mat format but also as csvs for gephi.
* <code>step8\_commCentralityExtraction.m
	This .m file extracts the centrality of the community adjacency matrices using the PageRank algorithm.
* <code>step9\_commRank\_commCentr.m</code> 
	This .m file provides an analysis of the communities in respect to their evolution in terms of community centrality. 
* <code>step9\_commRank\_stability.m</code> 
	This .m file provides an analysis of the communities in respect to their evolution in terms of stability.
* <code>step9\_commRank\_persist.m</code> 
This .m file provides an analysis of the communities in respect to their evolution in terms of persistence.
* <code>step9\_commRank\_synergy.m</code> 
	This .m file provides an analysis of the communities in respect to their evolution in terms of persistence, stability and community centrality. A heatmap presenting the evolution and size of all evolving communities is produced giving an idea of the bigger picture.
* <code>step9\_commRank\_comparison.m</code> 
	This .m file provides a comparison of the communities perceived as most significant by 3 different community evolution factors: stability, persistance and community centrality. The synergy of the 3 is also available for comparison.

There are also 4 assistive functions which are used to extract the position of each user in the adjacency matrix (_pos\_aloc\_of\_usrs.m_), to create the adjacency matrix (_adj\_mat\_creator.m_), to perform the community detection (_comm\_detect\_louvain.m_) and to extract the centrality of each user using the pagerank algorithm (_mypagerank.m_).

###Matlab Results###
The final outcome is a cell array in ../data/mats/signifComms.mat containing the most significant dynamic communities, their users and the centrality of the users.
_.../data/mats/commEvol.mat_ and _.../data/mats/commEvolSize.mat_ are also useful as they present the evolution of the communities and the community sizes respectfully.
A heatmap presenting the evolution and size of all evolving communities is also produced giving the user an idea of the bigger picture (../data/figures/).
