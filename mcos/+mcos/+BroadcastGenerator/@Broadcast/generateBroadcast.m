function obj = generateBroadcast(varargin)
% obj = generateBroadcast(varargin)
% 
% Creates a Broadcast object using various argument parameters.

%% Parse inputs
res = parseBroadcast(varargin{:});

% Temporary
obj = 0;




end

%%
function res = parseBroadcast(varargin)
% res = parseBroadcast(varargin)
% 
% Parse the input parameters for Broadcast

%% Parse input data
parser = inputParser;

% Algorithm
validAlgorithmFn = @(x) (strcmp(x, 'Hameed-Standard'));
parser.addParameter('Algorithm', validAlgorithmFn)

% WeightingSchemeFile
validWeightingSchemeFileFn = @(x) (strcmp(x(end-3), '.mat'));
parser.addParameter('WeightingSchemeFile', validWeightingSchemeFileFn)

%% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;


end