% generateWeightingSchemeFiles
% This code generates weighting scheme files in .mat form to be loaded
% during testing.
clear; close all; clc;

%% Set filename
filename = 'Hameed-Semi-Rigid-ECDSA-100';

%% Set algorithm to be used
% Options: Hameed-Standard, Hameed-Semi-Rigid, Hameed-Split
algorithm = 'Hameed-Semi-Rigid';

%% Set weights to be used
inputWeights = [100, 1];     % Input weights to be used.
weightAllocation = [{[1 2]}, {[3:8, 12:15]}];   % Allocate where the input weights will be distributed to. The number of cells must be equal to the number of columns of inputWeights. 
%% Normalize the weights
weights = mcos.internal.normalizeWeights(inputWeights, weightAllocation);

%% Custom options for different generation algorithms
switch algorithm
    case 'Hameed-Semi-Rigid'
        % maximum time (in authentication frames) between the most crucial
        % OTAR information
        maxFrameLatency = 30;
        crucialMessages = [1 2];
end

%% Save results
currentDir = pwd;
% Change to WeightingSchemeFiles directory
cd ..
cd +mcos/+BroadcastGenerator/weightingSchemeFiles
save(filename)
cd(currentDir)
cd ..

% TODO: Make normalizeWeights not an internal function







