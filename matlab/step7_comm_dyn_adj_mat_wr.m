% step7_comm_dyn_adj_mat_wr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the community adjacency matrix in between         %
% timeslots. (In this case, the communities are treated as users.)                 %
% The commAdjMats are written in mat format but also as csvs for gephi    %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step7_comm_dyn_adj_mat_wr(folder_name,timeSeg) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

CommDir=dir([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat*.mat']);
lDir=length(CommDir);

for k=1:lDir
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat_',num2str(k),'.mat']);
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(k),'.mat'],'strComms');
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(k),'.mat']);
    load([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\tempUsersCommNums_',num2str(k),'.mat'],'tempUsersCommNums');
    %%%%%%%%%%%%%%%%%%%
    lStrComm=length(find(cellfun(@numel,strComms)>2));%find all the communities which consist of 3 members or more 
    lTempUsrs=length(tempUsers);
    commAuth=[];weight=[];commMent=[];
    for i=1:lStrComm
        comm=strComms{i}; %community in hand
        [~,locb]=ismember(comm,tempUsers(:,1)); %user indices in the community
        tempAdjMat=sparse(lTempUsrs,lTempUsrs);
        tempAdjMat(:,locb)=adjMat(:,locb);%indices of who mentioned users in community i
        tempAdjMat(locb,locb)=0;%disregard mentions between members of the same community
        tempAdjMat=sum(tempAdjMat,2);%sum of users who mentioned community i
        nzMent=find(tempAdjMat);%indices of users mentioning comm i
        commAuth=cat(1,commAuth,tempUsersCommNums(nzMent)');%creating rows of mentioner comm Ids by concatenation
        weight=cat(1,weight,tempAdjMat(nzMent));%creating rows of weight by concatenation
        commtmp=ones(length(nzMent),1)*i;%creating rows of mentioned comm Ids by concatenation
        commMent=cat(1,commMent,commtmp);
    end
    lStrCommFull=length(strComms);
	% Construction of the community adjacency matrix
    commAdjMat = sparse(commAuth,commMent,weight,lStrCommFull,lStrCommFull,nnz(weight));
    save([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\commAdjMat_',num2str(k),'.mat'],'commAdjMat');
    %%%%%%%%write csvs for use with gephi
    [authIdx,mentIdx,weight] = find(commAdjMat);
    fid = fopen([folder_name,'\data\txts\adjMats\timeSeg_',num2str(timeSeg),'\adjComm_',num2str(k),'.csv'],'w');
    fprintf(fid,'%s\n','Source,Target,Weight');
    for row=1:length(authIdx);
        fprintf(fid,'%d,%d,%d\r\n', authIdx(row,:),mentIdx(row,:),weight(row,:));
    end
    fclose(fid);
    clear tempAdjMat commAdjMat
    
end


