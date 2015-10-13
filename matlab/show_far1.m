data = load('scores_cnn_clear.mat');

% Use complete GPD model without prior

th = 0.1070;
design_pfa = 0.02;
tail_size = 0.1;
far = zeros(length(data.scores),4);
gold_far = zeros(length(data.scores),4);
gold_scores = {};
adapt_far = zeros(length(data.scores),4);
for i = 1:length(data.scores)
    fprintf('Processing file %d\n', i);
    for j = 1:4
        s = data.scores{i}(:,j);
        %t = data.gt{i}(:,j);   % Gold standard without defects
        t = data.scores{i}(:,j) < th;    % Actual performance with defects
        neg_scores = s(t==0);
        far(i,j) = far(i,j) + nnz(neg_scores < th)/length(neg_scores);

        % Gold standard. Use GPD to adjust PFA to design PFA
        sorted_neg_scores = sort(neg_scores);
        % Take lowest 5% samples to estimate the tail of the PDF
        lower_th = sorted_neg_scores(ceil(length(sorted_neg_scores)*tail_size)+1);
        trunc_scores = lower_th - sorted_neg_scores(sorted_neg_scores<lower_th);
        % Fit GPD
        [parmhat,parmci] = gpfit(trunc_scores);
        % Evaluate the inverse CDF of the GPD at design_pfa to find
        % adapted threshold
        adapt_th = lower_th - gpinv(1-design_pfa/tail_size,parmhat(1),parmhat(2),0);
        % Compute false alarm rate using the new adapated threshold
        gold_far(i,j) = gold_far(i,j) + nnz(neg_scores < adapt_th)/length(neg_scores);
        % Compute adjusted scores
        gold_scores{i}(:,j) = s - adapt_th + th;
        %gold_scores{i}(:,j) = (s - th) * adapt_th;
    end
end
%r=1:length(data.scores);
%figure(2), plot(r,far(:,1),r,far(:,2),r,far(:,3),r,far(:,4));
r=1:numel(far);
figure, plot(r,far(:),r,gold_far(:));
fprintf('Design PFA = %.6f, Actual PFA =%.6f\n', design_pfa, mean(gold_far(:)));
figure, show2_roc(gold_scores, data.scores, data.gt)
legend('GPD normalized','unnormalized')

