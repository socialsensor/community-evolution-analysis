%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file writes a csv file of all the dataset's unique users for use%
% with the python scipts json_retweet_finder or json_dyn_retweet_finder.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function uniqueUsers_CSV_wr(folder_name,timeSeg)
%stand alone script %%comment the following 4 lines if you need the fn
folder_name=uigetdir;
 timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
 choice = menu('Please select sampling rate...',timeSegCopy); 
 timeSeg=timeSegCopy{choice};
%%%%%%%%%%%%%%
load([placeName,'\mats\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\uniqueUsers.mat'],'uniqueUsers');

fid = fopen([placeName,'\txts\adjMats\dynamic\timeSeg_',num2str(timeSeg),'\uniqueUsers.csv'],'w');
for row=1:length(uniqueUsers);
    fprintf(fid,'%s %d\n', uniqueUsers{row,:},0);
end
fclose(fid);
toc