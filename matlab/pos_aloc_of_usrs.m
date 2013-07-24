function [posAuthor,posMention,uniqueUsers,tempUsers]=pos_aloc_of_usrs(authors,mentions,sesStart,sesEnd,uniqueUsers)
%new in this vers: unique users sequentially from all the timesteps and
%temporary users from each single timestep
%txt files have been processed to separate mentions in same tweet
%this is the fastest position allocator so far
authors=authors(sesStart:sesEnd);
mentions=mentions(sesStart:sesEnd);
uniqueMentions=unique(mentions);
uniqueAuthors=unique(authors);
uniqueUsers=unique([uniqueUsers;uniqueAuthors;uniqueMentions],'stable');
tempUsers=unique([uniqueAuthors; uniqueMentions]);
clear uniqueAuthors uniqueMentions

[~,posAuthor]=ismember(authors,tempUsers);%find position of author in uniquenames
% posAuthor=single(posAuthor);
[~,posMention]=ismember(mentions,tempUsers);%find position of mentions in uniquenames
% posMention=single(posMention);