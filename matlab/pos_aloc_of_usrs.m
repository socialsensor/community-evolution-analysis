% pos_aloc_of_usrs.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file creates two vectors flagging the position of each user from%
% each post.                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [posAuthor,posMention,uniqueUsers,tempUsers]=pos_aloc_of_usrs(authors,mentions,sesStart,sesEnd,uniqueUsers)
authors=authors(sesStart:sesEnd);
mentions=mentions(sesStart:sesEnd);
uniqueMentions=unique(mentions);
uniqueAuthors=unique(authors);
uniqueUsers=unique([uniqueUsers;uniqueAuthors;uniqueMentions],'stable');
tempUsers=unique([uniqueAuthors; uniqueMentions]);
clear uniqueAuthors uniqueMentions

[~,posAuthor]=ismember(authors,tempUsers);%find position of author in uniquenames
[~,posMention]=ismember(mentions,tempUsers);%find position of mentions in uniquenames