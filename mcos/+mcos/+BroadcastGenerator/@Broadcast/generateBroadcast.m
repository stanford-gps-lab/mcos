function obj = generateBroadcast(weightingSchemeFile)
% obj = generateBroadcast(varargin)
% 
% Creates a Broadcast object using various argument parameters.

% Assign WeightingSchemeFile
obj.WeightingSchemeFile = weightingSchemeFile;

% Load information from the WeightingSchemeFile
currentDir = pwd;
cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
load(obj.WeightingSchemeFile)
cd(currentDir)

% Assign information from loaded file
obj.Algorithm = algorithm;

% Generate BroadcastArray




end