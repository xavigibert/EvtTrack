function [result] = filter_median(scores,params)

w = params.w;
hw = (w-1)/2;
% Apply symmetric extension
ext = [flipud(scores(1:hw)); scores; flipud(scores(end-hw+1:end))];
result  = zeros(size(scores));
% Subtract second smallest value
for j = 1:length(scores)
    %vals = sort(ext(j:j+w-1));
    %result(j) = scores(j) - vals(7);
    result(j) = scores(j) - median(ext(j:j+w-1));
end
