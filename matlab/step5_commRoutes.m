% step5_commRoutes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file detects the evolution of the communities between timeslots.%
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step5_commRoutes(folder_name,timeSeg) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commLengths.mat']);
lDir=length(lC);                                                                       
commIds=cell(lDir,max(lC));
commNums=cell(lDir,max(lC));
%name first line of communities
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(1),'.mat']);
for j=1:lC(1);%length(numComms)
    commIds{1,j}=['T',num2str(1),',',num2str(j)];
    commNums{1,j}(1,j)=1;
    commNums{1,j}=sparse(commNums{1,j});
end
%do the rest
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numMaxCommSimPercentage_jacc.mat'],'maxCommSimPercentage');
load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commSizes.mat'],'commSizes');
mrgCount=0;splCount=0;birthCount=0;
bin=0;
for i=2:lDir  
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\tempmaxLike_',num2str(i),'.mat'],'tempmaxLike');
    for j=1:lC(i)
        tempcommSize=commSizes(i,j);
        if tempcommSize>999
            thres=.1;
        elseif tempcommSize>99%9
            thres=.15;
        elseif tempcommSize>29
            thres=.2;
        elseif tempcommSize>7
            thres=.3;
        else
            thres=.41;
        end
        if maxCommSimPercentage(i,j)>thres
            [row,colmn]=find(tempmaxLike{j}>thres/2);
            [rowval,rowIdx]=sort(row,'descend');
            %Uncomment the following if section to check for merging 
%             if length(rowIdx)>1 && rowval(1)==rowval(2) 
%                 commIds{i,j}=commIds{row(rowIdx(1)),colmn(rowIdx(1))};
%                 commIds{i,lC(i)+1}=commIds{row(rowIdx(1)),colmn(rowIdx(2))};
%                 bin=bin+1;
%                 tempUniCommIds{bin}=commIds{row(rowIdx(1)),colmn(rowIdx(1))};
%                 bin=bin+1;
%                 tempUniCommIds{bin}=commIds{row(rowIdx(1)),colmn(rowIdx(2))};
%                 commNums{i,j}(row(rowIdx(1)),colmn(rowIdx(1)))=1;
%                 commNums{i,j}(row(rowIdx(2)),colmn(rowIdx(2)))=1;
%                 mrgCount=mrgCount+1;
%             else
                bin=bin+1;
                tempUniCommIds{bin}=commIds{row(rowIdx(1)),colmn(rowIdx(1))};
                commIds{i,j}=commIds{row(rowIdx(1)),colmn(rowIdx(1))}; %simple evolution
                commNums{i,j}=commNums{row(rowIdx(1)),colmn(rowIdx(1))};
%             end
              %Uncomment the following if section to check for splitting
%                         if j>1
%                             str1=commIds{i,j};
%                             strCell=commIds(i,1:(j-1));
%                             splitChk=strcmp(str1,strCell); %check for splitting
%                             findSplit=find(splitChk);
%                             lS=length(findSplit);
%                             if lS>0
%                                 commIds{i,j}=[commIds{i,j},'sp',commIds{i,findSplit(end)}];
%                                 commNums{i,j}=lS+1;
%                                 splCount=splCount+1;
%                             end
%                         end
        else
            %if there's no evolution a new dynamic community is born
            commIds{i,j}=['T',num2str(i),',',num2str(j)];
            commNums{i,j}(i,j)=1;
            commNums{i,j}=sparse(commNums{i,j});
            birthCount=birthCount+1;
        end
    end    
end
uniCommIds=unique(tempUniCommIds,'stable');
%Save a mat file with all the community Ids
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolCommIds.mat'],'commIds');
%Save a mat file with all the respective community Id numbers
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolCommNums.mat'],'commNums');
%Save a mat file with a vector containting all the unique community Ids
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numEvolUniCommIds.mat'],'uniCommIds');


