
% David Li    Yale University    2024

% Requires results .mats (e.g., case1_results.mat) generated from data_preproc.m.
% Requires colormaps/ folder and tight_subplot.m.

clear; clc; close all;
addpath('colormaps');
set(0, 'DefaultAxesTickDir', 'in'); set(0, 'DefaultAxesTickDirMode', 'manual');

%% Set options
paddata   = 1;				% 0 or 1		Use padded data?
fliptheta = 1;				% 0 or 1		Load reordered theta results?
pcolplot  = 1;				% 0 or 1		Plot pcolor maps
pcolsave  = 0;				% 0 or 1		Save pcolor maps

casenum = 'case2';			% case1-4		Which data format/maps
cn = str2double(casenum(end));

%% Load results
if paddata; suffix = '_pad_penalty'; else; suffix = []; end

if fliptheta; load(['allResults', suffix, '/', casenum, '_results.mat']);			% With theta reordering
else; load(['allResults', suffix, '/', casenum, '_results_noflip.mat']); end		% Without theta reordering

% Define testing realizations
realizations = 38;
% Pad data									No pad
%  EF domi: (2 LNO bad) (34 mild) 38		12 17 38
%  MS domi: 4 13 44							1 14 28 37 45
%  Balance: 10 15 16						13 31

%% Create figures
N = 4;
if pcolplot && ~ishandle(1)
	if cn==4; figure('name', 'Training data'); set(gcf, 'units', 'normalized', 'outerposition', [.10 .40 .18 .60]);
		f1 = tight_subplot(N, 2, [.06 .20], [.05 .02], [.05 .20]);
	else; figure('name', 'Training data'); set(gcf, 'units', 'normalized', 'outerposition', [.10 .40 .17 .60]);
		f1 = tight_subplot(N, 2, [.06 .07], [.05 .02], [.10 .25]);
	end
	figure('name', 'Eln fiber insult'); set(gcf, 'units', 'normalized', 'outerposition', [.33 .40 .17 .60]);
		f2 = tight_subplot(N, 2, [.06 .07], [.05 .02], [.10 .25]);
	figure('name', 'Mechanosensing insult'); set(gcf, 'units', 'normalized', 'outerposition', [.63 .40 .17 .60]);
		f3 = tight_subplot(N, 2, [.06 .07], [.05 .02], [.10 .25]);
	figure('name', 'Eln fiber absolute error'); set(gcf, 'units', 'normalized', 'outerposition', [.50 .40 .10 .60]);
		f4 = tight_subplot(N, 1, [.06 .07], [.05 .02], [.00 .30]);
	figure('name', 'Mechanosensing absolute error'); set(gcf, 'units', 'normalized', 'outerposition', [.80 .40 .10 .60]);
		f5 = tight_subplot(N, 1, [.06 .07], [.05 .02], [.00 .30]);
end

r = realizations;

% Loop over all networks
for nettype = {'networkA', 'networkB', 'networkC', 'networkD'}%
	if contains(nettype, 'A');		c = 1;
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
	
	if pcolplot
	
	% Dilatation and/or distensibility
	axes(f1(2*(c-1)+1)); % subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, dil_in); xlim([-pi pi]);
		if mod(cn, 2)==0; caxis([1 1.5]); else; caxis([0 255]); end
		if cn==4; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.7e-1 0 1.8e-2 0];
		elseif cn==3; shading flat;
		else; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0];
		end
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Dilatation'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	axes(f1(2*c)); % subplot(10,2,2*r);
		if cn < 3; axis off;
		else
			pcolor(T_in, Z_in, dis_in); xlim([-pi pi]);
			if mod(cn, 2)==0; caxis([.03 .07]); else; caxis([0 255]); end
			if cn==4; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.7e-1 0 1.5e-2 0];
			else; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0];
			end
			xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
	% 		if r==1; title('Distensibility'); end
			set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
		end
	if mod(cn, 2)==0; colormap(jet); else; colormap(gray); end
	
	% True and predicted elastic fiber insult
	axes(f2(2*(c-1)+1)); % subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, true_ce_in); xlim([-pi pi])
		caxis([0 .48]);
		shading flat; % colorbar('linewidth', 1);
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('True eln fiber'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	axes(f2(2*c)); % subplot(10,2,2*r);
		pcolor(T_in, Z_in, pred_ce_in); xlim([-pi pi]);
		caxis([0 .48]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0];
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Predicted eln fiber'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(plasma);

	% True and predicted mechanosensing insult
	axes(f3(2*(c-1)+1)); % subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, true_ms_in); xlim([-pi pi]);
		caxis([0 .28]);
		shading flat; % colorbar('linewidth', 1);
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('True mechanosensing'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	axes(f3(2*c)); % subplot(10,2,2*r);
		pcolor(T_in, Z_in, pred_ms_in); xlim([-pi pi]);
		caxis([0 .28]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0];
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Predicted mechanosensing'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(viridis);

	% (Absolute) errors for elastic fiber & mechanosensing
	axes(f4(c)); % axes(f4(2*(c-1)+1)); subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, pred_ce_in-true_ce_in); xlim([-pi pi]);
% 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
		caxis([-.10 .10]);
% 		caxis(max(max(abs(caxis)))*[-1 1]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0]; cb.Ruler.TickLabelFormat = '%.2f';
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Eln fiber error'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(bwr);
	axes(f5(c)); % axes(f4(2*c)); % subplot(10,2,2*r);
		pcolor(T_in, Z_in, pred_ms_in-true_ms_in); xlim([-pi pi]);
% 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
		caxis([-.10 .10]);
% 		caxis(max(max(abs(caxis)))*[-1 1]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0]; cb.Ruler.TickLabelFormat = '%.2f';
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Mechanosensing error'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(bwr);
	
% 	% (Relative) errors for elastic fiber & mechanosensing (normalized wrt max insult)
% 	axes(f4(c)); % axes(f4(2*(c-1)+1)); subplot(10,2,2*(r-1)+1);
% 		pcolor(T_in, Z_in, (pred_ce_in-true_ce_in)/max(max(true_ce_in))); xlim([-pi pi]);
% % 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
% 		caxis([-.50 .50]);
% % 		caxis(max(max(abs(caxis)))*[-1 1]);
% 		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0]; cb.Ruler.TickLabelFormat = '%.2f';
% 		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% % 		if r==1; title('Eln fiber error'); end
% 		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
% 	colormap(bwr);
% 	axes(f5(c)); % axes(f4(2*c)); % subplot(10,2,2*r);
% 		pcolor(T_in, Z_in, (pred_ms_in-true_ms_in)/max(max(true_ms_in))); xlim([-pi pi]);
% % 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
% 		caxis([-.50 .50]);
% % 		caxis(max(max(abs(caxis)))*[-1 1]);
% 		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0]; cb.Ruler.TickLabelFormat = '%.2f';
% 		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% % 		if r==1; title('Mechanosensing error'); end
% 		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
% 	colormap(bwr);
	
	end
	
	c = c+1;
end

%% Save plots
if pcolsave
	if ~exist('plots', 'dir'); mkdir('plots'); end
	figure(1); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_1-testing.png'], '-dpng', '-r300');
	figure(2); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_2-EF-pred.png'], '-dpng', '-r300');
	figure(4); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_3-EF-error.png'], '-dpng', '-r300');
	figure(3); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_4-MS-pred.png'], '-dpng', '-r300');
	figure(5); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_5-MS-error.png'], '-dpng', '-r300');
end
