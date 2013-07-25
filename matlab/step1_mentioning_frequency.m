%step1_mentioning_frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user activity in respect to twitter mentions. %
% The preprocessed data file is acquired from the python scipt 			  %
% "json_parser_singlefile.py" if json files are available or from the     %
% "authorMentionTimeParser" if txt files are available.					  %
% It can either work as a standalone script or as a function for the main %
% m-file. Please comment the function line below accordingly              %
% The user is prompted to select the time sampling interval that seems    %
% more appropriate for the specific txtsset.                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function timeSeg=step1_mentioning_frequency(folder_name,show_plots) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%stand alone script %%comment the following 4 lines if you need the fn
%folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
%show_plots = 1; %% should be set to 1 if the plots are to be shown and to 0 if not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir([folder_name,'\data\mats']);mkdir([folder_name,'\data\txts']);
fid = fopen([folder_name,'\data\authors_mentions_time.txt']); 
C = textscan(fid,'%*s %*s %d %*[^\n]', 'CollectOutput');
fclose(fid);
time=C{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%time difference from one mention to the next
time2=cat(1,time(1),time);time2=time2(1:end-1);
timeDif=single(time-time2);
lT=length(time);
clear time time2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeSegCopy={600 900 1200 1800 2700 3600}; %Snapshot every so many secs
for timeSeg=[600 900 1200 1800 2700 3600] %Please provide sampling time intervals in seconds
    curTime=0;
    bin=1;
    freqStat=0;freqStatIni=0;freqStatMoved=0;
    mentionLimit=0;
    for i=1:lT  %create a list of mentions in separate cells and time differences
        curTime=curTime+timeDif(i);
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
    saveFreq = ([folder_name,'\data\mats\MentionFreqPer_',num2str(timeSeg),'_secs.mat']);
    save(saveFreq,'freqStat');
    mentionLimit(bin)=i;
    save([folder_name,'\data\mats\mentionLim_',num2str(timeSeg),'.mat'],'mentionLimit');
    % Discrete First Derivative of the mentioning frequency per time vector
    freqStatIni(length(freqStat)+1)=0;
    freqStatIni(1:length(freqStat))=freqStat;
    freqStatMoved(2:(length(freqStat)+1))=freqStat;
    firstderiv=freqStatIni-freqStatMoved;
    save([folder_name,'\data\mats\firstderiv_',num2str(timeSeg),'.mat'],'firstderiv');%save the first derivative
    %%Discover Points of Interest
    counter=1;
    for k=1:length(mentionLimit)
        if firstderiv(k)<0 && firstderiv(k+1)>=0
            POI(counter)=k;
            counter=counter+1;
        end
    end
    if exist('POI')
        save([folder_name,'\data\mats\POI_',num2str(timeSeg),'.mat'],'POI');
    end
    clear POI
end
%%Plot the activity graphs (these following parameters and text are specific to the PCI13 paper txtsset)
mkdir([folder_name,'\data\figures']);
if show_plots==1
    mentionsPer={'10min intervals' '15min intervals' '20min intervals' '30min intervals' '45min intervals' '60min intervals'};
    realDays=length(freqStat);
    maxDateinSecs=max(cell2mat(timeSegCopy))*realDays;
    h=figure;
    bin=1;
    for i=1:length(timeSegCopy)
        load([folder_name,'\data\mats\MentionFreqPer_',num2str(timeSegCopy{i}),'_secs.mat']);
        load([folder_name,'\data\mats\POI_',num2str(timeSegCopy{i}),'.mat'],'POI');
        j=i;
        if i>3
            j=i-3;
            if i==4
                h=figure;
            end
        end
        hold on
        subplot(3,1,j), plot(freqStat), xlabel('Hours'), ylabel(['User Activity (#tweets/',num2str(timeSegCopy{i}/3600),')']), xlim([1 maxDateinSecs/timeSegCopy{i}]);
        set(gca,'Xtick',1:max(cell2mat(timeSegCopy))/timeSegCopy{i}:maxDateinSecs/timeSegCopy{i},'XGrid','on');%'XTickLabel',dates,
        hold
        subplot(3,1,j), plot(POI,freqStat(POI),'ro'), xlim([0 maxDateinSecs/timeSegCopy{i}]);
        hold off
        if i==4 || i==6
           saveas(h, [folder_name,'\data\figures\',num2str(bin),'.fig'],'fig');
           saveas(h, [folder_name,'\data\figures\',num2str(bin),'.jpg'],'jpg');
           bin=bin+1;
        end            
    end
end
%Selection of Snapshot every timeSegCopy secs
choice = menu('Please select sampling rate...',timeSegCopy);
timeSeg=timeSegCopy{choice};




