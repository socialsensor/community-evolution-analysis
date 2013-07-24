% step9_commRank_comparison.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides a comparison of the communities perceived as most %
% significant by 3 different community evolution factors: stability,      %
% persistance and community centrality. The synergy of the 3 is also      %
% available for comparison. 											  %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr]=step9_commRank_comparison(folder_name,timeSeg,top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
% top=20;%number of top evolving communities to show
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%


sigComms=step9_commRank_synergy(folder_name,timeSeg,top);

sigComms_sblt=step9_commRank_stability(folder_name,timeSeg,top);

sigComms_prsst=step9_commRank_persist(folder_name,timeSeg,top);

sigComms_commCentr=step9_commRank_commCentr(folder_name,timeSeg,top);

