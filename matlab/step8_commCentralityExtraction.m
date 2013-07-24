% step8_commCentralityExtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the centrality of the community adjacency matrices%
% using the PageRank algorithm.											  %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function line below accordingly                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step8_commCentralityExtraction(folder_name,timeSeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

CommDir=dir([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\commAdjMat_*.mat']);
lDir=length(CommDir);
commPageRank=zeros(lDir,1);
for k=1:lDir
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\commAdjMat_',num2str(k),'.mat'],'commAdjMat');
    temp=(mypagerank(commAdjMat,0.85,0.001))';
    commPageRank(k,1:length(commAdjMat))=temp(1:end);
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commPageRank.mat'],'commPageRank');