function [roc] = generate_roc(scores, gt)

n = 0;
for i = 1:length(scores)
    n = n + numel(scores{i});
end
s = zeros(n,1);     % Sequential scores
t = zeros(n,1);     % Sequential true values
n = 0;
for i = 1:length(scores)
    l = numel(scores{i});
    s(n+1:n+l) = scores{i}(:);
    t(n+1:n+l) = gt{i}(:)~=0;
    n = n + l;
end
[~,idx] = sort(s(:,1));
num_pos = nnz(t);
num_neg = n-num_pos;
roc.pd=cumsum(t(idx))/num_pos;
roc.pfa=cumsum(~t(idx))/num_neg;