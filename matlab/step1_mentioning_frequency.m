%step1_mentioning_frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user activity in respect to twitter mentions. %
% The preprocessed data file is acquired from the python scipt 			  %
% "json_parser_singlefile.py" if json files are available or from the     %	
% "authorMentionTimeParser" if txt files are available.					  %
% It can either work as a standalone script or as a function for the main %
% m-file.                                                                 %
% Please comment the function line below accordingly                      %
% The user is prompted to select the time sampling interval that seems    %
% more appropriate for the specific txtsset.                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function timeSeg=step1_mentioning_frequency(folder_name,show_plots) %%Comment this line if you need the script
%%%%%%%%%%%%%%
% standalone script %%comment the following two lines if you need the fn
folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
show_plots=1; %set show_plots to 0 if the plots are not to be shown
%%%%%%%%%%%%%%
mkdir([folder_name,'\matlab\mats']);mkdir([folder_name,'\matlab\txts']);
dbstop if error
    fid = fopen([folder_name,'\txts\authors_mentions_time.txt']); %if the txts is contained in a single file
    C = textscan(fid,'%s %s %q %*[^\n]', 'CollectOutput');
    fclose(fid);
    time=C{3};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extract time vectors from the time stamps
lT=length(time);
datetime=cell(lT,1);
if ~matlabpool('size')
    matlabpool open
end
parfor xa=1:lT
    datetime{xa}=datevec(time{xa},'ddd mmm dd HH:MM:SS yyyy')
end
clear time
matlabpool close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeDif=single(zeros(lT,1)); timeini=datetime{1,:};
timeSegCopy={600 1800 3600 21600 43200 86400}; %Snapshot every so many secs
for timeSeg=[600 1800 3600 21600 43200 86400] %Please provide sampling time intervals in seconds
    curTime=0;
    bin=1;
    freqStat=0;freqStatIni=0;freqStatMoved=0;
    mentionLimit=0;
    for i=1:lT  %create a list of mentions in separate cells and time differences
        if not(timeSeg-timeSegCopy(1))
            %time difference from one mention to the next (it only runs once)
            timeDif(i)=etime(datetime{i,:},timeini);
        end
        curTime=curTime+timeDif(i);
        timeini=datetime{i,:};
        if curTime<=timeSeg
            freqStat(bin)=freqStat(bin)+1;
        else
            curTime=0;
            mentionLimit(bin)=i;
            bin=bin+1;
            freqStat(bin)=0;
        end
    end
    %save the mentioning activity vector
    saveFreq = ([folder_name,'\matlab\mats\MentionFreqPer_',num2str(timeSeg),'_secs.mat']);
    save(saveFreq,'freqStat');
    mentionLimit(bin)=i;
    save([folder_name,'\matlab\mats\mentionLim_',num2str(timeSeg),'.mat'],'mentionLimit');
    % Discrete First Derivative of the mentioning frequency per time vector
    freqStatIni(length(freqStat)+1)=0;
    freqStatIni(1:length(freqStat))=freqStat;
    freqStatMoved(2:(length(freqStat)+1))=freqStat;
    firstderiv=freqStatIni-freqStatMoved;
    save([folder_name,'\matlab\mats\firstderiv_',num2str(timeSeg),'.mat'],'firstderiv');%save the first derivative
    %%Discover Points of Interest
    counter=1;
    for k=1:length(mentionLimit)
        if firstderiv(k)<0 && firstderiv(k+1)>=0
            POI(counter)=k;
            counter=counter+1;
        end
    end
    if exist('POI')
        save([folder_name,'\matlab\mats\POI_',num2str(timeSeg),'.mat'],'POI');
    end
    clear POI
end
saveTimeDif = ([folder_name,'\matlab\mats\TimeDif.mat']);
save(saveTimeDif, 'timeDif');%save the time difference from one mention to the next
%%Plot the activity graphs (these following parameters and text are specific to the PCI13 paper txtsset)
if show_plots==1
    mentionsPer={'10min intervals' '30min intervals' '1hour intervals' '6hour intervals' '12hour intervals' '1day intervals'};
    realDays=length(freqStat);
    maxDateinSecs=max(timeSegCopy)*realDays;
%     %The following dates only apply to the PCI13 txtsset. Comment for
%     %different txtssets.
%     dates=cell(realDays,1);
%     for k=1:4:25
%         dates{k,1}=[num2str(k+3),'/02'];
%     end
%     for k=29:4:56
%         dates{k,1}=[num2str(k-25),'/03'];
%     end
%     for k=57:4:86
%         dates{k,1}=[num2str(k-56),'/04'];
%     end
%     for k=87:4:93
%         dates{k,1}=[num2str(k-86),'/05'];
%     end
    figure;
    for i=1:length(timeSegCopy)
        load([folder_name,'\matlab\mats\MentionFreqPer_',num2str(timeSegCopy(i)),'_secs.mat']);
        load([folder_name,'\matlab\mats\POI_',num2str(timeSegCopy(i)),'.mat'],'POI');
        j=i;
        if i>3
            j=i-3;
            if i==4
                figure;
            end
        end
        hold on
        subplot(3,1,j), plot(freqStat), xlabel('Date'), ylabel(['User Activity (#tweets/',num2str(timeSegCopy(i)/3600),')']), xlim([1 maxDateinSecs/timeSegCopy(i)]);
        set(gca,'Xtick',1:max(timeSegCopy)/timeSegCopy(i):maxDateinSecs/timeSegCopy(i),'XGrid','on');%'XTickLabel',dates,
        hold
        subplot(3,1,j), plot(POI,freqStat(POI),'ro'), xlim([0 maxDateinSecs/timeSegCopy(i)]);
        hold off
    end
end
%Selection of Snapshot every timeSegCopy secs
choice = menu('Please select sampling rate...',timeSegCopy);
timeSeg=timeSegCopy{choice};




