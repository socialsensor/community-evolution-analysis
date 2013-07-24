% needs changes in the documentation and functions
%main file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user activity in respect to twitter mentions. % 
% The txt(s) containing the data should be in folder ../data/    .        %
% If there is only one file it should be named "authors_mentions_time.txt".                   %
% If there are more than one txt files containing the data please number  %
% them incrementally in accordance to time starting with 1 (norton        %
% commander is a good tool)                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;clc;
% Select the folder of interest.  
folder_name=uigetdir;
timeSeg=1800;
% This .m file extracts the user activity in respect to twitter mentions.
% At the end of the function the user is prompted to select the time 
% sampling interval that seems more appropriate for the specific dataset.  
% A time sampling interval of 43200secs was selected for the PCI13 dataset
% timeSeg=step1_mentioning_frequency(folder_name,1);
step1_mentioning_frequency(folder_name,1);
% This .m file extracts the dynamic adjacency matrices for each respective%
% timeslot and save it into a mat format for use with the rest of the code%
% but also in a csv gephi-ready format.
step2_dyn_adj_mat_wr(folder_name,timeSeg);
% This .m file detects the communities in each adjacency matrix as well as%
% the sizes of the communities and the modularity for each timeslot using %
% Louvain mentod (V. D. Blondel, J.-L. Guillaume, R. Lambiotte, and       %
% E. Lefebvre. Fast unfolding of communities in large networks. Journal   %
% of Statistical Mechanics: Theory and Experiment, 2008(10):P10008 (12pp),%
% 2008.).
step3_comm_detect_louvain(folder_name,0,timeSeg);
% This .m file detects the evolution of the communities between timeslots.
step4_comm_evol_detect(folder_name,timeSeg);
% This .m file detects the evolution of the communities between timeslots.
step5_commRoutes(folder_name,timeSeg);
% This .m file extracts the user centrality of all adjacency matrices in  %
% between timeslots using the pagerank algorithm.  
step6_usrCentrality(folder_name,timeSeg);
% This .m file extracts the community adjacency matrix in between        
% timeslots. (In this case, the communities are treated as users.)
step7_comm_dyn_adj_mat_wr(folder_name,timeSeg);
% This .m file extracts the centrality of the community adjacency matrices%
% using the PageRank algorithm.											  %
step8_commCentralityExtraction(folder_name,timeSeg);
% This .m file provides a comparison of the communities perceived as most %
% significant by 3 different community evolution factors: stability,      %
% persistance and community centrality. The synergy of the 3 is also      %
% available for comparison.
top_evol=20;%number of top evolving communities to show
[sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr]=step9_commRank_comparison(folder_name,timeSeg,top_evol);
% The signifComms variable provides the user with the most significant
% communities along with the users which comprise it and their centrality
% values. commEvol and commEvolSize are also useful are they present the 
% evolution of the communities and the community sizes respectfully.
% A heatmap presenting the evolution and size of all evolving communities
% is produced giving the user an idea of the bigger picture.

