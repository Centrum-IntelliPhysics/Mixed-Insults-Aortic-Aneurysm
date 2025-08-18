
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
% Requires colormaps/ export_fig/ folders as well as subroutines
% threshfilter.m and tight_subplot.m.

% This script generates 2D colormap plots of network predictions:
% 'case1'		Dilatation only					Grayscale maps
% 'case2'		Dilatation only					Heat maps
% 'case3'		Dilatation & distensibility		Grayscale maps
% 'case4'		Dilatation & distensibility		Heat maps
% Network A		CNN-based DeepONet
% Network B		FNN-based DeepONet
% Network C		UNet
% Network D		LNO

% Generates 3 plots:
%
% Figure 1
%	1st column: Input data.
%	2nd column: Ground truth elastic fiber integrity (top, plasma) and
%	mechanosensing (bottom, viridis) combined insult.
% Figure 2
%	Elastic fiber integrity predictions (top, plasma) and absolute errors
%	(bottom, rwb), with each column corresponding to each network.
% Figure 3
%	Mechanosensing predictions (top, plasma) and absolute errors (bottom,
%	rwb), with each column corresponding to each network.

clear; clc; close all;
addpath colormaps export_fig;
set(0, 'DefaultAxesTickDir', 'in'); set(0, 'DefaultAxesTickDirMode', 'manual');

%% Set options
paddata   = 1;				% 0 or 1		Use padded data?
fliptheta = 0;				% 0 or 1		Load reordered theta results?
filterins = 0;				% 0 or 1		Filter insult magnitudes?
pcolplot  = 1;				% 0 or 1		Plot pcolor maps?
pcolsave  = 0;				% 0 or 1		Save pcolor maps?

casenum = 'case1';			% case1-4		Which data format/maps
cn = str2double(casenum(end));

%% Load results
if paddata; suffix = '_pad'; else; suffix = []; end

if fliptheta; load(['allResults', suffix, '/', casenum, '_results.mat']);			% With theta reordering
else; load(['allResults', suffix, '/', casenum, '_results_noflip.mat']); end		% Without theta reordering

% Define testing realization number(s)
realizations = 15;
% Pad data									No pad
%  EF domi: (2 LNO bad) (34 mild) 38		12 17 38
%  MS domi: 4 13 44							1 14 28 37 45
%  Balance: 10 15 16						13 31

%% Create figures
% tight_subplot(Nh, Nw, [gap_h gap_w], marg_h, marg_w)
N = 4;
if pcolplot && ~ishandle(1)
	figure('name', 'Training data'); set(gcf, 'units', 'normalized', 'outerposition', [.00 .59 .20 .35]);
		f1 = tight_subplot(2, 2, [.06 .12], [.05 .05], [.01 .13]);
	figure('name', 'Eln fiber insult'); set(gcf, 'units', 'normalized', 'outerposition', [.50 .67 .25 .33]);
		f2 = tight_subplot(2, N, [.06 .01], [.05 .05], [.02 .11]);
	figure('name', 'Mechanosensing insult'); set(gcf, 'units', 'normalized', 'outerposition', [.50 .34 .25 .33]);
		f3 = tight_subplot(2, N, [.06 .01], [.05 .05], [.02 .11]);
end

r = realizations;

% Loop over all networks
for nettype = {'networkA', 'networkB', 'networkC', 'networkD'} %{'networkA', 'networkB', 'networkC', 'networkD'} {'networkC'}
	if	   contains(nettype, 'A');	c = 1;
	elseif contains(nettype, 'B');	c = 2;
	elseif contains(nettype, 'C');	c = 3;
	elseif contains(nettype, 'D');	c = 4;
	end
	
	if mod(cn, 2)==1			% Leave uninterpolated for grayscale maps
		T_in   = T_re;
		Z_in   = Z_re;
		dil_in = squeeze(gray_dil_re(r,:,:));
		dis_in = squeeze(gray_dis_re(r,:,:));
		if contains(nettype, 'A')
			true_ce_in = squeeze(A_true_ce_re(r,:,:));
			true_ms_in = squeeze(A_true_ms_re(r,:,:));
			pred_ce_in = squeeze(A_pred_ce_re(r,:,:));
			pred_ms_in = squeeze(A_pred_ms_re(r,:,:));
		elseif contains(nettype, 'B')
			true_ce_in = squeeze(B_true_ce_re(r,:,:));
			true_ms_in = squeeze(B_true_ms_re(r,:,:));
			pred_ce_in = squeeze(B_pred_ce_re(r,:,:));
			pred_ms_in = squeeze(B_pred_ms_re(r,:,:));
		elseif contains(nettype, 'C')
			true_ce_in = squeeze(C_true_ce_re(r,:,:));
			true_ms_in = squeeze(C_true_ms_re(r,:,:));
			pred_ce_in = squeeze(C_pred_ce_re(r,:,:));
			pred_ms_in = squeeze(C_pred_ms_re(r,:,:));
		elseif contains(nettype, 'D')
			true_ce_in = squeeze(D_true_ce_re(r,:,:));
			true_ms_in = squeeze(D_true_ms_re(r,:,:));
			pred_ce_in = squeeze(D_pred_ce_re(r,:,:));
			pred_ms_in = squeeze(D_pred_ms_re(r,:,:));
		end
	else						% Cubic interpolation for heat maps
		n_refine = 0;			% Refinement factor
		T_in     = interp2(T_re, n_refine, 'cubic');
		Z_in     = interp2(Z_re, n_refine, 'cubic');
		dil_in   = interp2(squeeze(heat_dil_re(r,:,:)), n_refine, 'cubic');
		dis_in   = interp2(squeeze(heat_dis_re(r,:,:)), n_refine, 'cubic');
		if contains(nettype, 'A')
			true_ce_in = interp2(squeeze(A_true_ce_re(r,:,:)), n_refine, 'cubic');
			true_ms_in = interp2(squeeze(A_true_ms_re(r,:,:)), n_refine, 'cubic');
			pred_ce_in = interp2(squeeze(A_pred_ce_re(r,:,:)), n_refine, 'cubic');
			pred_ms_in = interp2(squeeze(A_pred_ms_re(r,:,:)), n_refine, 'cubic');
		elseif contains(nettype, 'B')
			true_ce_in = interp2(squeeze(B_true_ce_re(r,:,:)), n_refine, 'cubic');
			true_ms_in = interp2(squeeze(B_true_ms_re(r,:,:)), n_refine, 'cubic');
			pred_ce_in = interp2(squeeze(B_pred_ce_re(r,:,:)), n_refine, 'cubic');
			pred_ms_in = interp2(squeeze(B_pred_ms_re(r,:,:)), n_refine, 'cubic');
		elseif contains(nettype, 'C')
			true_ce_in = interp2(squeeze(C_true_ce_re(r,:,:)), n_refine, 'cubic');
			true_ms_in = interp2(squeeze(C_true_ms_re(r,:,:)), n_refine, 'cubic');
			pred_ce_in = interp2(squeeze(C_pred_ce_re(r,:,:)), n_refine, 'cubic');
			pred_ms_in = interp2(squeeze(C_pred_ms_re(r,:,:)), n_refine, 'cubic');
		elseif contains(nettype, 'D')
			true_ce_in = interp2(squeeze(D_true_ce_re(r,:,:)), n_refine, 'cubic');
			true_ms_in = interp2(squeeze(D_true_ms_re(r,:,:)), n_refine, 'cubic');
			pred_ce_in = interp2(squeeze(D_pred_ce_re(r,:,:)), n_refine, 'cubic');
			pred_ms_in = interp2(squeeze(D_pred_ms_re(r,:,:)), n_refine, 'cubic');
		end
	end
	
	% Create logical mask of all regions where normalized insults is above
	% specified threshold
	if filterins
		thres = 0.5;
		ce_norm = true_ce_in./max(true_ce_in(:));   ms_norm = true_ms_in./max(true_ms_in(:));

		ins_mask = ce_norm >= thres & ms_norm >= thres;
		true_ce_in(~ins_mask) = NaN;    pred_ce_in(~ins_mask) = NaN;
		true_ms_in(~ins_mask) = NaN;    pred_ms_in(~ins_mask) = NaN;

	else
		ins_mask = ones(size(true_ce_in));

	end

	if pcolplot
	
	% Dilatation and/or distensibility
	axes(f1(1));
		pcolor(T_in, Z_in, dil_in); shading flat;
		cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 -1e-4 0];
		if mod(cn, 2)==0; caxis([1 1.5]); else; caxis([0 255]); cb.Ticks = [0 255]; end
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
	axes(f1(3));
		if cn < 3; axis off;
		else
			pcolor(T_in, Z_in, dis_in); shading flat;
			cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 -1e-4 0];
			if mod(cn, 2)==0; caxis([.03 .07]); else; caxis([0 255]); cb.Ticks = [0 255]; end
			set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
		end
	if mod(cn, 2)==0; colormap(jet); else; colormap(gray); end
	
	% True and predicted elastic fiber insult
	axes(f1(2));
		pcolor(T_in, Z_in, true_ce_in); shading flat;
		caxis([0 .48]);
		cb = colorbar('linewidth', 1); cb.Ticks = [0 .2 .4]; cb.Position = cb.Position + [1.1e-1 0 -1e-4 0];
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
		colormap(f1(2),plasma);
	axes(f2(c));
		pcolor(T_in, Z_in, pred_ce_in); shading flat;
		caxis([0 .48]);
		if c==4; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 1e-2 0]; end
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
	    colormap(f2(c),plasma);

	% True and predicted mechanosensing insult
	axes(f1(4));
		pcolor(T_in, Z_in, true_ms_in); shading flat;
		caxis([0 .28]);
		cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 -1e-4 0];
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
		colormap(f1(4),viridis);
	axes(f3(c));
		pcolor(T_in, Z_in, pred_ms_in); shading flat;
		caxis([0 .28]);
		if c==4; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 1e-2 0]; end
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
	    colormap(f3(c),viridis);
	
	% (Absolute) errors for elastic fiber & mechanosensing
	axes(f2(c+N));
		pcolor(T_in, Z_in, pred_ce_in-true_ce_in); shading flat;
		caxis([-.10 .10]);
		if c==4; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 1e-2 0]; end
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
	    colormap(f2(c+N),bwr);
	axes(f3(c+N));
		pcolor(T_in, Z_in, pred_ms_in-true_ms_in); shading flat;
		caxis([-.10 .10]);
		if c==4; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.1e-1 0 1e-2 0]; end
		set(gca, 'layer', 'top', 'fontsize', 12, 'linewidth', 1, 'XTick', [], 'YTick', []); pbaspect([1 1.25 1]);
	    colormap(f3(c+N),bwr);
	end
	
	c = c+1;
end

%% Save plots
if pcolsave
	if ~exist('plots', 'dir'); mkdir('plots'); end
	figure(1); set(gcf, 'color', 'w'); export_fig(['plots/',casenum,'_',num2str(realizations),'_1-testing.png'],  '-m3.5');
	figure(2); set(gcf, 'color', 'w'); export_fig(['plots/',casenum,'_',num2str(realizations),'_2-EF-pred.png'],  '-m3.5');
	figure(3); set(gcf, 'color', 'w'); export_fig(['plots/',casenum,'_',num2str(realizations),'_4-MS-pred.png'],  '-m3.5');
end
