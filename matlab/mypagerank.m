% mypagerank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user page rank of an adjacency matrix         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myPageRank=mypagerank(adjMat,alpha,quadratic_error) %,tenCentralUsers ,txtfile
adjMat=adjMat';
lenAdjMat=size(adjMat,2);
clmnSum = sum(adjMat,1);
zrClmS = find(clmnSum~=0);
mspar = sparse(zrClmS,zrClmS,1./clmnSum(zrClmS),lenAdjMat,lenAdjMat);
adjOnes = ones(lenAdjMat,1);
z = ((1-alpha)*(clmnSum~=0) + (clmnSum==0))/lenAdjMat;
adjMat = alpha*adjMat*mspar;
normAdjOnes = adjOnes/lenAdjMat;
oldx = zeros(lenAdjMat,1);
while norm(normAdjOnes - oldx) > quadratic_error
oldx = normAdjOnes;
normAdjOnes = adjMat*normAdjOnes + adjOnes*(z*normAdjOnes);
end
myPageRank = normAdjOnes;
