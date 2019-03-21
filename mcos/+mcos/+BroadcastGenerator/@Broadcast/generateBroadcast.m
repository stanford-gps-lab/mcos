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
obj.Weights = weights;

% Assign weights to multiple WeightsVector
[numWeights, ~] = size(obj.Weights);
if (numWeights > 1) && (length(configParameters.PER) > 1)
    error('Cannot loop through multiple PER AND Weights')
elseif (numWeights == 1) && (length(configParameters.PER) > 1)
    configParameters.PERVector = configParameters.PER;
    configParameters.WeightsVector = repmat(obj.Weights, length(configParameters.PER), 1);
elseif (numWeights > 1) && (length(configParameters.PER) == 1)
    configParameters.WeightsVector = obj.Weights;
    configParameters.PERVector = configParameters.PER*ones(numWeights, 1);
end

% Generate BroadcastArray
if (strcmp(obj.Algorithm, 'Hameed-Standard'))
    % Generate broadcast array using algorithm from "Hameed - Efficient
    % algorithms for scheduling data broadcast"
    
    % Generate BroadcastArray
    [obj.BroadcastArray, obj.BroadcastMessageNum] = mcos.internal.generateHameedStandardBroadcast(configParameters, omtConfiguration, iteration);
    
end

end