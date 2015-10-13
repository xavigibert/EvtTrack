data = load('scores_cnn_clear.mat');

th = 0.1070;
design_pfa = 0.007;
far = zeros(length(data.scores),4);
mr = zeros(length(data.scores),4);
gold_far = zeros(length(data.scores),4);
adapt_far = zeros(length(data.scores),4);
for i = 1:length(data.scores)
    fprintf('Processing file %d\n', i);
    split = mod(data.tieIndex{i},5);
    for j = 1:4
        for k = 0:4
            s = data.scores{i}(split==k,j) - th;
            t = data.gt{i}(split==k,j);
            neg_scores = s(t==0);
            pos_scores = s(t~=0);
            far(i,j) = far(i,j) + (nnz(neg_scores < 0)/length(neg_scores))/5;
            mr(i,j) = mr(i,j) + nnz(pos_scores > 0);
            
            % Gold standard. Use GPD to adjust PFA to design PFA
            sorted_neg_scores = sort(neg_scores);
            % Take lowest 5% samples to estimate the tail of the PDF
            lower_th = sorted_neg_scores(ceil(length(sorted_neg_scores)*0.05)+1);
            trunc_scores = lower_th - sorted_neg_scores(sorted_neg_scores<lower_th);
            % Fit GPD
            [parmhat,parmci] = gpfit(trunc_scores);
            % Evaluate the inverse CDF of the GPD at design_pfa to find
            % adapted threshold
            adapt_th = lower_th - gpinv(1-design_pfa/0.05,parmhat(1),parmhat(2),0);
            % Compute false alarm rate using the new adapated threshold
            gold_far(i,j) = gold_far(i,j) + (nnz(neg_scores < adapt_th)/length(neg_scores))/5;
            
        end
    end
end
%r=1:length(data.scores);
%figure(2), plot(r,far(:,1),r,far(:,2),r,far(:,3),r,far(:,4));
r=1:numel(far);
figure, plot(r,far(:),r,gold_far(:));
