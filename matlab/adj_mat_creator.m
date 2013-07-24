% adj_mat_creator.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes the extracted variables from the pos_aloc_of_usrs   %
% function and creates the adjacency matrix for each time step.           %
% An additional option of the function is to remove the self mentions.    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function adjMat=adj_mat_creator(posAuthor,posMention,tempUsers)
%---------------------------------------------------------------------
lU=length(tempUsers);
adjMat = sparse(posAuthor,posMention,1,lU,lU,nnz(posAuthor));


% remove self mentions (self-loops) (optional)
adjMat(1:(length(adjMat)+1):length(adjMat)^2)=0;