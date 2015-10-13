num_files= 85;

for which = 0:1
    fnames = {};
    scores = {};
    tieIndex = {};
    gt = {};
    for i = 1:num_files
        file_idx = i-1;
        fname = scores_file_name2(file_idx, which);
        [scores{i}, tieIndex{i}, gt{i}] = read_scores_file(fname);
        fnames{i} = fname(find(fname=='/',1,'last')+1:end);
    end

    switch which
        case 0
            save scores_crumbling.mat fnames scores tieIndex gt
        case 1
            save scores_chipped.mat fnames scores tieIndex gt
    end
end