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
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

CommDir=dir([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms*.mat']);
lDir=length(CommDir);

numCommBags=cell(lDir,1);
strCommBags=cell(lDir,1);
lC=zeros(lDir,1);
%load communities and make community bags with communities of size 2 and larger
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commSizes.mat'],'commSizes');
for i=1:lDir
    lC(i)=length(find(commSizes(i,:)>2));
end
maxlC=max(lC);
clear commSizes
for i=1:lDir
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(i),'.mat'],'strComms');
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numComms',num2str(i),'.mat'],'numComms');
    numCommBags(i,1:lC(i))=numComms(1:lC(i));
    strCommBags(i,1:lC(i))=strComms(1:lC(i));
end
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numCommBags.mat'],'numCommBags');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat'],'lC');
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strCommBags.mat'],'strCommBags');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find similar communities in previous snapshots
clear CommDir numComms i place commSizes
if ~matlabpool('size')
    matlabpool open
end
tic
maxCommSimPercentage=zeros((lDir),max(lC));
for i=2:lDir
    tempmaxLike=cell(1,lC(i));
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
        mytemp=zeros(i-1,maxlC);
        for ltmemp=1:3
            l=i-ltmemp;
            if l>0
                templC=lC(l);
                parfor k=1:templC
                     tmp=numel(numCommBags{l,k});
                     if  (tmp/tempcommSize)>thres && tempcommSize>tmp
                         mytemp(l,k)=sum(ismembc(numCommBags{l,k},bag1))/numel(unique([bag1;numCommBags{l,k}]));
                    elseif (tempcommSize/tmp)>thres && tempcommSize<tmp
                         mytemp(l,k)=sum(ismembc(bag1,numCommBags{l,k}))/numel(unique([bag1;numCommBags{l,k}]));
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
        if max(max(mytemp))>0
            tempmaxLike{j}=sparse(mytemp);
        end
    end    
    %find maximum similarity between communities to speed up the process
    parfor k=1:lC(i)
        if ~isempty(tempmaxLike{k});
            maxCommSimPercentage(i,k)=full(max(max(tempmaxLike{k})));
        end
    end
    save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\tempmaxLike_',num2str(i),'.mat'],'tempmaxLike');
    clear tempmaxLike
    toc
end

% save maximum similarity between communities
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numMaxCommSimPercentage_jacc.mat'],'maxCommSimPercentage');
if matlabpool('size')
    matlabpool close
end