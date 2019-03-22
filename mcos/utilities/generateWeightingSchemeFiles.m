% generateWeightingSchemeFiles
% This code generates weighting scheme files in .mat form to be loaded
% during testing.
clear; close all; clc;

%% Set filename
filename = 'Hameed-Standard-ECDSA-Single-Test';

%% Set algorithm to be used
% Options: Hameed-Standard
algorithm = 'Hameed-Standard';

%% Set weights to be used
inputWeights = [10, 1];     % Input weights to be used.
weightAllocation = [{[1 2]}, {[3:8, 12:15]}];   % Allocate where the input weights will be distributed to. The number of cells must be equal to the number of columns of inputWeights.

%% Normalize the weights
weights = mcos.internal.normalizeWeights(inputWeights, weightAllocation);

%% Save results
currentDir = pwd;
% Change to WeightingSchemeFiles directory
cd .. 
cd +mcos/+BroadcastGenerator/weightingSchemeFiles
save(filename, 'algorithm', 'inputWeights', 'weightAllocation', 'weights')
cd(currentDir)
cd ..