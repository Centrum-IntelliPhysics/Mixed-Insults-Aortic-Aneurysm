
% David Li    Yale University    2024

clear; clc; close all;

%% Set options
paddata   = 1;				% 0 or 1		Assemble results with padded column?
fliptheta = 0;				% 0 or 1		Reorder maps by ascending theta? Can reveal periodicity issues
casenum = 'case4';			% case1-4		Which data format/maps

%% Prepare coordinates and testing data
nt = 20; nz = 20;			% Mesh size (# 27-node hex elements)
if paddata; suffix = '_pad_penalty'; else; suffix = []; end

% Coordinates
load(['data/new_delta=0000_pad.mat'], 'init_loc_cyl');
% load(['data/new_delta=0000',suffix,'.mat'], 'init_loc_cyl');
T = init_loc_cyl(:,1);		% Theta (circ.)
Z = init_loc_cyl(:,3);		% Z (axial)

% Grayscale map testing data
load(['case3/networkA/Results',suffix,'/pred.mat'], 'dilatation', 'distensibility')
gray_dil = uint8(dilatation*255);		clear dilatation;
gray_dis = uint8(distensibility*255);	clear distensibility;

% Heat map testing data
load(['case4/networkA/Results',suffix,'/pred.mat'], 'dilatation', 'distensibility')
heat_dil = dilatation;					clear dilatation;
heat_dis = distensibility;				clear distensibility;

% Reshape into 2D grids, reorder columns based on ascending theta coordinate
if paddata
	T_re = reshape(T, 2*nz+1, 2*nt+1);
	Z_re = reshape(Z, 2*nz+1, 2*nt+1);
else
	T_re = reshape(T, 2*nz+1, 2*nt);
	Z_re = reshape(Z, 2*nz+1, 2*nt);
end

% If padded, the last column is repeated in the input data; therefore, only
% go to the 2nd-to-last column
[~, Tmin] = min(T_re(1, :));
T_re      = fliplr([T_re(:, Tmin+1:2*nt) T_re(:, 1:Tmin)]);	
Z_re      = fliplr([Z_re(:, Tmin+1:2*nt) Z_re(:, 1:Tmin)]);
T_re      = horzcat(-pi*ones(2*nz+1,1), T_re);
Z_re      = horzcat(Z_re(:,end), Z_re);

% Grayscale & heat maps for dilatation (dil) and distensibility (dis)
% 're' stands for reshaped to 2D grid (2*nz+1 x 2*nt+1) for 50 samples
gray_dil_re = uint8(zeros(50, 2*nz+1, 2*nt+1));
gray_dis_re = uint8(zeros(50, 2*nz+1, 2*nt+1));
heat_dil_re = zeros(50, 2*nz+1, 2*nt+1);
heat_dis_re = zeros(50, 2*nz+1, 2*nt+1);
for tt = 1:50
	if paddata
		gray_dil_2D = reshape(gray_dil(tt,:), 2*nt+1, 2*nz+1)';
		gray_dis_2D = reshape(gray_dis(tt,:), 2*nt+1, 2*nz+1)';
		heat_dil_2D = reshape(heat_dil(tt,:), 2*nt+1, 2*nz+1)';
		heat_dis_2D = reshape(heat_dis(tt,:), 2*nt+1, 2*nz+1)';
	else
		gray_dil_2D = reshape(gray_dil(tt,:), 2*nt, 2*nz+1)';
		gray_dis_2D = reshape(gray_dis(tt,:), 2*nt, 2*nz+1)';
		heat_dil_2D = reshape(heat_dil(tt,:), 2*nt, 2*nz+1)';
		heat_dis_2D = reshape(heat_dis(tt,:), 2*nt, 2*nz+1)';
	end
	if fliptheta
		gray_dil_2D = fliplr([gray_dil_2D(:, Tmin+1:2*nt) gray_dil_2D(:, 1:Tmin)]);
		gray_dis_2D = fliplr([gray_dis_2D(:, Tmin+1:2*nt) gray_dis_2D(:, 1:Tmin)]);
		heat_dil_2D = fliplr([heat_dil_2D(:, Tmin+1:2*nt) heat_dil_2D(:, 1:Tmin)]);
		heat_dis_2D = fliplr([heat_dis_2D(:, Tmin+1:2*nt) heat_dis_2D(:, 1:Tmin)]);
		gray_dil_re(tt,:,:) = horzcat(gray_dil_2D(:,end), gray_dil_2D);
		gray_dis_re(tt,:,:) = horzcat(gray_dis_2D(:,end), gray_dis_2D);
		heat_dil_re(tt,:,:) = horzcat(heat_dil_2D(:,end), heat_dil_2D);
		heat_dis_re(tt,:,:) = horzcat(heat_dis_2D(:,end), heat_dis_2D);
	else
		if paddata
			gray_dil_re(tt,:,:) = gray_dil_2D;
			gray_dis_re(tt,:,:) = gray_dis_2D;
			heat_dil_re(tt,:,:) = heat_dil_2D;
			heat_dis_re(tt,:,:) = heat_dis_2D;
		else
			gray_dil_re(tt,:,:) = horzcat(gray_dil_2D(:,end), gray_dil_2D);
			gray_dis_re(tt,:,:) = horzcat(gray_dis_2D(:,end), gray_dis_2D);
			heat_dil_re(tt,:,:) = horzcat(heat_dil_2D(:,end), heat_dil_2D);
			heat_dis_re(tt,:,:) = horzcat(heat_dis_2D(:,end), heat_dis_2D);
		end
	end
end

clear init_loc_cyl T Z
clear gray_dil gray_dis heat_dil heat_dis gray_dil_2D gray_dis_2D heat_dil_2D heat_dis_2D

%% Loop over all networks
% 'ce' stands for elastic fiber integrity insult (reduction in ce modulus)
% 'ms' stands for mechanosensing (delta coefficient)

for nettype = {'networkA', 'networkB', 'networkC', 'networkD'}%

path = [casenum, '/', char(nettype), '/Results', suffix, '/'];		% Define data path

% True & predicted results for Networks A & B (DeepONet)
if contains(nettype, 'A') || contains(nettype, 'B')
	load([path, 'pred.mat'], 'target_ef', 'target_mech', 'pred_ef', 'pred_mech');

	true_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	true_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	pred_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	pred_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	for tt = 1:50
		if paddata
			true_ce_2D = reshape(target_ef(tt,:),   2*nt+1, 2*nz+1)';
			true_ms_2D = reshape(target_mech(tt,:), 2*nt+1, 2*nz+1)';
			pred_ce_2D = reshape(pred_ef(tt,:),     2*nt+1, 2*nz+1)';
			pred_ms_2D = reshape(pred_mech(tt,:),   2*nt+1, 2*nz+1)';
		else
			true_ce_2D = reshape(target_ef(tt,:),   2*nt, 2*nz+1)';
			true_ms_2D = reshape(target_mech(tt,:), 2*nt, 2*nz+1)';
			pred_ce_2D = reshape(pred_ef(tt,:),     2*nt, 2*nz+1)';
			pred_ms_2D = reshape(pred_mech(tt,:),   2*nt, 2*nz+1)';
		end
		if fliptheta
			true_ce_2D = fliplr([true_ce_2D(:, Tmin+1:2*nt) true_ce_2D(:, 1:Tmin)]);
			true_ms_2D = fliplr([true_ms_2D(:, Tmin+1:2*nt) true_ms_2D(:, 1:Tmin)]);
			pred_ce_2D = fliplr([pred_ce_2D(:, Tmin+1:2*nt) pred_ce_2D(:, 1:Tmin)]);
			pred_ms_2D = fliplr([pred_ms_2D(:, Tmin+1:2*nt) pred_ms_2D(:, 1:Tmin)]);
			true_ce_re(tt,:,:) = horzcat(true_ce_2D(:,end), true_ce_2D);
			true_ms_re(tt,:,:) = horzcat(true_ms_2D(:,end), true_ms_2D);
			pred_ce_re(tt,:,:) = horzcat(pred_ce_2D(:,end), pred_ce_2D);
			pred_ms_re(tt,:,:) = horzcat(pred_ms_2D(:,end), pred_ms_2D);
		else
			if paddata
				true_ce_re(tt,:,:) = true_ce_2D;
				true_ms_re(tt,:,:) = true_ms_2D;
				pred_ce_re(tt,:,:) = pred_ce_2D;
				pred_ms_re(tt,:,:) = pred_ms_2D;
			else
				true_ce_re(tt,:,:) = horzcat(true_ce_2D(:,end), true_ce_2D);
				true_ms_re(tt,:,:) = horzcat(true_ms_2D(:,end), true_ms_2D);
				pred_ce_re(tt,:,:) = horzcat(pred_ce_2D(:,end), pred_ce_2D);
				pred_ms_re(tt,:,:) = horzcat(pred_ms_2D(:,end), pred_ms_2D);
			end
		end
	end
	
	if contains(nettype, 'A')
		A_true_ce_re = true_ce_re;	A_pred_ce_re = pred_ce_re;
		A_true_ms_re = true_ms_re;	A_pred_ms_re = pred_ms_re;
	elseif contains(nettype, 'B')
		B_true_ce_re = true_ce_re;	B_pred_ce_re = pred_ce_re;
		B_true_ms_re = true_ms_re;	B_pred_ms_re = pred_ms_re;
	end
end

clear target_ef target_mech pred_ef pred_mech
clear true_ce_2D true_ms_2D pred_ce_2D pred_ms_2D true_ce_re true_ms_re pred_ce_re pred_ms_re

% True & predicted results for Network C (UNet)
if contains(nettype, 'C')
	load([path, 'pred.mat'], 'test_true', 'test_pred');
	
	true_ce_sq = squeeze(test_true(:,1,:,:));
	true_ms_sq = squeeze(test_true(:,2,:,:));
	pred_ce_sq = squeeze(test_pred(:,1,:,:));
	pred_ms_sq = squeeze(test_pred(:,2,:,:));
	
	C_true_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	C_true_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	C_pred_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	C_pred_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	if fliptheta
		for tt = 1:50
			true_ce_2D = fliplr([squeeze(true_ce_sq(tt,:,Tmin+1:2*nt)) squeeze(true_ce_sq(tt,:,1:Tmin))]);
			true_ms_2D = fliplr([squeeze(true_ms_sq(tt,:,Tmin+1:2*nt)) squeeze(true_ms_sq(tt,:,1:Tmin))]);
			pred_ce_2D = fliplr([squeeze(pred_ce_sq(tt,:,Tmin+1:2*nt)) squeeze(pred_ce_sq(tt,:,1:Tmin))]);
			pred_ms_2D = fliplr([squeeze(pred_ms_sq(tt,:,Tmin+1:2*nt)) squeeze(pred_ms_sq(tt,:,1:Tmin))]);
			if paddata
				C_true_ce_re(tt,:,:) = horzcat(true_ce_2D(:,end), true_ce_2D);
				C_true_ms_re(tt,:,:) = horzcat(true_ms_2D(:,end), true_ms_2D);
				C_pred_ce_re(tt,:,:) = horzcat(pred_ce_2D(:,end), pred_ce_2D);
				C_pred_ms_re(tt,:,:) = horzcat(pred_ms_2D(:,end), pred_ms_2D);
			else
				true_ce_ex = vertcat(true_ce_2D, true_ce_2D(1,:));
				true_ms_ex = vertcat(true_ms_2D, true_ms_2D(1,:));
				pred_ce_ex = vertcat(pred_ce_2D, pred_ce_2D(1,:));
				pred_ms_ex = vertcat(pred_ms_2D, pred_ms_2D(1,:));
				C_true_ce_re(tt,:,:) = horzcat(true_ce_ex(:,end), true_ce_ex);
				C_true_ms_re(tt,:,:) = horzcat(true_ms_ex(:,end), true_ms_ex);
				C_pred_ce_re(tt,:,:) = horzcat(pred_ce_ex(:,end), pred_ce_ex);
				C_pred_ms_re(tt,:,:) = horzcat(pred_ms_ex(:,end), pred_ms_ex);
			end
		end
	else
		if ~paddata
			for tt = 1:50
				true_ce_2D = squeeze(true_ce_sq(tt,:,:));
				true_ms_2D = squeeze(true_ms_sq(tt,:,:));
				pred_ce_2D = squeeze(pred_ce_sq(tt,:,:));
				pred_ms_2D = squeeze(pred_ms_sq(tt,:,:));
				true_ce_ex = vertcat(true_ce_2D, true_ce_2D(1,:));
				true_ms_ex = vertcat(true_ms_2D, true_ms_2D(1,:));
				pred_ce_ex = vertcat(pred_ce_2D, pred_ce_2D(1,:));
				pred_ms_ex = vertcat(pred_ms_2D, pred_ms_2D(1,:));
				C_true_ce_re(tt,:,:) = horzcat(true_ce_ex(:,end), true_ce_ex);
				C_true_ms_re(tt,:,:) = horzcat(true_ms_ex(:,end), true_ms_ex);
				C_pred_ce_re(tt,:,:) = horzcat(pred_ce_ex(:,end), pred_ce_ex);
				C_pred_ms_re(tt,:,:) = horzcat(pred_ms_ex(:,end), pred_ms_ex);
			end
		else
			C_true_ce_re = true_ce_sq;
			C_true_ms_re = true_ms_sq;
			C_pred_ce_re = pred_ce_sq;
			C_pred_ms_re = pred_ms_sq;
		end
	end
end

clear test_true test_pred
clear true_ce_sq true_ms_sq pred_ce_sq pred_ms_sq true_ce_2D true_ms_2D pred_ce_2D pred_ms_2D

% True & predicted results for Network D (LNO)
if contains(nettype, 'D')
	load([path, 'pred.mat'], 'u_true', 'u_pred');
	
	true_ce_sq = squeeze(u_true(:,:,:,1));
	true_ms_sq = squeeze(u_true(:,:,:,2));
	pred_ce_sq = squeeze(u_pred(:,:,:,1));
	pred_ms_sq = squeeze(u_pred(:,:,:,2));
	
	D_true_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	D_true_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	D_pred_ce_re = zeros(50, 2*nz+1, 2*nt+1);
	D_pred_ms_re = zeros(50, 2*nz+1, 2*nt+1);
	if fliptheta
		for tt = 1:50
			true_ce_2D = fliplr([squeeze(true_ce_sq(tt,:,Tmin+1:2*nt)) squeeze(true_ce_sq(tt,:,1:Tmin))]);
			true_ms_2D = fliplr([squeeze(true_ms_sq(tt,:,Tmin+1:2*nt)) squeeze(true_ms_sq(tt,:,1:Tmin))]);
			pred_ce_2D = fliplr([squeeze(pred_ce_sq(tt,:,Tmin+1:2*nt)) squeeze(pred_ce_sq(tt,:,1:Tmin))]);
			pred_ms_2D = fliplr([squeeze(pred_ms_sq(tt,:,Tmin+1:2*nt)) squeeze(pred_ms_sq(tt,:,1:Tmin))]);
			D_true_ce_re(tt,:,:) = horzcat(true_ce_2D(:,end), true_ce_2D);
			D_true_ms_re(tt,:,:) = horzcat(true_ms_2D(:,end), true_ms_2D);
			D_pred_ce_re(tt,:,:) = horzcat(pred_ce_2D(:,end), pred_ce_2D);
			D_pred_ms_re(tt,:,:) = horzcat(pred_ms_2D(:,end), pred_ms_2D);
		end
	else
		if paddata
			D_true_ce_re = true_ce_sq;
			D_true_ms_re = true_ms_sq;
			D_pred_ce_re = pred_ce_sq;
			D_pred_ms_re = pred_ms_sq;
		else
			for tt = 1:50
				true_ce_2D = squeeze(true_ce_sq(tt,:,:));
				true_ms_2D = squeeze(true_ms_sq(tt,:,:));
				pred_ce_2D = squeeze(pred_ce_sq(tt,:,:));
				pred_ms_2D = squeeze(pred_ms_sq(tt,:,:));
				D_true_ce_re(tt,:,:) = horzcat(true_ce_2D(:,end), true_ce_2D);
				D_true_ms_re(tt,:,:) = horzcat(true_ms_2D(:,end), true_ms_2D);
				D_pred_ce_re(tt,:,:) = horzcat(pred_ce_2D(:,end), pred_ce_2D);
				D_pred_ms_re(tt,:,:) = horzcat(pred_ms_2D(:,end), pred_ms_2D);
			end
		end
	end
end

clear test_true test_pred
clear true_ce_sq true_ms_sq pred_ce_sq pred_ms_sq true_ce_2D true_ms_2D pred_ce_2D pred_ms_2D
end

% Save a note structure containing case and options
note = struct('flip_theta', fliptheta, 'pad_data', paddata, 'mesh_size', [1 nt nz], 'case_number', casenum);
clear casenum nettype nt nz Tmin tt fliptheta path suffix paddata
