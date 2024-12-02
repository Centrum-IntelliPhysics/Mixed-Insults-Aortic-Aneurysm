
% David Li    Yale University    2024

% Requires results .mats (e.g., case1_results.mat) generated from data_preproc.m.

clear; clc; close all;
set(0, 'DefaultAxesTickDir', 'out'); set(0, 'DefaultAxesTickDirMode', 'manual');

%% Set options
paddata    = 1;				% 0 or 1	Use padded data?
fliptheta  = 0;				% 0 or 1	Load reordered theta results?
err_allsam = 1;				% 0 or 1	Plot errors for all realizations?
err_idvsam = 0;				% 0 or 1	Plot errors for individual realizations?
err_save   = 0;				% 0 or 1	Save error file?

% 1: Gray dil only, 2: Heat dil only, 3: Gray dil & dis, 4: Heat dil & dis
cases = {'case1', 'case2', 'case3', 'case4'};

% A: CNN-DeepONet, B: FNN-DeepONet, C: UNet, D: LNO
% nets  = {'networkA', 'networkB', 'networkC', 'networkD'};

% if paddata; suffix = '_pad'; else; suffix = []; end
if paddata; suffix = '_pad_penalty'; else; suffix = []; end

N    = 50;		% Number of testing realizations
nrow = 41;		% Number of rows
ncol = 41;		% Number of columns

%% Extract prediction errors
% Errors for each sample
% 1: insult (ce, ms)	2: case (1:4)	3: realization (1:50)	4: metric (rL2, MSE)
netA_err_allcases = zeros(2,4,N,2);		netB_err_allcases = zeros(2,4,N,2);
netC_err_allcases = zeros(2,4,N,2);		netD_err_allcases = zeros(2,4,N,2);

% Errors over all samples
% 1: case (1:4)		2: metric (rL2, MSE, L1, Linf)
netA_err_ce = zeros(4);	netA_err_ms = zeros(4);
netB_err_ce = zeros(4);	netB_err_ms = zeros(4);
netC_err_ce = zeros(4);	netC_err_ms = zeros(4);
netD_err_ce = zeros(4);	netD_err_ms = zeros(4);
for cc = cases
	if fliptheta; load(['allResults', suffix, '/', char(cc), '_results.mat']);			% With theta reordering
	else; load(['allResults', suffix, '/', char(cc), '_results_noflip.mat']); end		% Without theta reordering
	
	cn = str2double(cc{end}(end));				% Case number
	
	% Reshape to a 2D grids and vectors for error calculation
	% Network A
	netA_err_ce(cn,1) = norm(reshape(A_true_ce_re-A_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(A_true_ce_re, N, nrow*ncol)', 'fro');
	netA_err_ce(cn,2) = immse(A_true_ce_re, A_pred_ce_re);
	netA_err_ce(cn,3) = norm(reshape(A_true_ce_re-A_pred_ce_re, N*nrow*ncol, 1)', 1);
	netA_err_ce(cn,4) = norm(reshape(A_true_ce_re-A_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netA_err_ms(cn,1) = norm(reshape(A_true_ms_re-A_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(A_true_ms_re, N, nrow*ncol)', 'fro');
	netA_err_ms(cn,2) = immse(A_true_ms_re, A_pred_ms_re);
	netA_err_ms(cn,3) = norm(reshape(A_true_ms_re-A_pred_ms_re, N*nrow*ncol, 1)', 1);
	netA_err_ms(cn,4) = norm(reshape(A_true_ms_re-A_pred_ms_re, N*nrow*ncol, 1)', Inf);
% 	netA_err_allcases(1,cn,:,:) = reshape(A_true_ce_re-A_pred_ce_re, N, nrow*ncol);
% 	netA_err_allcases(2,cn,:,:) = reshape(A_true_ms_re-A_pred_ms_re, N, nrow*ncol);
	
	% Network B
	netB_err_ce(cn,1) = norm(reshape(B_true_ce_re-B_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(B_true_ce_re, N, nrow*ncol)', 'fro');
	netB_err_ce(cn,2) = immse(B_true_ce_re, B_pred_ce_re);
	netB_err_ce(cn,3) = norm(reshape(B_true_ce_re-B_pred_ce_re, N*nrow*ncol, 1)', 1);
	netB_err_ce(cn,4) = norm(reshape(B_true_ce_re-B_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netB_err_ms(cn,1) = norm(reshape(B_true_ms_re-B_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(B_true_ms_re, N, nrow*ncol)', 'fro');
	netB_err_ms(cn,2) = immse(B_true_ms_re, B_pred_ms_re);
	netB_err_ms(cn,3) = norm(reshape(B_true_ms_re-B_pred_ms_re, N*nrow*ncol, 1)', 1);
	netB_err_ms(cn,4) = norm(reshape(B_true_ms_re-B_pred_ms_re, N*nrow*ncol, 1)', Inf);
% 	netB_err_allcases(1,cn,:,:) = reshape(B_true_ce_re-B_pred_ce_re, N, nrow*ncol);
% 	netB_err_allcases(2,cn,:,:) = reshape(B_true_ms_re-B_pred_ms_re, N, nrow*ncol);
	
	% Network C
	netC_err_ce(cn,1) = norm(reshape(C_true_ce_re-C_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(C_true_ce_re, N, nrow*ncol)', 'fro');
	netC_err_ce(cn,2) = immse(C_true_ce_re, C_pred_ce_re);
	netC_err_ce(cn,3) = norm(reshape(C_true_ce_re-C_pred_ce_re, N*nrow*ncol, 1)', 1);
	netC_err_ce(cn,4) = norm(reshape(C_true_ce_re-C_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netC_err_ms(cn,1) = norm(reshape(C_true_ms_re-C_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(C_true_ms_re, N, nrow*ncol)', 'fro');
	netC_err_ms(cn,2) = immse(C_true_ms_re, C_pred_ms_re);
	netC_err_ms(cn,3) = norm(reshape(C_true_ms_re-C_pred_ms_re, N*nrow*ncol, 1)', 1);
	netC_err_ms(cn,4) = norm(reshape(C_true_ms_re-C_pred_ms_re, N*nrow*ncol, 1)', Inf);
% 	netC_err_allcases(1,cn,:,:) = reshape(C_true_ce_re-C_pred_ce_re, N, nrow*ncol);
% 	netC_err_allcases(2,cn,:,:) = reshape(C_true_ms_re-C_pred_ms_re, N, nrow*ncol);
	
	% Network D
	netD_err_ce(cn,1) = norm(reshape(D_true_ce_re-D_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(D_true_ce_re, N, nrow*ncol)', 'fro');
	netD_err_ce(cn,2) = immse(D_true_ce_re, D_pred_ce_re);
	netD_err_ce(cn,3) = norm(reshape(D_true_ce_re-D_pred_ce_re, N*nrow*ncol, 1)', 1);
	netD_err_ce(cn,4) = norm(reshape(D_true_ce_re-D_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netD_err_ms(cn,1) = norm(reshape(D_true_ms_re-D_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(D_true_ms_re, N, nrow*ncol)', 'fro');
	netD_err_ms(cn,2) = immse(D_true_ms_re, D_pred_ms_re);
	netD_err_ms(cn,3) = norm(reshape(D_true_ms_re-D_pred_ms_re, N*nrow*ncol, 1)', 1);
	netD_err_ms(cn,4) = norm(reshape(D_true_ms_re-D_pred_ms_re, N*nrow*ncol, 1)', Inf);
% 	netD_err_allcases(1,cn,:,:) = reshape(D_true_ce_re-D_pred_ce_re, N, nrow*ncol);
% 	netD_err_allcases(2,cn,:,:) = reshape(D_true_ms_re-D_pred_ms_re, N, nrow*ncol);
	
	for ee = 1:N
		netA_err_allcases(1,cn,ee,1) = norm(squeeze(A_true_ce_re(ee,:,:)-A_pred_ce_re(ee,:,:)), 'fro')/norm(squeeze(A_true_ce_re(ee,:,:)), 'fro');
		netA_err_allcases(1,cn,ee,2) = immse(A_true_ce_re(ee,:,:), A_pred_ce_re(ee,:,:));
		netB_err_allcases(1,cn,ee,1) = norm(squeeze(B_true_ce_re(ee,:,:)-B_pred_ce_re(ee,:,:)), 'fro')/norm(squeeze(B_true_ce_re(ee,:,:)), 'fro');
		netB_err_allcases(1,cn,ee,2) = immse(B_true_ce_re(ee,:,:), B_pred_ce_re(ee,:,:));
		netC_err_allcases(1,cn,ee,1) = norm(squeeze(C_true_ce_re(ee,:,:)-C_pred_ce_re(ee,:,:)), 'fro')/norm(squeeze(C_true_ce_re(ee,:,:)), 'fro');
		netC_err_allcases(1,cn,ee,2) = immse(C_true_ce_re(ee,:,:), C_pred_ce_re(ee,:,:));
		netD_err_allcases(1,cn,ee,1) = norm(squeeze(D_true_ce_re(ee,:,:)-D_pred_ce_re(ee,:,:)), 'fro')/norm(squeeze(D_true_ce_re(ee,:,:)), 'fro');
		netD_err_allcases(1,cn,ee,2) = immse(D_true_ce_re(ee,:,:), D_pred_ce_re(ee,:,:));
		
		netA_err_allcases(2,cn,ee,1) = norm(squeeze(A_true_ms_re(ee,:,:)-A_pred_ms_re(ee,:,:)), 'fro')/norm(squeeze(A_true_ms_re(ee,:,:)), 'fro');
		netA_err_allcases(2,cn,ee,2) = immse(A_true_ms_re(ee,:,:), A_pred_ms_re(ee,:,:));
		netB_err_allcases(2,cn,ee,1) = norm(squeeze(B_true_ms_re(ee,:,:)-B_pred_ms_re(ee,:,:)), 'fro')/norm(squeeze(B_true_ms_re(ee,:,:)), 'fro');
		netB_err_allcases(2,cn,ee,2) = immse(B_true_ms_re(ee,:,:), B_pred_ms_re(ee,:,:));
		netC_err_allcases(2,cn,ee,1) = norm(squeeze(C_true_ms_re(ee,:,:)-C_pred_ms_re(ee,:,:)), 'fro')/norm(squeeze(C_true_ms_re(ee,:,:)), 'fro');
		netC_err_allcases(2,cn,ee,2) = immse(C_true_ms_re(ee,:,:), C_pred_ms_re(ee,:,:));
		netD_err_allcases(2,cn,ee,1) = norm(squeeze(D_true_ms_re(ee,:,:)-D_pred_ms_re(ee,:,:)), 'fro')/norm(squeeze(D_true_ms_re(ee,:,:)), 'fro');
		netD_err_allcases(2,cn,ee,2) = immse(D_true_ms_re(ee,:,:), D_pred_ms_re(ee,:,:));
	end
end

%% Plot overall errors
if err_allsam
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.30 .50 .40 .45]);
	
	% Category labels
	row1 = {'Dil only', 'Dil only', 'Dil & dis', 'Dil & dis'};
	row2 = {'Gray', 'Heat', 'Gray', 'Heat'};
	labelArray = [row1; row2];
	labelArray = strjust(pad(labelArray), 'center');
	barcases = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
	
	% Eln fiber rL2 & MSE
	subplot(221);
	b = bar(1:4,...
		[netA_err_ce(:,1) netB_err_ce(:,1) netC_err_ce(:,1) netD_err_ce(:,1)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	ylabel({'Relative L2',''}, 'fontweight', 'bold'); ylim([0 0.3]);
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0);
	title({'Elastic fiber integrity',''});
	subplot(223);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ce(:,2) netB_err_ce(:,2) netC_err_ce(:,2) netD_err_ce(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	ylabel({'MSE',''}, 'fontweight', 'bold');
	set(gca, 'yscale', 'log');
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0);
	% 	title('EF: MSE');
	
	% subplot(223);
	% 	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
	% 		[netA_err_ce(:,3) netB_err_ce(:,3) netD_err_ce(:,3) netD_err_ce(:,3)], 1, 'grouped',...
	% 		'edgecolor', 'none'); box off;
	% 	title('EF: L1');
	% subplot(224);
	% 	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
	% 		[netA_err_ce(:,4) netB_err_ce(:,4) netD_err_ce(:,4) netD_err_ce(:,4)], 1, 'grouped',...
	% 		'edgecolor', 'none'); box off;
	% 	title('EF: L\infty');
	
	% figure; set(gcf, 'units', 'normalized', 'outerposition', [.30 .10 .40 .40]);
	% Mechanosensing rL2 & MSE
	subplot(222);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,1) netB_err_ms(:,1) netC_err_ms(:,1) netD_err_ms(:,1)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	ylim([0 0.3]);
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0);
	title({'Mechanosensing',''});
	l = legend('A: CNN-DeepONet', 'B: FNN-DeepONet', 'C: UNet', 'D: LNO'); l.Position = l.Position + [1e-1 2e-2 0 0]; l.EdgeColor = 'w';
	subplot(224);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,2) netB_err_ms(:,2) netC_err_ms(:,2) netD_err_ms(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(gca, 'yscale', 'log');
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0);
	% 	title('MS: MSE');
	% 	l = legend('A', 'B', 'C', 'D'); l.Position = l.Position + [5e-2 3e-2 0 0]; l.EdgeColor = 'w';
	% subplot(223);
	% 	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
	% 		[netA_err_ms(:,3) netB_err_ms(:,3) netC_err_ms(:,3) netD_err_ms(:,3)], 1, 'grouped',...
	% 		'edgecolor', 'none'); box off;
	% 	title('MS: L1');
	% subplot(224);
	% 	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
	% 		[netA_err_ms(:,4) netB_err_ms(:,4) netC_err_ms(:,4) netD_err_ms(:,4)], 1, 'grouped',...
	% 		'edgecolor', 'none'); box off;
	% 	title('MS: L\infty');
end

%% Plot individual sample errors
if err_idvsam
	etype = 1;		% 1 or 2	1=rL2, 2=MSE
	if etype == 1;		ename = 'Relative L2 error';
	elseif etype == 2;	ename = 'MSE';
	end
	
	% Compare all realizations across cases 1-4, one network at a time
	nettype = 'A';
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .50 .98 .45]);
	subplot(211);
		if strcmp(nettype, 'A');		bar(squeeze(netA_err_allcases(1,:,:,etype))', 1);	netname = 'CNN-DeepONet';
		elseif strcmp(nettype, 'B');	bar(squeeze(netB_err_allcases(1,:,:,etype))', 1);	netname = 'FNN-DeepONet';
		elseif strcmp(nettype, 'C');	bar(squeeze(netC_err_allcases(1,:,:,etype))', 1);	netname = 'UNet';
		elseif strcmp(nettype, 'D');	bar(squeeze(netD_err_allcases(1,:,:,etype))', 1);	netname = 'LNO';
		end
		title(['Elastic fiber integrity contribution: ',ename, ' (',nettype,': ',netname, ')']); box off;
		ylabel(ename); ylim([1e-3 1e1]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
		l = legend('1: Dil only, gray', '2: Dil only, heat', '3: Dil & dis, gray', '4: Dil & dis, heat');
		l.Position = l.Position + [8e-2 1e-2 0 0]; l.EdgeColor = 'w';
	subplot(212);
		if strcmp(nettype, 'A');		bar(squeeze(netA_err_allcases(2,:,:,etype))', 1);	netname = 'CNN-DeepONet';
		elseif strcmp(nettype, 'B');	bar(squeeze(netB_err_allcases(2,:,:,etype))', 1);	netname = 'FNN-DeepONet';
		elseif strcmp(nettype, 'C');	bar(squeeze(netC_err_allcases(2,:,:,etype))', 1);	netname = 'UNet';
		elseif strcmp(nettype, 'D');	bar(squeeze(netD_err_allcases(2,:,:,etype))', 1);	netname = 'LNO';
		end
		title(['Mechanosensing contribution: ',ename, ' (',nettype,': ',netname, ')']); box off;
		ylabel(ename); ylim([1e-3 1e1]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
	
	% Compare all realizations across networks A-D
	casenum = 2;
	if casenum == 1;		cname = 'Dil only, gray';
	elseif casenum == 2;	cname = 'Dil only, heat';
	elseif casenum == 3;	cname = 'Dil & dis, gray';
	elseif casenum == 4;	cname = 'Dil & dis, heat';
	end
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .05 .98 .45]);
	subplot(211);
		ABCD_ce = cat(2,squeeze(netA_err_allcases(1,casenum,:,etype)),...
						squeeze(netB_err_allcases(1,casenum,:,etype)),...
						squeeze(netC_err_allcases(1,casenum,:,etype)),...
						squeeze(netD_err_allcases(1,casenum,:,etype)));
		bar(ABCD_ce, 1);
		title(['Elastic fiber integrity contribution: relative L2 error (',num2str(casenum),': ',cname, ')']); box off;
		ylabel('Relative L2 error'); % ylim([1e-3 1e1]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
		l = legend('A: CNN-DeepONet', 'B: FNN-DeepONet', 'C: UNet', 'D: LNO');
		l.Position = l.Position + [8.7e-2 1e-2 0 0]; l.EdgeColor = 'w';
	subplot(212);
		ABCD_ms = cat(2,squeeze(netA_err_allcases(2,casenum,:,etype)),...
						squeeze(netB_err_allcases(2,casenum,:,etype)),...
						squeeze(netC_err_allcases(2,casenum,:,etype)),...
						squeeze(netD_err_allcases(2,casenum,:,etype)));
		bar(ABCD_ms, 1);
		title(['Mechanosensing contribution: relative L2 error (',num2str(casenum),': ',cname, ')']); box off;
		ylabel('Relative L2 error'); % ylim([1e-3 1e1]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
end

% % Save tables (rows: cases, columns: networks)
% varnames = {'Insult', 'Cases',...
% 	'NetA_rL2', 'NetB_rL2', 'NetC_rL2', 'NetD_rL2',...
% 	'NetA_MSE', 'NetB_MSE', 'NetC_MSE', 'NetD_MSE',...
% 	'NetA_L1', 'NetB_L1', 'NetC_L1', 'NetD_L1',...
% 	'NetA_Linf', 'NetB_Linf', 'NetC_Linf', 'NetD_Linf'};
% 
% ins    = cellstr([repmat('elastic fibers',4,1); repmat('mechanosensing',4,1)]);
% cs     = repmat({'Case1';'Case2';'Case3';'Case4'},2,1);
% all_ce = [avg_netA_rL2_ce', avg_netB_rL2_ce', avg_netC_rL2_ce', avg_netD_rL2_ce',...
% 		  avg_netA_rL2_ce', avg_netB_rL2_ce', avg_netC_rL2_ce', avg_netD_rL2_ce',...
% 		  avg_netA_L1_ce', avg_netB_L1_ce', avg_netC_L1_ce', avg_netD_L1_ce',...
% 		  avg_netA_Linf_ce', avg_netB_Linf_ce', avg_netC_Linf_ce', avg_netD_Linf_ce'];
% all_ms = [avg_netA_rL2_ms', avg_netB_rL2_ms', avg_netC_rL2_ms', avg_netD_rL2_ms',...
% 		  avg_netA_MSE_ms', avg_netB_MSE_ms', avg_netC_MSE_ms', avg_netD_MSE_ms',...
% 		  avg_netA_L1_ms', avg_netB_L1_ms', avg_netC_L1_ms', avg_netD_L1_ms',...
% 		  avg_netA_Linf_ms', avg_netB_Linf_ms', avg_netC_Linf_ms', avg_netD_Linf_ms'];
% all_errors = vertcat(all_ce, all_ms);
% allnets_allerrs = horzcat(table(ins, cs), array2table(all_errors));
% allnets_allerrs.Properties.VariableNames = varnames;

%% Save all errors
if err_save
	save('error_allcases.mat',...
	'netA_rL2', 'netA_MSE', 'netA_L1', 'netA_Linf',...
	'netB_rL2', 'netB_MSE', 'netB_L1', 'netB_Linf',...
	'netC_rL2', 'netC_MSE', 'netC_L1', 'netC_Linf',...
	'netD_rL2', 'netD_MSE', 'netD_L1', 'netD_Linf',...
	'allnets_allerrs');
end
