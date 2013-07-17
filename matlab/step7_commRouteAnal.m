% step7_commRouteAnal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides an analysis of the communities in respect to their%
% evolution in terms of persistence, stability and user centrality.       %
% A heatmap presenting the evolution and size of all evolving communities %
% is produced giving an idea of the bigger picture.                       %
% It can either work as a standalone script or as a function for the main %
% m-file.                                                                 %
% Please comment the function lines below accordingly.                    %
% The results are saved in the ../data/mats/timeSeg_yourchoice/ folder.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signifComms=step7_commRouteAnal(folder_name,timeSeg,top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
% top=20;%number of top evolving communities to show
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
commSize=cellfun(@numel,numCommBags);
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommSize.mat'],'commSize');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolCommIds.mat'],'commIds');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolUniCommIds.mat'],'uniCommIds');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');
[siz,~]=size(commIds);
commEvol=zeros(siz,length(uniCommIds));
commEvolOnes=zeros(siz,length(uniCommIds));
commEvol=num2cell(commEvol);
commEvolSize=zeros(siz,length(uniCommIds));
usrEvolCentr=zeros(siz,length(uniCommIds));
for i=1:length(uniCommIds)
    [a,b]=find(strcmp(uniCommIds{i},commIds));
    for k=1:length(a)
        commEvolOnes(a(k),i)=1;
        commEvol{a(k),i}=uniCommIds{i};
        commEvolSize(a(k),i)=commSize(a(k),b(k));
        usrEvolCentr(a(k),i)=max(usrCentrMax{a(k),b(k)});
    end
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvol.mat'],'commEvol');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvolSize.mat'],'commEvolSize');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvolOnes.mat'],'commEvolOnes');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrEvolCentr.mat'],'usrEvolCentr');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvol.mat'],'commEvol');
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvolSize.mat'],'commEvolSize');
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commEvolOnes.mat'],'commEvolOnes');
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\usrEvolCentr.mat'],'usrEvolCentr');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,w]=size(commEvolOnes);
%%%%%persistence
prsistc=sum(commEvolOnes);%/h;
prsistc=prsistc/max(prsistc);
%%%%%stability
stblt=zeros(1,w);
for i=1:size(commEvolOnes,2)
    commOnes=commEvolOnes(:,i)';
    q=diff([0 commOnes 0]==1);
    v=find(q==-1)-find(q==1);
    xe=v>1;
    stblt(i)=sum(v(xe));%/h;
end
stblt=stblt/max(stblt);
%%%%%centrality
cntrlity=sum(usrEvolCentr);
cntrlity=cntrlity/max(cntrlity);
%%%%%most significant evolutional comms
frstTry=stblt.*prsistc.*cntrlity;
[~,idx]=sort(frstTry,'descend');
signifComms=cell(1,top);
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags')
% bin=1;
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms{i,k}=strCommBags{a(k),b(k)};
        tmp=num2cell(usrCentrMax{a(k),b(k)});
        signifComms{i,k}(:,2)=tmp;
    end
end
%As well as returning the most significant Comms in the workspace, we also save them in the ../data/mats/timeSeg_yourchoice/ folder. 
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\signifComms.mat'],'signifComms')
%The last part produces a heatmap presenting the evolution and size of all evolving communities.
figure
image(commEvolSize'),xlabel('Time Step'), ylabel('Evolving Community #');
colormap gray(10);
cmap = colormap;
cmap = flipud(cmap);
colormap(cmap);



