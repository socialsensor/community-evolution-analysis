% adj_mat_creator.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes the extracted variables from the pos_aloc_of_usrs   %
% function and creates the adjacency matrix for each time step.           %
% An additional option of the function is to remove the self mentions     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adjMat=adj_mat_creator(posAuthor,posMention,commaPos,mentionLengths,uniqueUsers)
%---------------------------------------------------------------------
lU=length(uniqueUsers);
% build adjMat for post which have only one mentioned user
adjMat = sparse(double(posAuthor),posMention(:,1),1,lU,lU,nnz(posMention));
% build adjMat for post which have more than one mentioned user
for i=1:length(commaPos)
    for j=2:mentionLengths(commaPos(i));
        adjMat(posAuthor(commaPos(i)),posMention(commaPos(i),j))=adjMat(posAuthor(commaPos(i)),posMention(commaPos(i),j))+1;
    end
end


% remove self mentions (self-loops) (optional)
adjMat(1:(length(adjMat)+1):length(adjMat)^2)=0;