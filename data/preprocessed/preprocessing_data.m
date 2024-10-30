clc
clear all

numrows = 41;
numclmns = 40;

% Get current folder
topLevelFolder = pwd;
% Get list of all .mat files in the folder
matFiles = dir(fullfile(topLevelFolder, '*.mat'));
numCases = length(matFiles);
U1 = zeros(numCases, numrows,numclmns);  % elastic fiber integraty insult
U2 = zeros(numCases, numrows,numclmns);  % mechanosensing insult
F1 = zeros(numCases, numrows, numclmns); % dilatation
F2 = zeros(numCases, numrows, numclmns); % distensibility


% Loop through each file and load it
for k = 1:numCases
    % Get the file name
    matFileName = fullfile(topLevelFolder, matFiles(k).name);
    
    % Load the .mat file
    data = load(matFileName);
    data_inner = data.data_inner;
    func1 = reshape(data_inner(:,15),[numrows, numclmns]); 
    func2 = reshape(data_inner(:,16),[numrows, numclmns]);
	%%%% David edit %%%%
	F1(k,:,:) = func1/mean([func1(1,:) func1(end,:)]);
    %%%%%%%%%%%%%%%%%%%%
    F2(k,:,:) = (func2-func1)./func1;
    U1(k,:,:) = reshape(data_inner(:,17),[numrows, numclmns]);
    U2(k,:,:) = reshape(data_inner(:,18),[numrows, numclmns]);
end
index = randperm(numCases);
F1_new = F1(index,:,:);
F2_new = F2(index,:,:);
U1_new = U1(index,:,:);
U2_new = U2(index,:,:);

ratio = 0.9;
ntrain = ratio*numCases;
F1_train = F1_new(1:ntrain,:,:);
F2_train = F2_new(1:ntrain,:,:);
F1_test = F1_new(ntrain+1:end,:,:);
F2_test = F2_new(ntrain+1:end,:,:);
U1_train = U1_new(1:ntrain,:,:);
U2_train = U2_new(1:ntrain,:,:);
U1_test = U1_new(ntrain+1:end,:,:);
U2_test = U2_new(ntrain+1:end,:,:);

% folderName = 'preprocessed';
% mkdir(folderName)
save('../mixed_data_heat.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');

%%%%%%%%%%%%%%%% Greyscale images %%%%%%%%%%%%%%%%%
F1min=min(min(min(F1_new))); 
F1max=max(max(max(F1_new))); 
F2min=min(min(min(F2_new)));
F2max=max(max(max(F2_new)));
F1_train =uint8(255*(F1_train-F1min)/(F1max-F1min));
F2_train =uint8(255*(F2_train-F2min)/(F2max-F2min));
F1_test =uint8(255*(F1_test-F1min)/(F1max-F1min));
F2_test =uint8(255*(F2_test-F2min)/(F2max-F2min));

save('Data/mixed_data_grey.mat','U1_train','U2_train','F1_train','F2_train','U1_test','U2_test','F1_test','F2_test');
















