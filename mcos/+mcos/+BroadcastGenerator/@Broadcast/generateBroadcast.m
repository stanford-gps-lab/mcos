function obj = generateBroadcast(configParameters, omtConfiguration, iteration)
% obj = generateBroadcast(weightingSchemeFile)
%
% Generates a broadcast array using information specified in
% weightingSchemeFile and configParameters.

% Assign WeightingSchemeFile
obj.WeightingSchemeFile = configParameters.WeightingSchemeFile;

% Load information from the WeightingSchemeFile
currentDir = pwd;
cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
load(obj.WeightingSchemeFile, 'algorithm', 'weights')
cd(currentDir)

% Assign information from loaded file
obj.Algorithm = algorithm;

% Generate BroadcastArray
if (strcmp(obj.Algorithm, 'Hameed-Standard'))
    % Generate broadcast array using algorithm from "Hameed - Efficient
    % algorithms for scheduling data broadcast"
    
    % Generate BroadcastArray
    broadcastArray = mcos.internal.generateHameedStandardBroadcast(configParameters, weights(iteration, :), omtConfiguration, iteration);
    
end





end