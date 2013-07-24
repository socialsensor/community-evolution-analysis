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
%stand alone script %%comment the following 2 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800;% Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

CommDir=dir([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat*.mat']);
lDir=length(CommDir);
adjMatCentr=cell(lDir,1);
commUsrCentr=cell(lDir,1);
if ~matlabpool('size')
    matlabpool open
end
for i=1:lDir
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat_',num2str(i),'.mat']);
    tempAdjMatCentr=mypagerank(adjMat,0.85,0.001); %These values are the ones proposed by most PageRank using algorithms
    adjMatCentr{i}=tempAdjMatCentr;
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(i),'.mat']);
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat']);
    strComms=strComms;tempUsers=tempUsers;
    parfor k=1:length(strComms)
        [~,tempNumUsrs]=ismember(strComms{k},tempUsers(:,1));
        commUsrCentr{i,k}=tempAdjMatCentr(tempNumUsrs);
    end    
end
if matlabpool('size')
    matlabpool close
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\adjMatCentr.mat'],'adjMatCentr');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commUsrCentr.mat'],'commUsrCentr');
%%%%%%%%%%%%%%%%%%%%%%%% normalize by max of centrality for each timestep
maxCentr=cellfun(@max,adjMatCentr);
usrCentrMax=cell(lDir,1);

for i=1:lDir
    tempUsrCentrMax=cellfun(@(x) x/maxCentr(i),commUsrCentr(i,:),'UniformOutput',0);
    usrCentrMax(i,(1:length(tempUsrCentrMax)))=tempUsrCentrMax;%(1:length(tempUsrCentrMax));
    clear tempUsrCentrMax    
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');


