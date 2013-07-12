% pos_aloc_of_usrs.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file creates two vectors flagging the position of each user from%
% each post.                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [posAuthor,posMention,commaPos,mentionLengths,uniqueUsers,tempUsers]=pos_aloc_of_usrs(C,sesStart,sesEnd,uniqueUsers)
authors=C{1}(sesStart:sesEnd);mentions=C{2}(sesStart:sesEnd);
clear C
%find posts which contain more than one mentions
findCommas=strfind(mentions,',');
emptyCell=cellfun(@isempty,findCommas);clear  findCommas
commaPos=single(find(~emptyCell));
mentionsList=mentions;
mentionsIni=mentions;
for i=1:length(commaPos)
    mentions(commaPos(i),1)=textscan(mentions{commaPos(i),1},'%s','Delimiter',',');
    a=length(mentions{commaPos(i),1});
    while a>1
        mentionsList(length(mentionsList)+1,1)=mentions{commaPos(i),1}(a,:);
        a=a-1;
        if a==1
            mentionsList(commaPos(i),1)=mentions{commaPos(i),1}(1,:);
        end
    end
end
uniqueMentions=unique(mentionsList); clear mentionsList;
uniqueAuthors=unique(authors);
uniqueUsers=unique([uniqueUsers;uniqueAuthors;uniqueMentions],'stable');
tempUsers=unique([uniqueAuthors; uniqueMentions]);
clear uniqueAuthors uniqueMentions

mentionLengths=single(cellfun(@numel,mentions));
mentionLengths(emptyCell)=single(1);
%find position of author in tempUsers
[~,posAuthor]=ismember(authors,tempUsers);
posAuthor=single(posAuthor);
%find position of mention in tempUsers (unit length)
posMention=spalloc(length(mentionLengths),double(max(mentionLengths)),double(sum(mentionLengths)));
[~,posMention(:,1)]=ismember(mentionsIni,tempUsers);
for i=1:length(commaPos);
    for j=1:mentionLengths(commaPos(i));
    [posMention(commaPos(i),j),~]=find(strcmp(mentions{commaPos(i),1}(j),tempUsers));
    end
end