%make community user number for all instances make_commUsrNum
% clear all
place=1;%0 for home, anything else for work
if place==0
    placeName='C:\Users\konst\Documents\MATLAB';
elseif place==154
    placeName='\\160.40.50.70\F$\Dropbox\ÉÐÔÇË\MATLAB\';
else
    placeName='F:\Dropbox\ÉÐÔÇË\MATLAB\';
end
datasetName='\cycling_WomensRoad_tags'; 
placeName=[placeName,datasetName];
timeSeg=600;%[600 1800 3600 21600 43200 86400] Snapshot every so many secs
CommDir=dir([placeName,'\mats\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\adjMat*.mat']);
lDir=length(CommDir);
%%%%%%%%%%%%%%
tic
for k=1:lDir
    load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(k),'.mat'],'strComms');
    load([placeName,'\mats\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(k),'.mat']);
    commUsrNum=zeros(length(tempUsers),1);
    for lTU=1:length(strComms)
        comm=strComms{lTU};
        loc=ismember(tempUsers,comm);
        commUsrNum(loc)=lTU;
    end
    toc
    save([placeName,'\mats\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\commUsrNum_',num2str(k),'.mat'],'commUsrNum');
end
