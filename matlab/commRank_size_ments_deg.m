% commRank_synergy
%%%function
% function signifComms=commRank_size_ments_deg(folder_name,timeSeg)
% clear all;clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Standalone
folder_name=uigetdir;
timeSeg={600 1800 3600 21600 43200 86400}; %Snapshot every timeSeg secs
choice = menu('Please select sampling rate...',timeSeg);
timeSeg=timeSeg{choice};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
commSize=cellfun(@numel,numCommBags);
% save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numCommSize.mat'],'commSize');
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numEvolCommIds.mat'],'commIds');
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\numEvolUniCommIds.mat'],'uniCommIds');
[siz,~]=size(commIds);
commEvol=zeros(siz,length(uniCommIds));
commEvolOnes=zeros(siz,length(uniCommIds));
commEvol=num2cell(commEvol);
commEvolSize=zeros(siz,length(uniCommIds));
for i=1:length(uniCommIds)
    [a,b]=find(strcmp(uniCommIds{i},commIds));
    for k=1:length(a)
        commEvolOnes(a(k),i)=1;
        commEvol{a(k),i}=uniCommIds{i};
        commEvolSize(a(k),i)=commSize(a(k),b(k));
    end
end
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvol.mat'],'commEvol');
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolSize.mat'],'commEvolSize');
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolOnes.mat'],'commEvolOnes');
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolCentr.mat'],'commEvolCentr');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvol.mat'],'commEvol');
% load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolSize.mat'],'commEvolSize');
% load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolOnes.mat'],'commEvolOnes');
% load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\commEvolCentr.mat'],'commEvolCentr');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[evols,w]=size(commEvolOnes);
%%%size
sizeRank=sum(commEvolSize);
sizeRank=sizeRank/max(sizeRank);
%%%All mentions
allMentions=
%%%%%most significant evolutional comms
frstTry=prsistc.*stblt.*cntrlity;
[~,idx]=sort(frstTry,'descend');
top=20;%number of top evolving communities to show
signifComms=cell(top,1);
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags')

load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');
% bin=1;
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms{i,k}=strCommBags{a(k),b(k)};
        tmpCommCentr=num2cell(commPageRank(a(k),b(k)));
        signifComms{i,k}(:,2)=tmpCommCentr;
        tmpUsrCentr=num2cell(usrCentrMax{a(k),b(k)});
        signifComms{i,k}(:,3)=tmpUsrCentr;
    end
end
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\signifComms.mat'],'signifComms')



