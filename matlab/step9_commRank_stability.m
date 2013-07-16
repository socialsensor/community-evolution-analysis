% commRank_stability
% step9_commRank_stability
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

function signifComms=step9_commRank_stability(folder_name,timeSeg,top) %%Comment this line if you need the script
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
[evols,w]=size(commEvolOnes);
%%%%%stability
stblt=zeros(1,w);
for i=1:size(commEvolOnes,2)
    commOnes=commEvolOnes(:,i)';
    q=diff([0 commOnes 0]==1);
    v=find(q==-1)-find(q==1);
    xe=v>1;
    stblt(i)=sum(v(xe));%/h;
end
%%%%%most significant evolutional comms
stblt=stblt/evols;
frstTry=stblt;
[~,idx]=sort(frstTry,'descend');
signifComms_sblt=cell(top,1);
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags')
load([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\usrCentrMax.mat'],'usrCentrMax');
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms_sblt{i,k}=strCommBags{a(k),b(k)};
        tmpCommCentr=num2cell(stblt(idx(i)));
        signifComms_sblt{i,k}(:,2)=tmpCommCentr;
        tmpUsrCentr=num2cell(usrCentrMax{a(k),b(k)});
        signifComms_sblt{i,k}(:,3)=tmpUsrCentr;
    end
end
save([folder_name,'\mats\timeSeg_',num2str(timeSeg),'\signifComms_stability.mat'],'signifComms_sblt')


