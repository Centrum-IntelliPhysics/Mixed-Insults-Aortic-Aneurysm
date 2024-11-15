
clear; clc;

% Set seed for randperm
if ~exist('seed.mat','file'); seed = rng; save('seed.mat','seed');
else; load('seed.mat'); rng(seed);
end

padflag  = 1;		% 0 or 1	Pad data?
numrows  = 41;		% Number of nodes in axial (z) dimension
numclmns = 40;		% Number of nodes in circumferential (theta) dimension

% Get current folder
topLevelFolder = pwd;

if padflag
% Load coordinates
    load('../new_delta=0000.mat');
    R     = init_loc_cyl(1, 2);
    T_re  = reshape(init_loc_cyl(:,1), numrows, numclmns);
    T_pad = padarray(T_re, [0 1], 'post', 'circular');
    Z_re  = reshape(init_loc_cyl(:,3), numrows, numclmns);
    Z_pad = padarray(Z_re, [0 1], 'post', 'circular');
    
    init_loc_cyl = [reshape(T_pad, numel(T_pad), 1) repmat(R, numel(T_pad), 1) reshape(Z_pad, numel(Z_pad), 1)];
    save('../new_delta=0000_pad.mat', 'init_loc_cyl');
end

% Get list of all .mat files in the folder
matFiles = dir(fullfile(topLevelFolder, 'rnd*.mat'));
numCases = length(matFiles);
U1 = zeros(numCases, numrows, numclmns);		% Elastic fiber integrity insult [0,1]
U2 = zeros(numCases, numrows, numclmns);		% Mechanosensing insult [0,1]
F1 = zeros(numCases, numrows, numclmns);		% Dilatation ~[1 1.6]
F2 = zeros(numCases, numrows, numclmns);		% Distensibility ~[.03 .07]

% Loop through each file
for k = 1:numCases
    % Get the file name
    matFileName = fullfile(topLevelFolder, matFiles(k).name);
    
    % Load the .mat file
    data = load(matFileName);
    data_inner = data.data_inner;
	
	% Reshape to 2D grid
    func1 = reshape(data_inner(:,15),[numrows, numclmns]); 
    func2 = reshape(data_inner(:,16),[numrows, numclmns]);
	F1(k,:,:) = func1/mean([func1(1,:) func1(end,:)]);				% Dilatation: normalize all points using average value at axial boundaries
    F2(k,:,:) = (func2-func1)./func1;								% Distensibility: normalize change in position using initial position
    U1(k,:,:) = reshape(data_inner(:,17),[numrows, numclmns]);		% Elastic fiber integrity insult
    U2(k,:,:) = reshape(data_inner(:,18),[numrows, numclmns]);		% Mechanosensing insult
end

%%%% David addition: padding maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Append first column as last column to enforce left/right boundaries equal
if padflag
	F1_pad = zeros(numCases, numrows, numclmns+1);
	F2_pad = zeros(numCases, numrows, numclmns+1);
	U1_pad = zeros(numCases, numrows, numclmns+1);
	U2_pad = zeros(numCases, numrows, numclmns+1);
	for p = 1:numCases
%         % org = original, ext = tiled in theta, pad = equal pad in z
% 		F1_org        = squeeze(F1(p,:,:));
% 		F1_ext        = [F1_org(:,numclmns/2+1:end) F1_org F1_org(:,1:numclmns/2)];
% 		F1_pad(p,:,:) = [repmat(F1_ext(1,:),floor(numrows/2),1); F1_ext; repmat(F1_ext(end,:),numclmns-floor(numrows/2)-1,1)];
% 		F2_org        = squeeze(F2(p,:,:));
% 		F2_ext        = [F2_org(:,numclmns/2+1:end) F2_org F2_org(:,1:numclmns/2)];
% 		F2_pad(p,:,:) = [repmat(F2_ext(1,:),floor(numrows/2),1); F2_ext; repmat(F2_ext(end,:),numclmns-floor(numrows/2)-1,1)];
% 		U1_org        = squeeze(U1(p,:,:));
% 		U1_ext        = [U1_org(:,numclmns/2+1:end) U1_org U1_org(:,1:numclmns/2)];
% 		U1_pad(p,:,:) = [repmat(U1_ext(1,:),floor(numrows/2),1); U1_ext; repmat(U1_ext(end,:),numclmns-floor(numrows/2)-1,1)];
% 		U2_org        = squeeze(U2(p,:,:));
% 		U2_ext        = [U2_org(:,numclmns/2+1:end) U2_org U2_org(:,1:numclmns/2)];
% 		U2_pad(p,:,:) = [repmat(U2_ext(1,:),floor(numrows/2),1); U2_ext; repmat(U2_ext(end,:),numclmns-floor(numrows/2)-1,1)];
        
        F1_pad(p,:,:) = padarray(squeeze(F1(p,:,:)), [0 1], 'post', 'circular');
        F2_pad(p,:,:) = padarray(squeeze(F2(p,:,:)), [0 1], 'post', 'circular');
        U1_pad(p,:,:) = padarray(squeeze(U1(p,:,:)), [0 1], 'post', 'circular');
        U2_pad(p,:,:) = padarray(squeeze(U2(p,:,:)), [0 1], 'post', 'circular');
	end
	F1 = F1_pad;
	F2 = F2_pad;
	U1 = U1_pad;
	U2 = U2_pad;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Random permutation of data based on seed
index = randperm(numCases);
F1_new = F1(index,:,:);
F2_new = F2(index,:,:);
U1_new = U1(index,:,:);
U2_new = U2(index,:,:);

% Split into training and testing
ratio = 0.9;
ntrain = ratio*numCases;

% Targets
U1_train = U1_new(1:ntrain,:,:);
U2_train = U2_new(1:ntrain,:,:);
U1_test  = U1_new(ntrain+1:end,:,:);
U2_test  = U2_new(ntrain+1:end,:,:);

% Heat maps
F1_train = F1_new(1:ntrain,:,:);
F2_train = F2_new(1:ntrain,:,:);
F1_test  = F1_new(ntrain+1:end,:,:);
F2_test  = F2_new(ntrain+1:end,:,:);

pcolor(squeeze(F1_new(1,:,:))); shading flat; colormap jet;

if ~padflag
	save('../mixed_data_heat.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');
else
	save('../mixed_data_heat_pad.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');
end

% Greyscale maps (normalized to [0 255])
F1min = min(min(min(F1_new)));      % Global minimum of F1
F1max = max(max(max(F1_new)));      % Global maximum of F1
F2min = min(min(min(F2_new)));      % Global minimum of F2
F2max = max(max(max(F2_new)));      % Global maximum of F2
F1_train = uint8(255*(F1_train-F1min)/(F1max-F1min));
F2_train = uint8(255*(F2_train-F2min)/(F2max-F2min));
F1_test  = uint8(255*(F1_test-F1min)/(F1max-F1min));
F2_test  = uint8(255*(F2_test-F2min)/(F2max-F2min));

if ~padflag
	save('../mixed_data_grey.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');
else
	save('../mixed_data_grey_pad.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');
end
