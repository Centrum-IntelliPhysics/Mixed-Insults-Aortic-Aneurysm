
% Importance of localized dilatation and distensibility in identifying
% thoracic aortic aneurysm contributors with neural operators
%
% Authors: David S. Li, Somdatta Goswami, Qianying Cao, Vivek Oommen,
%          Roland Assi, George Em Karniadakis, Jay D. Humphrey
% Yale University, Brown University
% 
% Last updated Aug 2025

% plot_2Dresults.m
% Requires results .mats (e.g., case1_results.mat) generated from data_preproc.m.
% Requires export_fig/ folder as well as subroutine threshfilter.m.

% This script generates error plots of network predictions:
% 'case1'		Dilatation only					Grayscale maps
% 'case2'		Dilatation only					Heat maps
% 'case3'		Dilatation & distensibility		Grayscale maps
% 'case4'		Dilatation & distensibility		Heat maps
% Network A		CNN-based DeepONet
% Network B		FNN-based DeepONet
% Network C		UNet
% Network D		LNO

% Generates 2 types of plots:
%
% allsam: Error computed over all samples, separately for elastic fiber
% integrity and mechanosensing
%	Relative L2 and MSE for the assembled array of testing errors.
% idvsam: Error computed for individual samples, separately for elastic fiber
% integrity and mechanosensing
%	Relative L2 for individual cases' testing errors (can also be changed
%	to MSE).

clear; clc; close all;
set(0, 'DefaultAxesTickDir', 'out'); set(0, 'DefaultAxesTickDirMode', 'manual');
set(0, 'DefaultAxesLineWidth', 0.75);
addpath export_fig

%% Set options
paddata    = 1;				% 0 or 1	Use padded data?
fliptheta  = 0;				% 0 or 1	Load reordered theta results?
filterins  = 0;				% 0 or 1	Filter insult magnitudes?
err_allsam = 1;				% 0 or 1	Plot errors for all realizations?
err_idvsam = 0;				% 0 or 1	Plot errors for individual realizations?
err_save   = 0;				% 0 or 1	Save error file?

% 1: Gray dil only, 2: Heat dil only, 3: Gray dil & dis, 4: Heat dil & dis
cases = {'case1', 'case2', 'case3', 'case4'};

% A: CNN-DeepONet, B: FNN-DeepONet, C: UNet, D: LNO
% nets  = {'networkA', 'networkB', 'networkC', 'networkD'};

if paddata; suffix = '_pad'; else; suffix = []; end

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
	
	% Create logical mask of all regions where normalized insults is above specified threshold (thres)
	if filterins
		thres = 0.5;
		for tt = 1:N
			A_output = threshfilter(A_true_ce_re(tt,:,:),A_pred_ce_re(tt,:,:),...
				A_true_ms_re(tt,:,:),A_pred_ms_re(tt,:,:),thres,450);
			A_true_ce_re(tt,:,:) = A_output.true_ce;	A_true_ms_re(tt,:,:) = A_output.true_ms;
			A_pred_ce_re(tt,:,:) = A_output.pred_ce;	A_pred_ms_re(tt,:,:) = A_output.pred_ms;
			
			B_output = threshfilter(B_true_ce_re(tt,:,:),B_pred_ce_re(tt,:,:),...
				B_true_ms_re(tt,:,:),B_pred_ms_re(tt,:,:),thres,450);
			B_true_ce_re(tt,:,:) = B_output.true_ce;	B_true_ms_re(tt,:,:) = B_output.true_ms;
			B_pred_ce_re(tt,:,:) = B_output.pred_ce;	B_pred_ms_re(tt,:,:) = B_output.pred_ms;
			
			C_output = threshfilter(C_true_ce_re(tt,:,:),C_pred_ce_re(tt,:,:),...
				C_true_ms_re(tt,:,:),C_pred_ms_re(tt,:,:),thres,450);
			C_true_ce_re(tt,:,:) = C_output.true_ce;	C_true_ms_re(tt,:,:) = C_output.true_ms;
			C_pred_ce_re(tt,:,:) = C_output.pred_ce;	C_pred_ms_re(tt,:,:) = C_output.pred_ms;
			
			D_output = threshfilter(D_true_ce_re(tt,:,:),D_pred_ce_re(tt,:,:),...
				D_true_ms_re(tt,:,:),D_pred_ms_re(tt,:,:),thres,450);
			D_true_ce_re(tt,:,:) = D_output.true_ce;	D_true_ms_re(tt,:,:) = D_output.true_ms;
			D_pred_ce_re(tt,:,:) = D_output.pred_ce;	D_pred_ms_re(tt,:,:) = D_output.pred_ms;
			
			netA_err_allcases(1,cn,tt,1) = norm(A_output.true_ce(A_output.ins_mask)-A_output.pred_ce(A_output.ins_mask), 'fro')/norm(A_output.true_ce(A_output.ins_mask), 'fro');
			netA_err_allcases(1,cn,tt,2) = immse(A_output.true_ce(A_output.ins_mask), A_output.pred_ce(A_output.ins_mask));
			netB_err_allcases(1,cn,tt,1) = norm(B_output.true_ce(B_output.ins_mask)-B_output.pred_ce(B_output.ins_mask), 'fro')/norm(B_output.true_ce(B_output.ins_mask), 'fro');
			netB_err_allcases(1,cn,tt,2) = immse(B_output.true_ce(B_output.ins_mask), B_output.pred_ce(B_output.ins_mask));
			netC_err_allcases(1,cn,tt,1) = norm(C_output.true_ce(C_output.ins_mask)-C_output.pred_ce(C_output.ins_mask), 'fro')/norm(C_output.true_ce(C_output.ins_mask), 'fro');
			netC_err_allcases(1,cn,tt,2) = immse(C_output.true_ce(C_output.ins_mask), C_output.pred_ce(C_output.ins_mask));
			netD_err_allcases(1,cn,tt,1) = norm(D_output.true_ce(D_output.ins_mask)-D_output.pred_ce(D_output.ins_mask), 'fro')/norm(D_output.true_ce(D_output.ins_mask), 'fro');
			netD_err_allcases(1,cn,tt,2) = immse(D_output.true_ce(D_output.ins_mask), D_output.pred_ce(A_output.ins_mask));
			
			netA_err_allcases(2,cn,tt,1) = norm(A_output.true_ms(A_output.ins_mask)-A_output.pred_ms(A_output.ins_mask), 'fro')/norm(A_output.true_ms(A_output.ins_mask), 'fro');
			netA_err_allcases(2,cn,tt,2) = immse(A_output.true_ms(A_output.ins_mask), A_output.pred_ms(A_output.ins_mask));
			netB_err_allcases(2,cn,tt,1) = norm(B_output.true_ms(B_output.ins_mask)-B_output.pred_ms(B_output.ins_mask), 'fro')/norm(B_output.true_ms(B_output.ins_mask), 'fro');
			netB_err_allcases(2,cn,tt,2) = immse(B_output.true_ms(B_output.ins_mask), B_output.pred_ms(B_output.ins_mask));
			netC_err_allcases(2,cn,tt,1) = norm(C_output.true_ms(C_output.ins_mask)-C_output.pred_ms(C_output.ins_mask), 'fro')/norm(C_output.true_ms(C_output.ins_mask), 'fro');
			netC_err_allcases(2,cn,tt,2) = immse(C_output.true_ms(C_output.ins_mask), C_output.pred_ms(C_output.ins_mask));
			netD_err_allcases(2,cn,tt,1) = norm(D_output.true_ms(D_output.ins_mask)-D_output.pred_ms(D_output.ins_mask), 'fro')/norm(D_output.true_ms(D_output.ins_mask), 'fro');
			netD_err_allcases(2,cn,tt,2) = immse(D_output.true_ms(D_output.ins_mask), D_output.pred_ms(D_output.ins_mask));
			
		end
	else
		for tt = 1:N
			netA_err_allcases(1,cn,tt,1) = norm(squeeze(A_true_ce_re(tt,:,:)-A_pred_ce_re(tt,:,:)), 'fro')/norm(squeeze(A_true_ce_re(tt,:,:)), 'fro');
			netA_err_allcases(1,cn,tt,2) = immse(A_true_ce_re(tt,:,:), A_pred_ce_re(tt,:,:));
			netB_err_allcases(1,cn,tt,1) = norm(squeeze(B_true_ce_re(tt,:,:)-B_pred_ce_re(tt,:,:)), 'fro')/norm(squeeze(B_true_ce_re(tt,:,:)), 'fro');
			netB_err_allcases(1,cn,tt,2) = immse(B_true_ce_re(tt,:,:), B_pred_ce_re(tt,:,:));
			netC_err_allcases(1,cn,tt,1) = norm(squeeze(C_true_ce_re(tt,:,:)-C_pred_ce_re(tt,:,:)), 'fro')/norm(squeeze(C_true_ce_re(tt,:,:)), 'fro');
			netC_err_allcases(1,cn,tt,2) = immse(C_true_ce_re(tt,:,:), C_pred_ce_re(tt,:,:));
			netD_err_allcases(1,cn,tt,1) = norm(squeeze(D_true_ce_re(tt,:,:)-D_pred_ce_re(tt,:,:)), 'fro')/norm(squeeze(D_true_ce_re(tt,:,:)), 'fro');
			netD_err_allcases(1,cn,tt,2) = immse(D_true_ce_re(tt,:,:), D_pred_ce_re(tt,:,:));
	
			netA_err_allcases(2,cn,tt,1) = norm(squeeze(A_true_ms_re(tt,:,:)-A_pred_ms_re(tt,:,:)), 'fro')/norm(squeeze(A_true_ms_re(tt,:,:)), 'fro');
			netA_err_allcases(2,cn,tt,2) = immse(A_true_ms_re(tt,:,:), A_pred_ms_re(tt,:,:));
			netB_err_allcases(2,cn,tt,1) = norm(squeeze(B_true_ms_re(tt,:,:)-B_pred_ms_re(tt,:,:)), 'fro')/norm(squeeze(B_true_ms_re(tt,:,:)), 'fro');
			netB_err_allcases(2,cn,tt,2) = immse(B_true_ms_re(tt,:,:), B_pred_ms_re(tt,:,:));
			netC_err_allcases(2,cn,tt,1) = norm(squeeze(C_true_ms_re(tt,:,:)-C_pred_ms_re(tt,:,:)), 'fro')/norm(squeeze(C_true_ms_re(tt,:,:)), 'fro');
			netC_err_allcases(2,cn,tt,2) = immse(C_true_ms_re(tt,:,:), C_pred_ms_re(tt,:,:));
			netD_err_allcases(2,cn,tt,1) = norm(squeeze(D_true_ms_re(tt,:,:)-D_pred_ms_re(tt,:,:)), 'fro')/norm(squeeze(D_true_ms_re(tt,:,:)), 'fro');
			netD_err_allcases(2,cn,tt,2) = immse(D_true_ms_re(tt,:,:), D_pred_ms_re(tt,:,:));
		end
	end
	
	% Reshape to a 2D grids and vectors for error calculation
	% Network A
	netA_err_ce(cn,1) = norm(A_true_ce_re(~isnan(A_true_ce_re))-A_pred_ce_re(~isnan(A_pred_ce_re)), 'fro')/norm(A_true_ce_re(~isnan(A_true_ce_re)), 'fro');
	netA_err_ce(cn,2) = immse(A_true_ce_re(~isnan(A_true_ce_re)), A_pred_ce_re(~isnan(A_pred_ce_re)));
	netA_err_ce(cn,3) = norm(A_true_ce_re(~isnan(A_true_ce_re))-A_pred_ce_re(~isnan(A_pred_ce_re)), 1);
	netA_err_ce(cn,4) = norm(A_true_ce_re(~isnan(A_true_ce_re))-A_pred_ce_re(~isnan(A_pred_ce_re)), Inf);
	netA_err_ms(cn,1) = norm(A_true_ms_re(~isnan(A_true_ms_re))-A_pred_ms_re(~isnan(A_pred_ms_re)), 'fro')/norm(A_true_ms_re(~isnan(A_true_ms_re)), 'fro');
	netA_err_ms(cn,2) = immse(A_true_ms_re(~isnan(A_true_ms_re)), A_pred_ms_re(~isnan(A_pred_ms_re)));
	netA_err_ms(cn,3) = norm(A_true_ms_re(~isnan(A_true_ms_re))-A_pred_ms_re(~isnan(A_pred_ms_re)), 1);
	netA_err_ms(cn,4) = norm(A_true_ms_re(~isnan(A_true_ms_re))-A_pred_ms_re(~isnan(A_pred_ms_re)), Inf);
	
	% Network B
	netB_err_ce(cn,1) = norm(B_true_ce_re(~isnan(B_true_ce_re))-B_pred_ce_re(~isnan(B_pred_ce_re)), 'fro')/norm(B_true_ce_re(~isnan(B_true_ce_re)), 'fro');
	netB_err_ce(cn,2) = immse(B_true_ce_re(~isnan(B_true_ce_re)), B_pred_ce_re(~isnan(B_pred_ce_re)));
	netB_err_ce(cn,3) = norm(B_true_ce_re(~isnan(B_true_ce_re))-B_pred_ce_re(~isnan(B_pred_ce_re)), 1);
	netB_err_ce(cn,4) = norm(B_true_ce_re(~isnan(B_true_ce_re))-B_pred_ce_re(~isnan(B_pred_ce_re)), Inf);
	netB_err_ms(cn,1) = norm(B_true_ms_re(~isnan(B_true_ms_re))-B_pred_ms_re(~isnan(B_pred_ms_re)), 'fro')/norm(B_true_ms_re(~isnan(B_true_ms_re)), 'fro');
	netB_err_ms(cn,2) = immse(B_true_ms_re(~isnan(B_true_ms_re)), B_pred_ms_re(~isnan(B_pred_ms_re)));
	netB_err_ms(cn,3) = norm(B_true_ms_re(~isnan(B_true_ms_re))-B_pred_ms_re(~isnan(B_pred_ms_re)), 1);
	netB_err_ms(cn,4) = norm(B_true_ms_re(~isnan(B_true_ms_re))-B_pred_ms_re(~isnan(B_pred_ms_re)), Inf);
	
	% Network C
	netC_err_ce(cn,1) = norm(C_true_ce_re(~isnan(C_true_ce_re))-C_pred_ce_re(~isnan(C_pred_ce_re)), 'fro')/norm(C_true_ce_re(~isnan(C_true_ce_re)), 'fro');
	netC_err_ce(cn,2) = immse(C_true_ce_re(~isnan(C_true_ce_re)), C_pred_ce_re(~isnan(C_pred_ce_re)));
	netC_err_ce(cn,3) = norm(C_true_ce_re(~isnan(C_true_ce_re))-C_pred_ce_re(~isnan(C_pred_ce_re)), 1);
	netC_err_ce(cn,4) = norm(C_true_ce_re(~isnan(C_true_ce_re))-C_pred_ce_re(~isnan(C_pred_ce_re)), Inf);
	netC_err_ms(cn,1) = norm(C_true_ms_re(~isnan(C_true_ms_re))-C_pred_ms_re(~isnan(C_pred_ms_re)), 'fro')/norm(C_true_ms_re(~isnan(C_true_ms_re)), 'fro');
	netC_err_ms(cn,2) = immse(C_true_ms_re(~isnan(C_true_ms_re)), C_pred_ms_re(~isnan(C_pred_ms_re)));
	netC_err_ms(cn,3) = norm(C_true_ms_re(~isnan(C_true_ms_re))-C_pred_ms_re(~isnan(C_pred_ms_re)), 1);
	netC_err_ms(cn,4) = norm(C_true_ms_re(~isnan(C_true_ms_re))-C_pred_ms_re(~isnan(C_pred_ms_re)), Inf);
	
	% Network D
	netD_err_ce(cn,1) = norm(D_true_ce_re(~isnan(D_true_ce_re))-D_pred_ce_re(~isnan(D_pred_ce_re)), 'fro')/norm(D_true_ce_re(~isnan(D_true_ce_re)), 'fro');
	netD_err_ce(cn,2) = immse(D_true_ce_re(~isnan(D_true_ce_re)), D_pred_ce_re(~isnan(D_pred_ce_re)));
	netD_err_ce(cn,3) = norm(D_true_ce_re(~isnan(D_true_ce_re))-D_pred_ce_re(~isnan(D_pred_ce_re)), 1);
	netD_err_ce(cn,4) = norm(D_true_ce_re(~isnan(D_true_ce_re))-D_pred_ce_re(~isnan(D_pred_ce_re)), Inf);
	netD_err_ms(cn,1) = norm(D_true_ms_re(~isnan(D_true_ms_re))-D_pred_ms_re(~isnan(D_pred_ms_re)), 'fro')/norm(D_true_ms_re(~isnan(D_true_ms_re)), 'fro');
	netD_err_ms(cn,2) = immse(D_true_ms_re(~isnan(D_true_ms_re)), D_pred_ms_re(~isnan(D_pred_ms_re)));
	netD_err_ms(cn,3) = norm(D_true_ms_re(~isnan(D_true_ms_re))-D_pred_ms_re(~isnan(D_pred_ms_re)), 1);
	netD_err_ms(cn,4) = norm(D_true_ms_re(~isnan(D_true_ms_re))-D_pred_ms_re(~isnan(D_pred_ms_re)), Inf);
	
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
	set(b(1), 'facecolor', [248 148 65]/255);
	set(b(2), 'facecolor', [203 71 120]/255);
	set(b(3), 'facecolor', [126 3 168]/255);
	set(b(4), 'facecolor', [13 8 135]/255);
	ylabel({'Relative L2',''}, 'fontweight', 'bold'); ylim([0 0.20]);
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0, 'fontsize', 9);
	title({'Elastic fiber integrity',''});
	l = legend('CNN-DeepONet', 'FNN-DeepONet', 'UNet', 'LNO'); l.Position = l.Position + [7e-2 1e-2 0 0]; l.EdgeColor = 'w';
	
	subplot(223);
	b = bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ce(:,2) netB_err_ce(:,2) netC_err_ce(:,2) netD_err_ce(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(b(1), 'facecolor', [248 148 65]/255);
	set(b(2), 'facecolor', [203 71 120]/255);
	set(b(3), 'facecolor', [126 3 168]/255);
	set(b(4), 'facecolor', [13 8 135]/255);
	ylabel({'MSE',''}, 'fontweight', 'bold'); ylim([1e-6 1e-3]);
	set(gca, 'yscale', 'log');
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0, 'fontsize', 9);
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
	b = bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,1) netB_err_ms(:,1) netC_err_ms(:,1) netD_err_ms(:,1)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(b(1), 'facecolor', [93 201 99]/255);
	set(b(2), 'facecolor', [33 144 140]/255);
	set(b(3), 'facecolor', [59 82 139]/255);
	set(b(4), 'facecolor', [68 1 84]/255);
	ylim([0 0.2]);
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0, 'fontsize', 9);
	title({'Mechanosensing',''});
	l = legend('CNN-DeepONet', 'FNN-DeepONet', 'UNet', 'LNO'); l.Position = l.Position + [7e-2 1e-2 0 0]; l.EdgeColor = 'w';
	
	subplot(224);
	b = bar(categorical({'Case 1','Case 2','Case 3','Case 4'}),...
		[netA_err_ms(:,2) netB_err_ms(:,2) netC_err_ms(:,2) netD_err_ms(:,2)], 1, 'grouped',...
		'edgecolor', 'none'); box off;
	set(b(1), 'facecolor', [93 201 99]/255);
	set(b(2), 'facecolor', [33 144 140]/255);
	set(b(3), 'facecolor', [59 82 139]/255);
	set(b(4), 'facecolor', [68 1 84]/255);
	set(gca, 'yscale', 'log'); ylim([1e-6 1e-3]);
	set(gca, 'xticklabel', barcases, 'xticklabelrotation', 0, 'fontsize', 9);
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
	
% 	% Compare all realizations across cases 1-4, one network at a time
% 	nettype = 'C';
% 	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .50 .98 .50]);
% 	subplot(211);
% 		if strcmp(nettype, 'A');		b = bar(squeeze(netA_err_allcases(1,:,:,etype))', 1);	netname = 'CNN-DeepONet';
% 		elseif strcmp(nettype, 'B');	b = bar(squeeze(netB_err_allcases(1,:,:,etype))', 1);	netname = 'FNN-DeepONet';
% 		elseif strcmp(nettype, 'C');	b = bar(squeeze(netC_err_allcases(1,:,:,etype))', 1);	netname = 'UNet';
% 		elseif strcmp(nettype, 'D');	b = bar(squeeze(netD_err_allcases(1,:,:,etype))', 1);	netname = 'LNO';
% 		end
% 		title(['Elastic fiber integrity contribution: ',ename, ' (',nettype,': ',netname, ')']); box off;
% 		set(b(1), 'facecolor', [248 148 65]/255);
% 		set(b(2), 'facecolor', [203 71 120]/255);
% 		set(b(3), 'facecolor', [126 3 168]/255);
% 		set(b(4), 'facecolor', [13 8 135]/255);
% 		ylabel(ename); ylim([1e-3 1e1]);
% 		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log', 'fontsize', 11);
% 		l = legend('Dil only, gray', 'Dil only, heat', 'Dil & dis, gray', 'Dil & dis, heat');
% 		l.Position = l.Position + [7e-2 4e-2 0 0]; l.EdgeColor = 'w';
% 	subplot(212);
% 		if strcmp(nettype, 'A');		b = bar(squeeze(netA_err_allcases(2,:,:,etype))', 1);	netname = 'CNN-DeepONet';
% 		elseif strcmp(nettype, 'B');	b = bar(squeeze(netB_err_allcases(2,:,:,etype))', 1);	netname = 'FNN-DeepONet';
% 		elseif strcmp(nettype, 'C');	b = bar(squeeze(netC_err_allcases(2,:,:,etype))', 1);	netname = 'UNet';
% 		elseif strcmp(nettype, 'D');	b = bar(squeeze(netD_err_allcases(2,:,:,etype))', 1);	netname = 'LNO';
% 		end
% 		title(['Mechanosensing contribution: ',ename, ' (',nettype,': ',netname, ')']); box off;
% 		set(b(1), 'facecolor', [93 201 99]/255);
% 		set(b(2), 'facecolor', [33 144 140]/255);
% 		set(b(3), 'facecolor', [59 82 139]/255);
% 		set(b(4), 'facecolor', [68 1 84]/255);
% 		ylabel(ename); ylim([1e-3 1e1]);
% 		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log', 'fontsize', 11);
% 		l = legend('Dil only, gray', 'Dil only, heat', 'Dil & dis, gray', 'Dil & dis, heat');
% 		l.Position = l.Position + [7e-2 4e-2 0 0]; l.EdgeColor = 'w';
	
	% Compare all realizations across networks A-D
	casenum = 1;
	if casenum == 1;		cname = 'Dil only, gray';
	elseif casenum == 2;	cname = 'Dil only, heat';
	elseif casenum == 3;	cname = 'Dil & dis, gray';
	elseif casenum == 4;	cname = 'Dil & dis, heat';
	end
	figure; set(gcf, 'units', 'normalized', 'outerposition', [.01 .05 .98 .50]);
	subplot(211);
		ABCD_ce = cat(2,squeeze(netA_err_allcases(1,casenum,:,etype)),...
						squeeze(netB_err_allcases(1,casenum,:,etype)),...
						squeeze(netC_err_allcases(1,casenum,:,etype)),...
						squeeze(netD_err_allcases(1,casenum,:,etype)));
		b = bar(ABCD_ce, 1);
		title(['Elastic fiber integrity contribution: relative L2 error (',num2str(casenum),': ',cname, ')']); box off;
		ylabel('Relative L2 error'); ylim([1e-3 1e1]);
		set(b(1), 'facecolor', [248 148 65]/255);
		set(b(2), 'facecolor', [203 71 120]/255);
		set(b(3), 'facecolor', [126 3 168]/255);
		set(b(4), 'facecolor', [13 8 135]/255);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log', 'fontsize', 11); %
		l = legend('CNN-DeepONet', 'FNN-DeepONet', 'UNet', 'LNO');
		l.Position = l.Position + [7.6e-2 4e-2 0 0]; l.EdgeColor = 'w';
	subplot(212);
		ABCD_ms = cat(2,squeeze(netA_err_allcases(2,casenum,:,etype)),...
						squeeze(netB_err_allcases(2,casenum,:,etype)),...
						squeeze(netC_err_allcases(2,casenum,:,etype)),...
						squeeze(netD_err_allcases(2,casenum,:,etype)));
		b = bar(ABCD_ms, 1);
		title(['Mechanosensing contribution: relative L2 error (',num2str(casenum),': ',cname, ')']); box off;
		set(b(1), 'facecolor', [93 201 99]/255);
		set(b(2), 'facecolor', [33 144 140]/255);
		set(b(3), 'facecolor', [59 82 139]/255);
		set(b(4), 'facecolor', [68 1 84]/255);
		ylabel('Relative L2 error'); ylim([1e-3 1e1]);
		set(gca, 'tickdir', 'out', 'xtick', 1:50, 'ticklength', [4e-3 0], 'linewidth', .75, 'yscale', 'log', 'fontsize', 11); %
		l = legend('CNN-DeepONet', 'FNN-DeepONet', 'UNet', 'LNO');
		l.Position = l.Position + [7.6e-2 4e-2 0 0]; l.EdgeColor = 'w';
end

%% Save all errors
if err_save
	save('error_allcases.mat',...
	'netA_rL2', 'netA_MSE', 'netA_L1', 'netA_Linf',...
	'netB_rL2', 'netB_MSE', 'netB_L1', 'netB_Linf',...
	'netC_rL2', 'netC_MSE', 'netC_L1', 'netC_Linf',...
	'netD_rL2', 'netD_MSE', 'netD_L1', 'netD_Linf',...
	'allnets_allerrs');
end
