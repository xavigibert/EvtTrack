function [] = show2_roc(scores, scores2, gt, wacv_pfa, wacv_pd)

[pfa,pd,s1] = compute_roc(scores, gt);
[pfa2,pd2,s2] = compute_roc(scores2, gt);
cfar_pd10 = compute_pd(pfa, pd, 0.001);
cfar_pd2 = compute_pd(pfa, pd, 0.0002);
cfar_pd10_2 = compute_pd(pfa2, pd2, 0.001);
cfar_pd2_2 = compute_pd(pfa2, pd2, 0.0002);
cfar_th10 = compute_th(pfa, s1, 0.001);
cfar_th2 = compute_th(pfa, s1, 0.0002);
cfar_th10_2 = compute_th(pfa2, s2, 0.001);
cfar_th2_2 = compute_th(pfa2, s2, 0.0002);

plot(pfa,pd,pfa2,pd2,wacv_pfa,wacv_pd,'Linewidth', 2);
axis([0 0.01 0.9 1]);
grid minor
grid on
set(gcf, 'Position',[100 200 560 420/1.4])
auc = sum(([pfa; 1]-[0; pfa]).*([pd; 1]+[0; pd]))/2;
auc2 = sum(([pfa2; 1]-[0; pfa2]).*([pd2; 1]+[0; pd2]))/2;
%title(sprintf('AUC = %.6f vs %.6f', auc, auc2));
fprintf('AUC = %.6f vs %.6f\n', auc, auc2);
fprintf('PD(0.10%%) = %.4f (%.4f) vs %.4f (%.4f)\n', cfar_pd10, cfar_th10, cfar_pd10_2, cfar_th10_2);
fprintf('PD(0.02%%) = %.4f (%.4f) vs %.4f (%.4f)\n', cfar_pd2, cfar_th2, cfar_pd2_2, cfar_th2_2);

end

function [pfa,pd,th] = compute_roc(scores, gt)
    n = 0;
    for i = 1:length(scores)
        % Remove outliers
        %if i==71, continue, end
        
        n = n + nnz(gt{i}(:)>=0);
    end
    s = zeros(n,1);     % Sequential scores
    t = zeros(n,1);     % Sequential true values
    n = 0;
    for i = 1:length(scores)
        % Remove outliers
        %if i==71, continue, end
        % Remove ambiguous samples
        filt_scores = scores{i}(gt{i}(:)>=0);
        filt_gt = gt{i}(gt{i}(:)>=0);
        
        l = numel(filt_scores);
        s(n+1:n+l) = filt_scores;
        t(n+1:n+l) = filt_gt~=0;
        n = n + l;
    end
    [th,idx] = sort(s(:,1));
    num_pos = nnz(t);
    num_neg = n-num_pos;
    pd=cumsum(t(idx))/num_pos;
    pfa=cumsum(~t(idx))/num_neg;
end

function [pd] = compute_pd(vpfa, vpd, pfa)
    idx = find(vpfa>pfa,1);
    alpha = (vpfa(idx) - pfa)/(vpfa(idx) - vpfa(idx-1));
    pd = vpd(idx)*alpha + vpd(idx-1)*(1-alpha);
end

function [th] = compute_th(vpfa, vth, pfa)
    idx = find(vpfa>pfa,1);
    alpha = (vpfa(idx) - pfa)/(vpfa(idx) - vpfa(idx-1));
    th = vth(idx)*alpha + vth(idx-1)*(1-alpha);    
end