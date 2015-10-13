function [result] = filter_mc(scores)

% Analyze tail of PDF
s = sort(scores);
% Find point at 0.005
idx = max(1,floor(length(scores)*0.5));
result = scores-scores(idx);
