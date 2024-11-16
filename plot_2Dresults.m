
% David Li    Yale University    2024

% Requires colormaps folder and tight_subplot.m

clear; clc; close all;
addpath('colormaps');

pcolplot = 1;				% 0 or 1		Plot pcolor maps
pcolsave = 0;				% 0 or 1		Save pcolor maps

casenum = 'case2';			% case1-4		Which data format/maps
cn = str2double(casenum(end));

load([casenum, '_results.mat']);
% load([casenum, '_results_noflip.mat']);

% Define testing realizations
realizations = 38;		% [5 10 16 34 38 44] [2 4 13 14 24 29 31 32 33 34 38 40 43 44]

% Create figures
N = 4;
if pcolplot && ~ishandle(1)
	if cn==4; figure('name', 'Training data'); set(gcf, 'units', 'normalized', 'outerposition', [.10 .40 .20 .60]);
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

for nettype = {'networkA', 'networkB', 'networkD'}%, 'networkC'}
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
	
	% Plot dilatation and/or distensibility
	axes(f1(2*(c-1)+1)); % subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, dil_in); xlim([-pi pi]);
		if mod(cn, 2)==0; caxis([1 1.5]); else; caxis([0 255]); end
		if cn==4; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.7e-1 0 1.8e-2 0];
		elseif cn==3; shading flat;
		else; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0]; end
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Dilatation'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	axes(f1(2*c)); % subplot(10,2,2*r);
		if ~exist('distensibility', 'var')
			axis off;
		else
			pcolor(T_in, Z_in, dis_in); xlim([-pi pi]);
			if mod(cn, 2)==0; caxis([.03 .07]); else; caxis([0 255]); end
			if cn==4; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [1.7e-1 0 1.8e-2 0];
			else; shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [2.2e-1 0 1.8e-2 0]; end
			xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
	% 		if r==1; title('Distensibility'); end
			set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
		end
	if mod(cn, 2)==0; colormap(jet); else; colormap(gray); end
	
	% Plot elastic fiber insult
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

	% Plot mechanosensing insult
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

	% Plot elastic fiber & mechanosensing (absolute) errors
	axes(f4(c)); % axes(f4(2*(c-1)+1)); subplot(10,2,2*(r-1)+1);
		pcolor(T_in, Z_in, pred_ce_in-true_ce_in); xlim([-pi pi]);
% 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
		caxis([-.10 .10]);
% 		caxis(max(max(abs(caxis)))*[-1 1]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0];
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Eln fiber error'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(bwr);
	axes(f5(c)); % axes(f4(2*c)); % subplot(10,2,2*r);
		pcolor(T_in, Z_in, pred_ms_in-true_ms_in); xlim([-pi pi]);
% 		if cs < 3; caxis([-.025 .025]); else; caxis([-.1 .1]); end
		caxis([-.10 .10]);
% 		caxis(max(max(abs(caxis)))*[-1 1]);
		shading flat; cb = colorbar('linewidth', 1); cb.Position = cb.Position + [3.2e-1 0 1.2e-2 0];
		xticks(linspace(-pi,pi,3)); xticklabels({'-180','0','180'});
% 		if r==1; title('Mechanosensing error'); end
		set(gca, 'layer', 'top', 'fontsize', 9, 'linewidth', 1); pbaspect([1 1.4 1]);
	colormap(bwr);
	
	end
	
	c = c+1;
end

if pcolsave
	if ~exist('plots', 'dir'); mkdir('plots'); end
	figure(1); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_1-testing.png'], '-dpng', '-r300');
	figure(2); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_2-EF-pred.png'], '-dpng', '-r300');
	figure(4); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_3-EF-error.png'], '-dpng', '-r300');
	figure(3); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_4-MS-pred.png'], '-dpng', '-r300');
	figure(5); print(gcf, ['plots/',casenum,'_',num2str(realizations),'_5-MS-error.png'], '-dpng', '-r300');
end

% figure; set(gcf, 'units', 'normalized', 'outerposition', [.10 .10 .80 .40]);
% subplot(211);
% 	violinplot(err_ce_networkA_allcases(1:20,1:4));
% % 	xlim([0 51]); box off;
% 	title('Elastic fiber integrity error');
% 	set(gca, 'tickdir', 'out', 'ticklength', 'default');
% subplot(212);
% 	violinplot((target_mech-pred_mech)');
% 	xlim([0 51]); box off;
% 	title('Mechanosensing error');
% 	set(gca, 'tickdir', 'out', 'ticklength', 'default');

% maptype = 'heat_';			% heat_ or grey_	Heat map or greycale map
% arch    = 'oldArch_';			% oldArch_			(Used to have newArch_ option)
% train   = 'dil_';				% dil_ or dil_dis_	Dilatation only or dilatation & distensibility
% cnn     = '_CNN';				% _CNN or []		CNN or FNN branches
% path    = [maptype, arch, train, 'EF_mech', cnn, '\Results\seed=0\'];


% 	% networkA & B
% 	t_re       = reshape(init_loc_cyl(:,1),   2*nz+1, 2*nt);					% Theta coordinates (circ.)
% 	z_re       = reshape(init_loc_cyl(:,3),   2*nz+1, 2*nt);					% Z coordinates (axial)
% 	dil_re     = reshape(dilatation(r,:),     2*nt, 2*nz+1)';					% Dilatation
% 	if exist('distensibility', 'var')
% 		dis_re     = reshape(distensibility(r,:), 2*nt, 2*nz+1)';				% Distensibility
% 	else
% 		dis_re = nan(2*nt, 2*nz+1)';											% (Set distensibility to NaN for dilatation only case)
% 	end
% 	true_ce_re = reshape(target_ef(r,:),      2*nt, 2*nz+1)';					% Elastic fiber integrity insult, true
% 	true_ms_re = reshape(target_mech(r,:),    2*nt, 2*nz+1)';					% Mechanosensing insult, true
% 	pred_ce_re = reshape(pred_ef(r,:),        2*nt, 2*nz+1)';					% Elastic fiber integrity insult, predicted
% 	pred_ms_re = reshape(pred_mech(r,:),      2*nt, 2*nz+1)';					% Mechanosensing insult, predicted
% 
% 	% Reorder rows based on ascending theta coordinate
% 	[~, tmin] = min(t_re(1, :));
% 	t_re       = fliplr([t_re(:, tmin+1:end) t_re(:, 1:tmin)]);
% 	z_re       = fliplr([z_re(:, tmin+1:end) z_re(:, 1:tmin)]);
% 	dil_re     = fliplr([dil_re(:, tmin+1:end) dil_re(:, 1:tmin)]);
% 	dis_re     = fliplr([dis_re(:, tmin+1:end) dis_re(:, 1:tmin)]);
% 	true_ce_re = fliplr([true_ce_re(:, tmin+1:end) true_ce_re(:, 1:tmin)]);
% 	true_ms_re = fliplr([true_ms_re(:, tmin+1:end) true_ms_re(:, 1:tmin)]);
% 	pred_ce_re = fliplr([pred_ce_re(:, tmin+1:end) pred_ce_re(:, 1:tmin)]);
% 	pred_ms_re = fliplr([pred_ms_re(:, tmin+1:end) pred_ms_re(:, 1:tmin)]);
% 
% 	% Append last column to front
% 	t_re       = horzcat(-pi*ones(2*nz+1,1), t_re);
% 	z_re       = horzcat(z_re(:,end), z_re);
% 	dil_re     = horzcat(dil_re(:,end), dil_re);
% 	dis_re     = horzcat(dis_re(:,end), dis_re);
% 	true_ce_re = horzcat(true_ce_re(:,end), true_ce_re);
% 	true_ms_re = horzcat(true_ms_re(:,end), true_ms_re);
% 	pred_ce_re = horzcat(pred_ce_re(:,end), pred_ce_re);
% 	pred_ms_re = horzcat(pred_ms_re(:,end), pred_ms_re);
