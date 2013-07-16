 function myPageRank=mypagerank(adjMat,alpha,quadratic_error) %,tenCentralUsers ,txtfile
%adjMat is the adjacency matrix, pagerank is the pagerank
% clear all;%clc;
% txtfile=1;
% load(['adjMat_',num2str(txtfile),'.mat'],'adjMat');
adjMat=adjMat';
% alpha=0.85;quadratic_error=0.001;
% adjMat = [1 0 0.2 0 1 ; 1.5 0 2 4 0 ; 0.5 0 4 0 1 ; 0 1 0.7 0 1 ; 0 2 0.8 1 0];
% tic
% N = size(adjMat, 2); % N is equal to half the size of adjMat
% clmnSum=sum(adjMat);
% for j=1:N
%    k=find(adjMat(:,j));
%    adjMat(k,j)=adjMat(k,j)./clmnSum(j);
% end
% pagerank = rand(N, 1);
% pagerank = pagerank ./ norm(pagerank, 2);
% last_v = ones(N, 1) * inf;
% M_hat = (alpha .* adjMat) + (((1 - alpha) / N) .* ones(N, N));
%  while(norm(pagerank - last_v, 2) > quadratic_error)
%         last_v = pagerank;
%         pagerank = M_hat * pagerank;
%         pagerank = pagerank ./ norm(pagerank, 2);
%  end
%  toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Page Rank % alpha = 0.85;required to run items below(except for last)
% tic
n=size(adjMat,2);
% delta = (1-alpha)/n;
clmnSum = sum(adjMat,1);
k = find(clmnSum~=0);
D = sparse(k,k,1./clmnSum(k),n,n);
e = ones(n,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%comment from here onwards
% I = speye(n,n);
% x = (I - alpha*adjMat*D)\e;
% x = x/sum(x);
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Conventional power method
z = ((1-alpha)*(clmnSum~=0) + (clmnSum==0))/n;%required to run sparse power method
% A = alpha*adjMat*D + e*z;
% x = e/n;
% oldx = zeros(n,1);
% while norm(x - oldx) > .001
% oldx = x;
% x = A*x;
% end
% x = x/sum(x);
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sparse power method
adjMat = alpha*adjMat*D;
x = e/n;
oldx = zeros(n,1);
while norm(x - oldx) > quadratic_error
oldx = x;
x = adjMat*x + e*(z*x);
end
myPageRank = x;%/sum(x);
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load(['tempUsers_',num2str(txtfile),'.mat']);
% [~,idx]=sort(myPageRank,'descend');
% tenCentralUsers=tempUsers(idx(1:20));


