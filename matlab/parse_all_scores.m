num_files= 85;
feat_idx = 1;       % CNN

for subset_idx = 1:3
    fnames = {};
    scores = {};
    tieIndex = {};
    gt = {};
    for i = 1:num_files
        file_idx = i-1;
        fname = scores_file_name(file_idx, feat_idx, subset_idx);
        [scores{i}, tieIndex{i}, gt{i}] = read_scores_file(fname);
        fnames{i} = fname(find(fname=='/',1,'last')+1:end);
    end

    switch subset_idx
        case 1
            save scores_cnn_clear.mat fnames scores tieIndex gt
        case 2
            save scores_cnn_switch.mat fnames scores tieIndex gt
        case 3
            save scores_cnn_all.mat fnames scores tieIndex gt
    end
end