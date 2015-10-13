function [scores, tieIndex, gt] = read_scores_file(fname)

fprintf('Parsing %s\n', fname);
f = fopen(fname,'r');
version = fread(f,1,'int32=>int32');
fprintf('version = %d\n', version);
if version ~= 1
    fclose(f);
    error('Unsupported version %d', version);
end
num_ties = fread(f,1,'int32=>int32');
fprintf('num_ties = %d\n', num_ties);
tieIndex = zeros(num_ties,1);
scores = zeros(num_ties,4);
gt = zeros(num_ties,4);
for i = 1:num_ties
    tieIndex(i) = fread(f,1,'int32');
    for j = 1:4
        gt(i,j) = fread(f,1,'int32');
        scores(i,j) = fread(f,1,'float');
    end
end
fclose(f);
