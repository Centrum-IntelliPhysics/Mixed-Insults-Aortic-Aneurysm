
clear; clc; close all;
set(0, 'DefaultAxesTickDir', 'out'); set(0, 'DefaultAxesTickDirMode', 'manual');

err_allsam = 0;				% 0 or 1	Plot errors for all realizations?
err_avg    = 0;				% 0 or 1	Plot average errors?
err_save   = 0;				% 0 or 1	Save error file?

% 1: Gray dil only, 2: Heat dil only, 3: Gray dil & dis, 4: Heat dil & dis
cases = {'case1', 'case2', 'case3', 'case4'};

% A: CNN-DeepONet, B: FNN-DeepONet, C: UNet, D: LNO
% nets  = {'networkA', 'networkB', 'networkC', 'networkD'};

N    = 50;		% Number of testing realizations
nrow = 41;		% Number of rows
ncol = 41;		% Number of columns

% 1: insult (ce, ms)	2: case (1:4)	3: realization (1:50)	4: 41x41 grid
netA_err_allcases = zeros(2,4,N,nrow,ncol);		netB_err_allcases = zeros(2,4,N,nrow,ncol);
netC_err_allcases = zeros(2,4,N,nrow,ncol);		netD_err_allcases = zeros(2,4,N,nrow,ncol);

netA_err_ce = zeros(4);	netA_err_ms = zeros(4);
netB_err_ce = zeros(4);	netB_err_ms = zeros(4);
netC_err_ce = zeros(4);	netC_err_ms = zeros(4);
netD_err_ce = zeros(4);	netD_err_ms = zeros(4);
for cc = cases
% 	load([char(cc), '_results.mat']);			% For non-padded data, with theta reordering
% 	load([char(cc), '_results_noflip.mat']);	% For non-padded data, without theta reordering
	load([char(cc), '_resultsABD.mat']);	% For non-padded data, without theta reordering
	
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
	
	% Network B
	netB_err_ce(cn,1) = norm(reshape(B_true_ce_re-B_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(B_true_ce_re, N, nrow*ncol)', 'fro');
	netB_err_ce(cn,2) = immse(B_true_ce_re, B_pred_ce_re);
	netB_err_ce(cn,3) = norm(reshape(B_true_ce_re-B_pred_ce_re, N*nrow*ncol, 1)', 1);
	netB_err_ce(cn,4) = norm(reshape(B_true_ce_re-B_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netB_err_ms(cn,1) = norm(reshape(B_true_ms_re-B_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(B_true_ms_re, N, nrow*ncol)', 'fro');
	netB_err_ms(cn,2) = immse(B_true_ms_re, B_pred_ms_re);
	netB_err_ms(cn,3) = norm(reshape(B_true_ms_re-B_pred_ms_re, N*nrow*ncol, 1)', 1);
	netB_err_ms(cn,4) = norm(reshape(B_true_ms_re-B_pred_ms_re, N*nrow*ncol, 1)', Inf);
	
	% Network C
	netC_err_ce(cn,1) = norm(reshape(C_true_ce_re-C_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(C_true_ce_re, N, nrow*ncol)', 'fro');
	netC_err_ce(cn,2) = immse(C_true_ce_re, C_pred_ce_re);
	netC_err_ce(cn,3) = norm(reshape(C_true_ce_re-C_pred_ce_re, N*nrow*ncol, 1)', 1);
	netC_err_ce(cn,4) = norm(reshape(C_true_ce_re-C_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netC_err_ms(cn,1) = norm(reshape(C_true_ms_re-C_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(C_true_ms_re, N, nrow*ncol)', 'fro');
	netC_err_ms(cn,2) = immse(C_true_ms_re, C_pred_ms_re);
	netC_err_ms(cn,3) = norm(reshape(C_true_ms_re-C_pred_ms_re, N*nrow*ncol, 1)', 1);
	netC_err_ms(cn,4) = norm(reshape(C_true_ms_re-C_pred_ms_re, N*nrow*ncol, 1)', Inf);
	
	% Network D
	netD_err_ce(cn,1) = norm(reshape(D_true_ce_re-D_pred_ce_re, N, nrow*ncol)', 'fro')/norm(reshape(D_true_ce_re, N, nrow*ncol)', 'fro');
	netD_err_ce(cn,2) = immse(D_true_ce_re, D_pred_ce_re);
	netD_err_ce(cn,3) = norm(reshape(D_true_ce_re-D_pred_ce_re, N*nrow*ncol, 1)', 1);
	netD_err_ce(cn,4) = norm(reshape(D_true_ce_re-D_pred_ce_re, N*nrow*ncol, 1)', Inf);
	netD_err_ms(cn,1) = norm(reshape(D_true_ms_re-D_pred_ms_re, N, nrow*ncol)', 'fro')/norm(reshape(D_true_ms_re, N, nrow*ncol)', 'fro');
	netD_err_ms(cn,2) = immse(D_true_ms_re, D_pred_ms_re);
	netD_err_ms(cn,3) = norm(reshape(D_true_ms_re-D_pred_ms_re, N*nrow*ncol, 1)', 1);
	netD_err_ms(cn,4) = norm(reshape(D_true_ms_re-D_pred_ms_re, N*nrow*ncol, 1)', Inf);
end

figure; set(gcf, 'units', 'normalized', 'outerposition', [.30 .50 .40 .40]);
subplot(221);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ce(:,1) netB_err_ce(:,1) netC_err_ce(:,1) netD_err_ce(:,1)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	title('EF: Relative L2');
subplot(222);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ce(:,2) netB_err_ce(:,2) netC_err_ce(:,2) netD_err_ce(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(gca, 'yscale', 'log');
	title('EF: MSE');
	l = legend('A', 'B', 'C', 'D'); l.Position = l.Position + [5e-2 3e-2 0 0]; l.EdgeColor = 'w';
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
subplot(223);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,1) netB_err_ms(:,1) netC_err_ms(:,1) netD_err_ms(:,1)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	title('MS: Relative L2');
subplot(224);
	bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,2) netB_err_ms(:,2) netC_err_ms(:,2) netD_err_ms(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(gca, 'yscale', 'log');
	title('MS: MSE');
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

% % 1: insult (ce, ms)	2: realization (1:50)	3: cases (1:4)
% % Relative L2 norm (Frobenius norm used), MSE, L1 norm, Linfinity norm
% netA_rL2 = zeros(2,N,4); netA_MSE = zeros(2,N,4); netA_L1 = zeros(2,N,4); netA_Linf = zeros(2,N,4);
% netB_rL2 = zeros(2,N,4); netB_MSE = zeros(2,N,4); netB_L1 = zeros(2,N,4); netB_Linf = zeros(2,N,4);
% netC_rL2 = zeros(2,N,4); netC_MSE = zeros(2,N,4); netC_L1 = zeros(2,N,4); netC_Linf = zeros(2,N,4);
% netD_rL2 = zeros(2,N,4); netD_MSE = zeros(2,N,4); netD_L1 = zeros(2,N,4); netD_Linf = zeros(2,N,4);
% 
% for cc = cases
% 	load([char(cc), '_results.mat']);				% For non-padded data, with theta reordering
% % 	load([char(cc), '_results_noflip.mat']);		% For non-padded data, without theta reordering
% 	
% 	cn = str2double(cc{end}(end));
% 	for rr = 1:N
% 		netA_rL2(1,rr,cn)  = norm(squeeze(A_true_ce_re(rr,:,:)-A_pred_ce_re(rr,:,:)), 'fro') / norm(squeeze(A_true_ce_re(rr,:,:)), 'fro');		% Frobenius
% 		netA_rL2(2,rr,cn)  = norm(squeeze(A_true_ms_re(rr,:,:)-A_pred_ms_re(rr,:,:)), 'fro') / norm(squeeze(A_true_ms_re(rr,:,:)), 'fro');
% 		netA_MSE(1,rr,cn)  = mean(mean((A_true_ce_re(rr,:,:)-A_pred_ce_re(rr,:,:)).^2));
% 		netA_MSE(2,rr,cn)  = mean(mean((A_true_ms_re(rr,:,:)-A_pred_ms_re(rr,:,:)).^2));
% 		netA_L1(1,rr,cn)   = norm(squeeze(A_true_ce_re(rr,:,:)-A_pred_ce_re(rr,:,:)), 1);						% Matrix 1-norm, not vector
% 		netA_L1(2,rr,cn)   = norm(squeeze(A_true_ms_re(rr,:,:)-A_pred_ms_re(rr,:,:)), 1);
% 		netA_Linf(1,rr,cn) = norm(reshape(A_true_ce_re(rr,:,:)-A_pred_ce_re(rr,:,:), numel(T_re), 1), Inf);		% Vector inf-norm, not matrix
% 		netA_Linf(2,rr,cn) = norm(reshape(A_true_ms_re(rr,:,:)-A_pred_ms_re(rr,:,:), numel(T_re), 1), Inf);
% 		
% 		netB_rL2(1,rr,cn)  = norm(squeeze(B_true_ce_re(rr,:,:)-B_pred_ce_re(rr,:,:)), 'fro') / norm(squeeze(B_true_ce_re(rr,:,:)), 'fro');
% 		netB_rL2(2,rr,cn)  = norm(squeeze(B_true_ms_re(rr,:,:)-B_pred_ms_re(rr,:,:)), 'fro') / norm(squeeze(B_true_ms_re(rr,:,:)), 'fro');
% 		netB_MSE(1,rr,cn)  = mean(mean((B_true_ce_re(rr,:,:)-B_pred_ce_re(rr,:,:)).^2));
% 		netB_MSE(2,rr,cn)  = mean(mean((B_true_ms_re(rr,:,:)-B_pred_ms_re(rr,:,:)).^2));
% 		netB_L1(1,rr,cn)   = norm(squeeze(B_true_ce_re(rr,:,:)-B_pred_ce_re(rr,:,:)), 1);
% 		netB_L1(2,rr,cn)   = norm(squeeze(B_true_ms_re(rr,:,:)-B_pred_ms_re(rr,:,:)), 1);
% 		netB_Linf(1,rr,cn) = norm(reshape(B_true_ce_re(rr,:,:)-B_pred_ce_re(rr,:,:), numel(T_re), 1), Inf);
% 		netB_Linf(2,rr,cn) = norm(reshape(B_true_ms_re(rr,:,:)-B_pred_ms_re(rr,:,:), numel(T_re), 1), Inf);
% 		
% 		netC_rL2(1,rr,cn)  = norm(squeeze(C_true_ce_re(rr,:,:)-C_pred_ce_re(rr,:,:)), 'fro') / norm(squeeze(C_true_ce_re(rr,:,:)), 'fro');
% 		netC_rL2(2,rr,cn)  = norm(squeeze(C_true_ms_re(rr,:,:)-C_pred_ms_re(rr,:,:)), 'fro') / norm(squeeze(C_true_ms_re(rr,:,:)), 'fro');
% 		netC_MSE(1,rr,cn)  = mean(mean((C_true_ce_re(rr,:,:)-C_pred_ce_re(rr,:,:)).^2));
% 		netC_MSE(2,rr,cn)  = mean(mean((C_true_ms_re(rr,:,:)-C_pred_ms_re(rr,:,:)).^2));
% 		netC_L1(1,rr,cn)   = norm(squeeze(C_true_ce_re(rr,:,:)-C_pred_ce_re(rr,:,:)), 1);
% 		netC_L1(2,rr,cn)   = norm(squeeze(C_true_ms_re(rr,:,:)-C_pred_ms_re(rr,:,:)), 1);
% 		netC_Linf(1,rr,cn) = norm(reshape(C_true_ce_re(rr,:,:)-C_pred_ce_re(rr,:,:), numel(T_re), 1), Inf);
% 		netC_Linf(2,rr,cn) = norm(reshape(C_true_ms_re(rr,:,:)-C_pred_ms_re(rr,:,:), numel(T_re), 1), Inf);
% 		
% 		netD_rL2(1,rr,cn)  = norm(squeeze(D_true_ce_re(rr,:,:)-D_pred_ce_re(rr,:,:)), 'fro') / norm(squeeze(D_true_ce_re(rr,:,:)), 'fro');
% 		netD_rL2(2,rr,cn)  = norm(squeeze(D_true_ms_re(rr,:,:)-D_pred_ms_re(rr,:,:)), 'fro') / norm(squeeze(D_true_ms_re(rr,:,:)), 'fro');
% 		netD_MSE(1,rr,cn)  = mean(mean((D_true_ce_re(rr,:,:)-D_pred_ce_re(rr,:,:)).^2));
% 		netD_MSE(2,rr,cn)  = mean(mean((D_true_ms_re(rr,:,:)-D_pred_ms_re(rr,:,:)).^2));
% 		netD_L1(1,rr,cn)   = norm(squeeze(D_true_ce_re(rr,:,:)-D_pred_ce_re(rr,:,:)), 1);
% 		netD_L1(2,rr,cn)   = norm(squeeze(D_true_ms_re(rr,:,:)-D_pred_ms_re(rr,:,:)), 1);
% 		netD_Linf(1,rr,cn) = norm(reshape(D_true_ce_re(rr,:,:)-D_pred_ce_re(rr,:,:), numel(T_re), 1), Inf);
% 		netD_Linf(2,rr,cn) = norm(reshape(D_true_ms_re(rr,:,:)-D_pred_ms_re(rr,:,:), numel(T_re), 1), Inf);
% 	end
% end

% Plot errors for all testing samples
if err_allsam
	% Compare all realizations across cases 1-4, one network at a time
	nettype = 'A';
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .55 .98 .40]);
	subplot(211);
		if strcmp(nettype, 'A');		bar(squeeze(netA_rL2(1,:,:)), 1);
		elseif strcmp(nettype, 'B');	bar(squeeze(netB_rL2(1,:,:)), 1);
		elseif strcmp(nettype, 'C');	bar(squeeze(netC_rL2(1,:,:)), 1);
		elseif strcmp(nettype, 'D');	bar(squeeze(netD_rL2(1,:,:)), 1);
		end
		title(['Elastic fiber integrity contribution: relative L2 error (Network ',nettype,')']); box off;
		ylabel('Relative L2 error'); % ylim([0 1e2]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
		l = legend('Case 1', 'Case 2', 'Case 3', 'Case 4'); l.Position = l.Position + [4e-2 1e-2 0 0]; l.EdgeColor = 'w';
	subplot(212);
		if strcmp(nettype, 'A');		bar(squeeze(netA_rL2(2,:,:)), 1);
		elseif strcmp(nettype, 'B');	bar(squeeze(netB_rL2(2,:,:)), 1);
		elseif strcmp(nettype, 'C');	bar(squeeze(netC_rL2(2,:,:)), 1);
		elseif strcmp(nettype, 'D');	bar(squeeze(netD_rL2(2,:,:)), 1);
		end
		title(['Mechanosensing contribution: relative L2 error (Network ',nettype,')']); box off;
		ylabel('Relative L2 error'); % ylim([0 1e2]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
	
	% Compare all realizations across networks A-D
	casenum = 4;
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .10 .98 .40]);
	subplot(211);
		ABCD_rL2_ce = cat(2,netA_rL2(1,:,casenum)',netB_rL2(1,:,casenum)',netC_rL2(1,:,casenum)',netD_rL2(1,:,casenum)');
		bar(ABCD_rL2_ce, 1);
		title(['Elastic fiber integrity contribution: relative L2 error (Case ',num2str(casenum),')']); box off;
		ylabel('Relative L2 error'); % ylim([0 .05]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
		l = legend('Network A', 'Network B', 'Network C', 'Network D'); l.Position = l.Position + [4e-2 1e-2 0 0]; l.EdgeColor = 'w';
	subplot(212);
		ABCD_rL2_ms = cat(2,netA_rL2(2,:,casenum)',netB_rL2(2,:,casenum)',netC_rL2(2,:,casenum)',netD_rL2(2,:,casenum)');
		bar(ABCD_rL2_ms, 1);
		title(['Mechanosensing contribution: relative L2 error (Case ',num2str(casenum),')']); box off;
		ylabel('Relative L2 error'); % ylim([0 .05]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log');
end

% % Error computation, averaged across all testing samples
% avg_netA_rL2_ce = mean(squeeze(netA_rL2(1,:,:)));	avg_netA_rL2_ms = mean(squeeze(netA_rL2(2,:,:)));
% avg_netB_rL2_ce = mean(squeeze(netB_rL2(1,:,:)));	avg_netB_rL2_ms = mean(squeeze(netB_rL2(2,:,:)));
% avg_netC_rL2_ce = mean(squeeze(netC_rL2(1,:,:)));	avg_netC_rL2_ms = mean(squeeze(netC_rL2(2,:,:)));
% avg_netD_rL2_ce = mean(squeeze(netD_rL2(1,:,:)));	avg_netD_rL2_ms = mean(squeeze(netD_rL2(2,:,:)));
% 
% avg_netA_MSE_ce = mean(squeeze(netA_MSE(1,:,:)));	avg_netA_MSE_ms = mean(squeeze(netA_MSE(2,:,:)));
% avg_netB_MSE_ce = mean(squeeze(netB_MSE(1,:,:)));	avg_netB_MSE_ms = mean(squeeze(netB_MSE(2,:,:)));
% avg_netC_MSE_ce = mean(squeeze(netC_MSE(1,:,:)));	avg_netC_MSE_ms = mean(squeeze(netC_MSE(2,:,:)));
% avg_netD_MSE_ce = mean(squeeze(netD_MSE(1,:,:)));	avg_netD_MSE_ms = mean(squeeze(netD_MSE(2,:,:)));
% 
% avg_netA_L1_ce = mean(squeeze(netA_L1(1,:,:)));		avg_netA_L1_ms = mean(squeeze(netA_L1(2,:,:)));
% avg_netB_L1_ce = mean(squeeze(netB_L1(1,:,:)));		avg_netB_L1_ms = mean(squeeze(netB_L1(2,:,:)));
% avg_netC_L1_ce = mean(squeeze(netC_L1(1,:,:)));		avg_netC_L1_ms = mean(squeeze(netC_L1(2,:,:)));
% avg_netD_L1_ce = mean(squeeze(netD_L1(1,:,:)));		avg_netD_L1_ms = mean(squeeze(netD_L1(2,:,:)));
% 
% avg_netA_Linf_ce = mean(squeeze(netA_Linf(1,:,:)));	avg_netA_Linf_ms = mean(squeeze(netA_Linf(2,:,:)));
% avg_netB_Linf_ce = mean(squeeze(netB_Linf(1,:,:)));	avg_netB_Linf_ms = mean(squeeze(netB_Linf(2,:,:)));
% avg_netC_Linf_ce = mean(squeeze(netC_Linf(1,:,:)));	avg_netC_Linf_ms = mean(squeeze(netC_Linf(2,:,:)));
% avg_netD_Linf_ce = mean(squeeze(netD_Linf(1,:,:)));	avg_netD_Linf_ms = mean(squeeze(netD_Linf(2,:,:)));

% Plot average errors for all cases and networks
if err_avg
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.30 .50 .40 .40]);
	subplot(221);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_rL2_ce; avg_netB_rL2_ce; avg_netC_rL2_ce; avg_netD_rL2_ce]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('EF: Avg Relative L_2');
	subplot(222);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_MSE_ce; avg_netB_MSE_ce; avg_netC_MSE_ce; avg_netD_MSE_ce]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('EF: Avg MSE');
		l = legend('A', 'B', 'C', 'D'); l.Position = l.Position + [5e-2 3e-2 0 0]; l.EdgeColor = 'w';
	subplot(223);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_L1_ce; avg_netB_L1_ce; avg_netC_L1_ce; avg_netD_L1_ce]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('EF: Avg L_1');
	subplot(224);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_Linf_ce; avg_netB_Linf_ce; avg_netC_Linf_ce; avg_netD_Linf_ce]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('EF: Avg L_\infty');

	figure; set(gcf, 'units', 'normalized', 'outerposition', [.30 .10 .40 .40]);
	subplot(221);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_rL2_ms; avg_netB_rL2_ms; avg_netC_rL2_ms; avg_netD_rL2_ms]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('MS: Avg Relative L_2');
	subplot(222);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_MSE_ms; avg_netB_MSE_ms; avg_netC_MSE_ms; avg_netD_MSE_ms]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('MS: Avg MSE');
		l = legend('A', 'B', 'C', 'D'); l.Position = l.Position + [5e-2 3e-2 0 0]; l.EdgeColor = 'w';
	subplot(223);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_L1_ms; avg_netB_L1_ms; avg_netC_L1_ms; avg_netD_L1_ms]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('MS: Avg L_1');
	subplot(224);
		bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
			[avg_netA_Linf_ms; avg_netB_Linf_ms; avg_netC_Linf_ms; avg_netD_Linf_ms]', 1, 'grouped',...
			'edgecolor', 'none'); box off;
		title('MS: Avg L_\infty');
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

% Save all errors
if err_save
	save('error_allcases.mat',...
	'netA_rL2', 'netA_MSE', 'netA_L1', 'netA_Linf',...
	'netB_rL2', 'netB_MSE', 'netB_L1', 'netB_Linf',...
	'netC_rL2', 'netC_MSE', 'netC_L1', 'netC_Linf',...
	'netD_rL2', 'netD_MSE', 'netD_L1', 'netD_Linf',...
	'allnets_allerrs');
end
