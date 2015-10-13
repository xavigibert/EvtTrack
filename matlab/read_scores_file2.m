function [sm, sb, ids] = read_scores_file(fname)

fprintf('Parsing %s\n', fname);
f = fopen(fname,'r');
version = fread(f,1,'int32=>int32');
fprintf('version = %d\n', version);
if version ~= 3
    fclose(f);
    error('Unsupported version %d', version);
end
[~] = fread(f,1,'int64=>int64');    % Skip timestamp
num_ties = fread(f,1,'int32=>int32');
fprintf('num_ties = %d\n', num_ties);
sm = nan(num_ties,4);
sb = nan(num_ties,4);
ids = zeros(num_ties,1,'int64');
for i = 1:num_ties
    ids(i) = fread(f,1,'uint64=>uint64');
    for j = 1:4
        num_dets = fread(f,1,'int16=>int16');
        detScoreMissing = zeros(1,num_dets);
        detScoreBroken = zeros(1,num_dets);
        detCl = zeros(1,num_dets);
        for k = 1:num_dets
            [~] = fread(f,1,'int16');   % Skip x
            [~] = fread(f,1,'int32');   % Skip y
            [~] = fread(f,1,'int16');   % Skip w
            [~] = fread(f,1,'int16');   % Skip h
            detCl(k) = fread(f,1,'uint8');  % Read class
            % Class should be 0 => Good/missing
            %              or 2 => Broken
            if detCl(k) ~= 0 && detCl(k) ~= 2
                error('Invalid cl = %d\n', cl);
            end
            [~] = fread(f,1,'uint8');   % Read subclass
            detScoreMissing(k) = fread(f,1,'float');
            detScoreBroken(k) = fread(f,1,'float');
        end
        sm(i,j) = max([nan detScoreMissing(detCl==0)]);
        sb(i,j) = max([nan detScoreBroken(detCl==2)]);
    end
end
fclose(f);
