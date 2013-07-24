% step9_commRank_commCentr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides an analysis of the communities in respect to their%
% evolution in terms of community centrality.                             %
% A heatmap presenting the evolution and size of all evolving communities %
% is produced giving an idea of the bigger picture.                       %
% It can either work as a standalone script or as a function for the main %
% m-file.                                                                 %
% Please comment the function lines below accordingly.                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signifComms_commCentr=step9_commRank_commCentr(folder_name,timeSeg,top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
% top=20;%number of top evolving communities to show
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolCommIds.mat'],'commIds');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolUniCommIds.mat'],'uniCommIds');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commPageRank.mat'],'commPageRank');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvolCentr.mat'],'commEvolCentr');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[evols,~]=size(commEvolCentr);
%%%%%centrality
cntrlity=sum(commEvolCentr);
cntrlity=cntrlity/evols;%/max(cntrlity);
%%%%%most significant evolutional comms
frstTry=cntrlity;
[~,idx]=sort(frstTry,'descend');
signifComms_commCentr=cell(top,1);
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags')
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms_commCentr{i,k}=strCommBags{a(k),b(k)};
        tmpCommCentr=num2cell(commPageRank(a(k),b(k)));
        signifComms_commCentr{i,k}(:,2)=tmpCommCentr;
        tmpUsrCentr=num2cell(usrCentrMax{a(k),b(k)});
        signifComms_commCentr{i,k}(:,3)=tmpUsrCentr;
    end
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\signifComms_commCentr.mat'],'signifComms_commCentr')


