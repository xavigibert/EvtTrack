function [] = test_filter(fnc,params)

suffix = {'clear.mat', 'switch.mat', 'all.mat'};

% Apply filter to all sets and compute ROC
for which = 1:3
    data = load(['scores_cnn_' suffix{which}]);
    for i = 1:length(data.scores)
        split = mod(data.tieIndex{i},5);
        for j = 1:4
            for k = 0:4
                s = data.scores{i}(split==k,j);
                if exist('params','var')
                    sf = fnc(s,params);
                else
                    sf = fnc(s);
                end
                data.scores{i}(split==k,j) = sf;
            end
        end
    end
    switch which
        case 1
            result_clear = generate_roc(data.scores, data.gt);
        case 2
            result_switch = generate_roc(data.scores, data.gt);
        case 3
            result_all = generate_roc(data.scores, data.gt);
    end
end

% Show comparative ROCs
load baseline_cnn

h = plot(result_clear.pfa, result_clear.pd, ...
    result_switch.pfa, result_switch.pd, ...
    result_all.pfa, result_all.pd, ...
    roc_clear.pfa, roc_clear.pd, ...
    roc_switch.pfa, roc_switch.pd, ...
    roc_all.pfa, roc_all.pd);
legend('normalized (clear ties)', 'normalized (clear ties + sw)', 'normalized (all ties)', ...
    'unnormalized (clear ties)', 'unnormalized (clear ties + sw)', 'unnormalized (all ties)');
for j=1:3
    set(h(j+3),'Color',get(h(j),'Color'));
    set(h(j+3),'Linestyle','--');
end
axis([0 0.02 0.9 1]);
grid on

auc1 = eval_auc(result_clear);
auc2 = eval_auc(result_switch);
auc3 = eval_auc(result_all);
auc1b = eval_auc(roc_clear);
auc2b = eval_auc(roc_switch);
auc3b = eval_auc(roc_all);
fprintf('AUC = %.6f (%.6f) (clear ties)\n', auc1, auc1b);
fprintf('AUC = %.6f (%.6f) (clear + sw)\n', auc2, auc2b);
fprintf('AUC = %.6f (%.6f) (all ties)\n', auc3, auc3b);
title(sprintf('AUC = %.6f, %.6f, %.6f', auc1, auc2, auc3));

end

function [auc] = eval_auc(roc)

auc = sum(([roc.pfa; 1]-[0; roc.pfa]).*([roc.pd; 1]+[0; roc.pd]))/2;

end
