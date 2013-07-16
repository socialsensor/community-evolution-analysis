% step9_commRank_persist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides an analysis of the communities in respect to their%
% evolution in terms of persistence, stability and community centrality.  %
% A heatmap presenting the evolution and size of all evolving communities %
% is produced giving an idea of the bigger picture.                       %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signifComms=step9_commRank_persist(folder_name,timeSeg,top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
% top=20;%number of top evolving communities to show
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
commSize=cellfun(@numel,numCommBags);
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numEvolCommIds.mat'],'commIds');
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numEvolUniCommIds.mat'],'uniCommIds');
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolOnes.mat'],'commEvolOnes');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[evols,~]=size(commEvolOnes);
%%%%%persistence
prsist=sum(commEvolOnes);%/h;
prsist=prsist/evols;
%%%%%most significant evolutional comms
frstTry=prsist;
[~,idx]=sort(frstTry,'descend');
signifComms_prsst=cell(top,1);
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags')
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms_prsst{i,k}=strCommBags{a(k),b(k)};
        tmpCommPrst=num2cell(prsist(idx(i)));
        signifComms_prsst{i,k}(:,2)=tmpCommPrst;
        tmpUsrCentr=num2cell(usrCentrMax{a(k),b(k)});
        signifComms_prsst{i,k}(:,3)=tmpUsrCentr;
    end
end
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\signifComms_persist.mat'],'signifComms_prsst')


