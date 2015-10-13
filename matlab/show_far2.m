data = load('scores_cnn_all.mat');
%data = load('scores_crumbling.mat');

% Use exponential model with conjugate Gamma prior
% Use KS test to remove defects from the tail of the distribution

% Algorithm parameters
th = 0.1070;
design_pfa = 0.001;
tail_size = 0.05;
prior_size = 400;
max_num_outliers = 12;
max_correction = 0.5;

far = zeros(length(data.scores),4);
% The sufficient statistic is the sum and sample count of the truncated and shifted tail
suf_stat_n = zeros(length(data.scores),4);
suf_stat_sum = zeros(length(data.scores),4);
gold_far = zeros(length(data.scores),4);
gold_scores = {};
adapt_far = zeros(length(data.scores),4);
adapt_scores = {};

% Training (compute prior)
for i = 1:length(data.scores)
    for j = 1:4
        s = data.scores{i}(:,j);
        t = data.gt{i}(:,j);
        neg_scores = s(t==0);
        far(i,j) = far(i,j) + nnz(neg_scores < th)/length(neg_scores);

        % Gold standard. Use GPD to adjust PFA to design PFA
        sorted_neg_scores = sort(neg_scores);
        % Take lowest 5% (tail_size) samples to estimate the tail of the PDF
        lower_th = sorted_neg_scores(ceil(length(sorted_neg_scores)*tail_size)+1);
        trunc_scores = lower_th - sorted_neg_scores(sorted_neg_scores<lower_th);
        % Compute sufficient statistics
        suf_stat_n(i,j) = numel(trunc_scores);
        suf_stat_sum(i,j) = sum(trunc_scores);
    end
end
% Testing (fit regularized exponential and adjust score to desired PFA)
for i = 1:length(data.scores)
    % Compute prior from the training set (exclude current sequence)
    prior_n = 0;
    prior_sum = 0;
    for j = 1:length(data.scores)
        if j~=i
            prior_n = prior_n + sum(suf_stat_n);
            prior_sum = prior_sum + sum(suf_stat_sum);
        end
    end
    % Compute prior
    alpha0 = 1 + prior_size;
    beta0 = prior_size * prior_sum / prior_n;
    a_hat0 = beta0 / (alpha0-1);
    for j = 1:4
        s = data.scores{i}(:,j);
        t = data.gt{i}(:,j);   % Gold standard without defects
        neg_scores = s(t==0);
        far(i,j) = far(i,j) + nnz(neg_scores < th)/length(neg_scores);
        
        % Gold standard. Remove true positives
        sorted_neg_scores = sort(neg_scores);
        % Take lowest 5% (tail_size) samples to estimate the tail of the PDF
        lower_th = sorted_neg_scores(ceil(length(sorted_neg_scores)*tail_size)+1);
        trunc_scores = lower_th - sorted_neg_scores(sorted_neg_scores<lower_th);
        % Compute posterior
        alpha1 = alpha0 + numel(trunc_scores);
        beta1 = beta0 + sum(trunc_scores);
        % Compute MAP estimate
        a_hat = beta1 / (alpha1-1);
        % Evaluate the inverse CDF of the GPD at design_pfa to find
        % adapted threshold
        adapt_th = lower_th + a_hat*log(design_pfa/tail_size);
        % Compute adjusted scores
        gold_far(i,j) = gold_far(i,j) + nnz(neg_scores < adapt_th)/length(neg_scores);
        gold_scores{i}(:,j) = s - adapt_th + th;
        
        % Actual performance with defects
        t = data.scores{i}(:,j) < th;
        sorted_neg_scores = sort(s);
        % Truncate scores to remove defects using a KS test
        tail_count = ceil(length(sorted_neg_scores)*tail_size)+1;
        ks_stat = zeros(1,max_num_outliers);
        for start_idx = 1:max_num_outliers
            % Check wether the samples start_idx:start_idx+tail_count-1
            % fit the prior exponential CDF
            lower_th = sorted_neg_scores(start_idx+tail_count-1);
            trunc_scores = lower_th - sorted_neg_scores(start_idx:start_idx+tail_count-1);
            ks_stat(start_idx) = ks_stat_exp(flipud(trunc_scores), a_hat0);
        end
        [min_D,start_idx] = min(ks_stat);
        lower_th = sorted_neg_scores(start_idx+tail_count-1);
        trunc_scores = lower_th - sorted_neg_scores(start_idx:start_idx+tail_count-1);
        % Compute posterior
        alpha1 = alpha0 + numel(trunc_scores);
        beta1 = beta0 + sum(trunc_scores);
        % Compute MAP estimate
        a_hat = beta1 / (alpha1-1);
        % Evaluate the inverse CDF of the GPD at design_pfa to find
        % adapted threshold
        adapt_th = lower_th + a_hat*log(design_pfa/tail_size);
        % Clip adjustment, so adapt_th_w-th < max_correction
        adapt_th = min(adapt_th, max_correction - th);
        % Compute adjusted scores
        adapt_far(i,j) = adapt_far(i,j) + nnz(neg_scores < adapt_th)/length(neg_scores);
        adapt_scores{i}(:,j) = s - adapt_th + th;
    end
end

%r=1:length(data.scores);
%figure(2), plot(r,far(:,1),r,far(:,2),r,far(:,3),r,far(:,4));
r=1:numel(far);
figure, plot(r,far(:),r,gold_far(:));
fprintf('Design PFA = %.6f, Actual PFA =%.6f\n', design_pfa, mean(adapt_far(:)));
figure, show2_roc(adapt_scores, data.scores, data.gt)
legend('Exp/Gamma normalized','unnormalized')
