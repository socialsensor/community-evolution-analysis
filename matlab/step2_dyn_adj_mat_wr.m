%step2_dyn_adj_mat_wr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the dynamic adjacency matrices for each respective%
% timeslot and save it into a mat format for use with the rest of the code%
% but also in a csv gephi-ready format. 								  %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function line below accordingly                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step2_dyn_adj_mat_wr(folder_name,timeSeg) %%Comment this line if you need the script
%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
% choice = menu('Please select sampling rate...',timeSegCopy); 
% timeSeg=timeSegCopy{choice};
%%%%%%%%%%%%%%
lenDir=length(dir([folder_name,'*.txt'])); %number of txt files in the folder
txtStartFile=1;
if lenDir>1 %if the data is contained in multiple files
    txtEndFile=lenDir;
else %if the data is contained in a single file
    txtEndFile=txtStartFile;
end
mkdir(folder_name,['\data\txts\adjMats\timeSeg_',num2str(timeSeg)]);
mkdir(folder_name,['\data\mats\adjMats\timeSeg_',num2str(timeSeg)]);
templA=1;
for txtfile=txtStartFile:txtEndFile
    fid = fopen([folder_name,'\data\',num2str(txtfile),'.txt']);
    C = textscan(fid,'%s %s %*[^\n]', 'CollectOutput');%extract mentioners and mentioned users
    fclose(fid);
    lngth=length(C{1})+templA-1;
    authors(templA:lngth,1)=C{1}; mentions(templA:lngth,1)=C{2};%complete authors & mentions
    templA=length(authors)+1;
end
C{1}=authors; C{2}=mentions;
clear authors mentions fid lngth templA txtStartFile txtEndFile place
load([folder_name,'\data\mats\mentionLim_',num2str(timeSeg),'.mat'],'mentionLimit');
load([folder_name,'\data\mats\firstderiv_',num2str(timeSeg),'.mat'],'firstderiv');
firstderiv(end)=0;
sesStart=1;
bin=1;
uniqueUsers={};
for k=1:length(mentionLimit)
    if firstderiv(k)<0 && firstderiv(k+1)>=0
        sesEnd=mentionLimit(k);
        %find the position of the authors and the mentions
        [posAuthor,posMention,commaPos,mentionLengths,uniqueUsers,tempUsers]=pos_aloc_of_usrs(C,sesStart,sesEnd,uniqueUsers);
        %create the sparse adjacency matrix
        adjMat=adj_mat_creator(posAuthor,posMention,commaPos,mentionLengths,tempUsers);
        
        [authIdx,mentIdx,weight] = find(adjMat);
        authors=tempUsers(authIdx);
        mentioned=tempUsers(mentIdx);
        %save csvs of all the dynamic adjacency matrices in gephi-ready
        %form (the file name numbers correspond to the various POIs)
        fid = fopen([folder_name,'\data\txts\adjMats\timeSeg_',num2str(timeSeg),'\',num2str(k),'.csv'],'w');
        fprintf(fid,'%s\n','Source,Target,Weight');
        for row=1:length(authIdx);
            fprintf(fid,'%s,%s,%d\r\n', authors{row,:},mentioned{row,:},weight(row,:));
        end
        fclose(fid);
        %save mats of all the dynamic adjacency matrices
        save([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat_',num2str(bin),'.mat'],'adjMat');
        %save mats of all the users in each time step (corresponding to the
        %dynamic adjacency matrices) This is done to save complexity/time
        save([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(bin),'.mat'],'tempUsers');
        sesStart=sesEnd+1;
        bin=bin+1;
    end
end
%save a mat of a cell array containing all unique users' names
save([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\uniqueUsers.mat'],'uniqueUsers');

