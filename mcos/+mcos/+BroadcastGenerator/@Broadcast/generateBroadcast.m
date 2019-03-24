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
switch algorithm
    case 'Hameed-Standard'
        % Generate broadcast array using algorithm from "Hameed - Efficient
        % algorithms for scheduling data broadcast"
        
        % Generate BroadcastArray
        [obj.BroadcastArray, obj.BroadcastMessageNum, obj.RowCells] = mcos.internal.generateHameedStandardBroadcast(configParameters, omtConfiguration);
        
    case 'Hameed-Semi-Rigid'
        % Generate broadcast array using algorithm from "Hameed - Efficient
        % algorithms for scheduling data broadcast". The messages deemed
        % most important have a minimum time between broadcast to ensure
        % that the these messages have a guarunteed broadcast rate.
        [obj.BroadcastArray, obj.BroadcastMessageNum, obj.RowCells] = mcos.internal.generateHameedSemiRigidBroadcast(configParameters, omtConfiguration);
        
    case 'Hameed-Split'
        % Generate broadast array using algorithm from "Hameed - Efficient
        % algorithms for scheduling data broadcast". In this case the
        % messages are split into their submessages and delivered
        % individually according to the algorithm where they do not
        % necessarily need to be sent as one whole message at a time.
        [obj.BroadcastArray, obj.BroadcastMessageNum, obj.RowCells] = mcos.internal.generateHameedSplitBroadcast(configParameters, omtConfiguration);
        
    otherwise
        error('Not a valid algorithm')
end

end