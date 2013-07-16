% step4_comm_evol_detect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file detects the evolution of the communities between timeslots.%
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step4_comm_evol_detect(folder_name,timeSeg) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy);
% timeSeg=timeSegCopy{choice};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CommDir=dir([placeName,'\mats\timeSeg_',num2str(timeSeg),'\strComms*.mat']);
lDir=length(CommDir);
if ~matlabpool('size')
	matlabpool open
end
% In order to test different thresholds run the following section once and then comment 
% and uncomment the loads below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numCommBags=cell(lDir,1);
% strCommBags=cell(lDir,1);
% lC=zeros(lDir,1);
% load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\commSizes.mat'],'commSizes');
% for i=1:lDir
%     load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat']);
%     lC(i)=length(find(cell2mat(commSizes(i,:))>2));
% end
% clear commSizes
% load([placeName,'\mats\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\uniqueUsers.mat'],'uniqueUsers');
% uniqueUsers=uniqueUsers;
% tic
% for i=1:lDir
%     load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat'],'strComms');
%     strComms=strComms;
%     parfor k=1:lC(i)
%         [~,tempnumbags]=ismember(strComms{k},uniqueUsers);
%         numCommBags{i,k}=tempnumbags;
%     end
%     strCommBags(i,1:lC(i))=strComms(1:lC(i));
%     toc
% end
% save([placeName,'\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
% save([placeName,'\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat'],'lC');
% save([placeName,'\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags');
load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat'],'lC');
maxlC=max(lC);
% %find similar communities in previous snapshots
% numCommBags=numCommBags;
clear CommDir numComms i place commSizes
tic
for i=2:lDir
    tempmaxLike=cell(1,maxlC);
    for j=1:lC(i)
        bag1=numCommBags{i,j};
        tempcommSize=numel(bag1);
        if tempcommSize>9999
            thres=.05;
        elseif tempcommSize>999
            thres=.1;
        elseif tempcommSize>99
            thres=.15;
        elseif tempcommSize>29
            thres=.2;
        elseif tempcommSize>7
            thres=.3;
        else
            thres=.41;
        end
        mytemp=sparse(i-1,maxlC);
        for ltmemp=1:3
            l=i-ltmemp;
            if l>0
                templC=lC(l);
                parfor k=1:templC
                    tmp=numel(numCommBags{l,k});
                    if  tempcommSize>tmp && (tmp/tempcommSize)>thres
                        mytemp(l,k)=sum(ismember(numCommBags{l,k},bag1))/numel(unique([bag1;numCommBags{l,k}]));
                    elseif tempcommSize<tmp && (tempcommSize/tmp)>thres
                        mytemp(l,k)=sum(ismember(bag1,numCommBags{l,k}))/numel(unique([bag1;numCommBags{l,k}]));
                    else
                        continue
                    end
                end
				%%if a similar community is detected in previous timeslots, the search continues to the next community
                if max(mytemp(l,:))>=thres
                    break
                end
            end
        end
        tempmaxLike{j}=sparse(mytemp);
    end
    toc
    save([placeName,'\mats\timeSeg_',num2str(timeSeg),'\tempmaxLike_',num2str(i),'.mat'],'tempmaxLike');
    clear tempmaxLike
end
% 
%find maximum similarity between communities to speed up the process
tic
maxCommSimPercentage=sparse((lDir),maxlC);
for i=2:(lDir)
    load([placeName,'\mats\timeSeg_',num2str(timeSeg),'\tempmaxLike_',num2str(i),'.mat'],'tempmaxLike');
    parfor j=1:maxlC
        if ~isempty(tempmaxLike{j});
            maxCommSimPercentage(i,j)=full(max(max(tempmaxLike{j})));
        end
    end
    clear tempmaxLike
    toc
end
matlabpool close
maxCommSimPercentage=full(maxCommSimPercentage);
save([placeName,'\mats\timeSeg_',num2str(timeSeg),'\numMaxCommSimPercentage_jacc.mat'],'maxCommSimPercentage');
