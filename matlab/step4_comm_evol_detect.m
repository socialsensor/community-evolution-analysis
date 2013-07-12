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
CommDir=dir([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms*.mat']);
lDir=length(CommDir);
if ~matlabpool('size')
    matlabpool open
end
% In order to test different thresholds run the following section once and then comment 
% and uncomment the loads below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numCommBags=cell(lDir,1);
strCommBags=cell(lDir,1);
lC=zeros(lDir,1);
%load communities and make community bags with communities of size 2 and larger
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commSizes.mat'],'commSizes');
for i=1:lDir
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat']);
    lC(i)=length(find(cell2mat(commSizes(i,:))>2));
end
clear commSizes
load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\uniqueUsers.mat'],'uniqueUsers');
uniqueUsers=uniqueUsers;
for i=1:lDir
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat'],'strComms');
    strComms=strComms;
    parfor k=1:lC(i)
        [~,tempnumbags]=ismember(strComms{k},uniqueUsers);
        numCommBags{i,k}=tempnumbags;
    end
    strCommBags(i,1:lC(i))=strComms(1:lC(i));
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat'],'lC');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
% load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat'],'lC');
%find similar communities in previous snapshots
clear CommDir numComms i place commSizes
maxLike=cell((lDir),max(lC));
for i=2:lDir
    for j=1:lC(i)
        bag1=numCommBags{i,j};
        tempcommSize=numel(bag1);
        if tempcommSize>999
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
        mytemp=zeros(i-1,lC(i-1));
        for ltmemp=1:3
            l=i-ltmemp;
            if l>0
                templC=lC(l);
                parfor k=1:templC
                    mytemp(l,k)=(sum(ismember(bag1,numCommBags{l,k})))/numel(union(bag1,numCommBags{l,k}));
                end
                %%if a similar community is detected in previous timeslots, the search continues to the next community
                if max(mytemp(l,:))>=thres
                    break
                end
            end
        end
        maxLike{i,j}=sparse(mytemp);
        clear mytemp
    end
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numMaxLike_back_jacc.mat'],'maxLike');
%find maximum similarity between communities to speed up the process
matlabpool close
maxCommSimPercentage=zeros((lDir),max(lC));
for i=1:(lDir)
    for j=1:max(lC)
        if ~isempty((maxLike{i,j}));
            maxCommSimPercentage(i,j)=full(max(max(maxLike{i,j})));
        end
    end
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numMaxCommSimPercentage_jacc.mat'],'maxCommSimPercentage');

