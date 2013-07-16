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

function [signifComms,signifComms_sblt,signifComms_prsst,signifComms_commCentr]=step9_commRank_comparison.m(folder_name,timeSeg,top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
% top=20;%number of top evolving communities to show
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
signifComms=commRank_synergy(folder_name,timeSeg,top);
toc
signifComms_sblt=commRank_stability(folder_name,timeSeg,top);
toc
signifComms_prsst=commRank_persist(folder_name,timeSeg,top);
toc
signifComms_commCentr=commRank_commCentr(folder_name,timeSeg,top);
toc
