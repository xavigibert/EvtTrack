function [] = show_scores(file_idx, subset_idx)

fname = scores_file_name(file_idx, 0, subset_idx);
[shog, tieIndex, gt] = read_scores_file(fname);
[scnn, ~, ~] = read_scores_file(scores_file_name(file_idx, 1, subset_idx));
shog = shog - 0.1614;
scnn = scnn - 0.1070;
r = 1:length(tieIndex);

fname1 = fname(find(fname=='/',1,'last')+1:end);
fname = [];
for j = 1:length(fname1)
    if fname1(j)=='_'
        fname = [fname '\_'];
    else
        fname = [fname fname1(j)];
    end
end

for j = 1:4
    subplot(4,1,j);
    gt2 = nan(length(tieIndex),1);
    gt2(gt(:,j)>0) = 0;
    %plot(r, shog(:,j), r, scnn(:,j), r, gt2, 'x');
    splitIdx = mod(tieIndex, 5);
    scnn0 = scnn(splitIdx==0,:);
    r0 = r(splitIdx==0);
    scnn1 = scnn(splitIdx==1,:);
    r1 = r(splitIdx==1);
    scnn2 = scnn(splitIdx==2,:);
    r2 = r(splitIdx==2);
    scnn3 = scnn(splitIdx==3,:);
    r3 = r(splitIdx==3);
    scnn4 = scnn(splitIdx==4,:);
    r4 = r(splitIdx==4);
    plot(r0, scnn0(:,j), r1, scnn1(:,j), r2, scnn2(:,j), r3, scnn3(:,j), r4, scnn4(:,j), r, gt2, 'ko');
    grid on
    axis([1 length(shog) -2 2]);
    if j==1, title(fname), end
end
