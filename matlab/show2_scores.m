function [] = show2_scores(data, adapt_scores, idx)

tieIndex = data.tieIndex{idx};
gt = data.gt{idx};
s1 = data.scores{idx};
s2 = adapt_scores{idx} - 1.8102;
for j = 1:4
    subplot(4,1,j);
    gt2 = nan(length(tieIndex),1);
    gt2(gt(:,j)>0) = 0;
    plot(tieIndex, s1(:,j), tieIndex, s2(:,j), tieIndex, gt2, 'ko');
    grid on
    axis([min(tieIndex(1),tieIndex(end)) max(tieIndex(1),tieIndex(end)) -2 2]);
    if j==1, title(data.fnames{idx}), end
end

end