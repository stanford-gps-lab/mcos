function obj = generateBroadcast(configParameters, omtConfiguration)
% obj = generateBroadcast(weightingSchemeFile)
%
% Generates a broadcast array using information specified in
% weightingSchemeFile and configParameters.

% Assign variable
obj.Weights = configParameters.Weights;

% Assign WeightingSchemeFile
obj.WeightingSchemeFile = configParameters.WeightingSchemeFile;

% Load information from the WeightingSchemeFile
currentDir = pwd;
cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
load(obj.WeightingSchemeFile, 'algorithm')
cd(currentDir)

% Assign information from loaded file
obj.Algorithm = algorithm;

% Generate BroadcastArray
if (strcmp(obj.Algorithm, 'Hameed-Standard'))
    % Generate broadcast array using algorithm from "Hameed - Efficient
    % algorithms for scheduling data broadcast"
    
    % Generate BroadcastArray
    [obj.BroadcastArray, obj.BroadcastMessageNum, obj.RowCells] = mcos.internal.generateHameedStandardBroadcast(configParameters, omtConfiguration);
    
end

end