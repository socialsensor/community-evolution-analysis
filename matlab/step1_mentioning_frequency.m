%step1_mentioning_frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user activity in respect to twitter mentions. %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function line below accordingly                      %
% The data to be analysed is in the ../data folder                        %
% If there are more than one txt files in the ../data folder containing   %
% the data please number them incrementally starting with 1 (norton       %
% commander is a good tool)      										  %
% The user is prompted to select the time sampling interval that seems    %
% more appropriate for the specific dataset.                              %
% A time sampling interval of 43200secs was selected for the PCI13 dataset%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function timeSeg=step1_mentioning_frequency(folder_name,show_plots) %%Comment this line if you need the script
%%%%%%%%%%%%%%
% standalone script %%comment the following two lines if you need the fn
%folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
%show_plots=1; %set show_plots to 0 if the plots are not to be shown
%%%%%%%%%%%%%%
mkdir([folder_name,'\data\mats']);mkdir([folder_name,'\data\txts']);
dbstop if error
lenDir=length(dir([folder_name,'\data\*.txt'])); %number of txt files in the folder
if lenDir>1 %if the data is contained in multiple files
    templA=1;
    for txtfile=1:lenDir
        fid = fopen([folder_name,'\data\',num2str(txtfile),'.txt']);
        C = textscan(fid,'%*s %*s %q %*[^\n]', 'CollectOutput');
        fclose(fid);
        lngth=length(C{1})+templA-1;
        time(templA:lngth,1)=C{1};
        templA=length(time)+1;
    end
else
    fid = fopen([folder_name,'\data\1.txt']); %if the data is contained in a single file
    C = textscan(fid,'%*s %*s %q %*[^\n]', 'CollectOutput');
    fclose(fid);
    time=C{1};
end
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
timeSegCopy=[600 1800 3600 21600 43200 86400];
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
saveTimeDif = ([folder_name,'\data\mats\TimeDif.mat']);
save(saveTimeDif, 'timeDif');%save the time difference from one mention to the next
%%Plot the activity graphs (these following parameters and text are specific to the PCI13 paper dataset)
if show_plots==1
    mentionsPer={'10min intervals' '30min intervals' '1hour intervals' '6hour intervals' '12hour intervals' '1day intervals'};
    realDays=length(freqStat);
    timeSeg=[600 1800 3600 21600 43200 86400];
    maxDateinSecs=max(timeSeg)*realDays;
    %The following dates only apply to the PCI13 dataset. Comment for
    %different datasets.
    dates=cell(realDays,1);
    for k=1:4:25
        dates{k,1}=[num2str(k+3),'/02'];
    end
    for k=29:4:56
        dates{k,1}=[num2str(k-25),'/03'];
    end
    for k=57:4:86
        dates{k,1}=[num2str(k-56),'/04'];
    end
    for k=87:4:93
        dates{k,1}=[num2str(k-86),'/05'];
    end
    figure;
    for i=1:length(timeSeg)
        load([folder_name,'\data\mats\MentionFreqPer_',num2str(timeSeg(i)),'_secs.mat']);
        load([folder_name,'\data\mats\POI_',num2str(timeSeg(i)),'.mat'],'POI');
        j=i;
        if i>3
            j=i-3;
            if i==4
                figure;
            end
        end
        hold on
        subplot(3,1,j), plot(freqStat), xlabel('Date'), ylabel(['User Activity (#tweets/',num2str(timeSeg(i)/3600),')']), xlim([1 maxDateinSecs/timeSeg(i)]);
        set(gca,'Xtick',1:max(timeSeg)/timeSeg(i):maxDateinSecs/timeSeg(i),'XTickLabel',dates,'XGrid','on');
        hold
        subplot(3,1,j), plot(POI,freqStat(POI),'ro'), xlim([0 maxDateinSecs/timeSeg(i)]);
        hold off
    end
end
timeSeg={600 1800 3600 21600 43200 86400}; %Snapshot every timeSeg secs
choice = menu('Please select sampling rate...',timeSeg);
timeSeg=timeSeg{choice};




