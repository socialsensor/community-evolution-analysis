%step6_commIndivCentrality centrality of users in their corresponding communities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user centrality of all adjacency matrices in  %
% between timeslots using the pagerank algorithm.                         %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step6_usrCentrality(folder_name,timeSeg) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CommDir=dir([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat*.mat']);
lDir=length(CommDir);
adjMatCentr=cell(lDir,1);
commUsrCentr=cell(lDir,1);
if ~matlabpool('size')
    matlabpool open
end
for i=1:lDir
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat_',num2str(i),'.mat']);
    tempAdjMatCentr=mypagerank(adjMat,0.85,0.001);
    adjMatCentr{i}=tempAdjMatCentr;
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(i),'.mat']);
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat']);
    strComms=strComms;tempUsers=tempUsers;
    parfor k=1:length(strComms)
        [~,tempNumUsrs]=ismember(strComms{k},tempUsers);
        commUsrCentr{i,k}=tempAdjMatCentr(tempNumUsrs);
    end    
end
matlabpool close
% save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\adjMatCentr.mat'],'adjMatCentr');
% save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commUsrCentr.mat'],'commUsrCentr');
%%%%%%%%%%%%%%%%%%%%%%%% normalize by max of centrality for each timestep
maxCentr=cellfun(@max,adjMatCentr);
usrCentrMax=cell(lDir,1);

for i=1:lDir
    tempUsrCentrMax=cellfun(@(x) x/maxCentr(i),commUsrCentr(i,:),'UniformOutput',0);
    usrCentrMax(i,(1:length(tempUsrCentrMax)))=tempUsrCentrMax;%(1:length(tempUsrCentrMax));
    clear tempUsrCentrMax    
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');


