function [] = show_roc(scores, gt)

n = 0;
for i = 1:length(scores)
    % Remove outliers
    if i==71, continue, end
    
    n = n + numel(scores{i});
end
s = zeros(n,1);     % Sequential scores
t = zeros(n,1);     % Sequential true values
n = 0;
for i = 1:length(scores)
    % Remove outliers
    if i==71, continue, end
    
    l = numel(scores{i});
    s(n+1:n+l) = scores{i}(:);
    t(n+1:n+l) = gt{i}(:)~=0;
    n = n + l;
end
[si,idx] = sort(s(:,1));
num_pos = nnz(t);
num_neg = n-num_pos;
pd=cumsum(t(idx))/num_pos;
pfa=cumsum(~t(idx))/num_neg;

plot(pfa,pd);
axis([0 0.02 0.9 1]);
grid on
auc = sum(([pfa; 1]-[0; pfa]).*([pd; 1]+[0; pd]))/2;
title(sprintf('AUC = %.6f', auc));
fprintf('AUC = %.6f\n', auc);
