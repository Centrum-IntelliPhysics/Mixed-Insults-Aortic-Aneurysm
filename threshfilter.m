
function output = threshfilter(true_ce_re,pred_ce_re,true_ms_re,pred_ms_re,thres,resam)

% output = struct([]);

true_ce = squeeze(true_ce_re);		pred_ce = squeeze(pred_ce_re);
true_ms = squeeze(true_ms_re);		pred_ms = squeeze(pred_ms_re);

ins_mask = true_ce./max(true_ce(:)) >= thres & true_ms./max(true_ms(:)) >= thres;
true_ce(~ins_mask) = NaN;    pred_ce(~ins_mask) = NaN;
true_ms(~ins_mask) = NaN;    pred_ms(~ins_mask) = NaN;

output.ins_mask = ins_mask;
output.true_ce  = true_ce;
output.pred_ce  = pred_ce;
output.true_ms  = true_ms;
output.pred_ms  = pred_ms;

% % Resample all distributions to give an equal number of points
% Nb = 200;
% 
% % ce truth
% [counts,edges] = histcounts(true_ce(ins_mask),linspace(0,.48,Nb));
% true_ce_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% % ce predicted
% [counts,edges] = histcounts(pred_ce(ins_mask),linspace(0,.48,Nb));
% pred_ce_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% % ms truth
% [counts,edges] = histcounts(true_ms(ins_mask),linspace(0,.28,Nb));
% true_ms_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% % ms predicted
% [counts,edges] = histcounts(pred_ms(ins_mask),linspace(0,.28,Nb));
% pred_ms_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% % ce absolute error
% [counts,edges] = histcounts(true_ce(ins_mask)-pred_ce(ins_mask),linspace(-.2,.2,Nb));
% aerr_ce_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% % ms absolute error
% [counts,edges] = histcounts(true_ms(ins_mask)-pred_ms(ins_mask),linspace(-.2,.2,Nb));
% aerr_ms_rs = randsample((edges(1:end-1) + edges(2:end))/2,resam,true,counts/sum(counts));
% 
% output.true_ce_rs = true_ce_rs';
% output.pred_ce_rs = pred_ce_rs';
% output.true_ms_rs = true_ms_rs';
% output.pred_ms_rs = pred_ms_rs';
% output.aerr_ce_rs = aerr_ce_rs';
% output.aerr_ms_rs = aerr_ms_rs';

return
