function res = parseConfig(varargin)
% Parse the ConfigParameters class input

%% Parse input data
parser = inputParser;

% Scheme
validSchemeFn = @(x) (strcmp(x, 'TESLA')) || (strcmp(x, 'ECDSA'));
parser.addParameter('Scheme', validSchemeFn)

% SaveData
validSaveDataFn = @(x) (x == 0) || (x == 1);
parser.addParameter('SaveData', 0, validSaveDataFn)

% Frequency
validFrequencyFn = @(x) (strcmp(x, 'L1')) || (strcmp(x, 'L5'));
parser.addParameter('Frequency', validFrequencyFn)

% Channel
validChannelFn = @(x) (strcmp(x, 'I')) || (strcmp(x, 'Q'));
parser.addParameter('Channel', validChannelFn)

% NumDiffKeys
parser.addParameter('NumDiffKeys', 1)

% MessageAuthenticationLength
parser.addParameter('MessageAuthenticationLength', false);

% PER
parser.addParameter('PER', 0)

% MinLengthOTARMessage
parser.addParameter('MinLengthOTARMessage', 0)

% TBA
parser.addParameter('TBA', [])

% SimLength
parser.addParameter('SimLength', [])

% NumUsers
parser.addParameter('NumUsers', 1)

% WeightingSchemeFile
validWeightingSchemeFileFn = @(x) (isempty(x)) || (strcmp(x(end-3:end), '.mat'));
parser.addParameter('WeightingSchemeFile', [], validWeightingSchemeFileFn)

% MessageConfiguration
validOMTConfigurationFileFn = @(x) (strcmp(x(end-3:end), '.mat'));
parser.addParameter('OMTConfigurationFile', validOMTConfigurationFileFn)

% QChannelCRCBits
parser.addParameter('QChannelCRCBits', 0)

% Level1PublicKeyLengthBits
parser.addParameter('Level1PublicKeyLengthBits', [])

% Level2PublicKeyLengthBits
parser.addParameter('Level2PublicKeyLengthBits', [])

% Level1SignatureLengthBits
parser.addParameter('Level1SignatureLengthBits', [])

% Level2SignatureLengthBits
parser.addParameter('Level2SignatureLengthBits', [])

% TESLAKeyLengthBits
parser.addParameter('TESLAKeyLengthBits', [])

% TESLAMACLengthBits
parser.addParameter('TESLAMACLengthBits', [])

% TESLASaltLengthBits
parser.addParameter('TESLASaltLengthBits', [])

% NumIterations
validNumIterationsFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('NumIterations', 1, validNumIterationsFn)

% PartitionBlockSize
validPartitionBlockSizeFn = @(x) (x > 0);
parser.addParameter('PartitionBlockSize', 1000, validPartitionBlockSizeFn)

% DisplayOn
validDisplayOnFn = @(x) (islogical(x));
parser.addParameter('DisplayOn', true, validDisplayOnFn)

% LoopVarName
parser.addParameter('LoopVarName', [])

% WeightingScheme
parser.addParameter('WeightingScheme', [])

% Weights
parser.addParameter('Weights', [])

% PlottingParameters
validPlottingParametersFn = @(x) isa(x, 'cell');
parser.addParameter('PlottingParameters', {}, validPlottingParametersFn)


%% Run parser and set results
try
    parser.parse(varargin{:})
catch
    error('Error while parsing inputs from config.m')
end
res = parser.Results;






end