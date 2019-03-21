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
validNumDiffKeysFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('NumDiffKeys', 1, validNumDiffKeysFn)

% PER
validPERFn = @(x) (min(x) >= 0) && (max(x) < 1);
parser.addParameter('PER', 0, validPERFn)

% MinLengthOTARMessage
validMinLengthOTARMessageFn = @(x) (floor(x) == x) && (x >= 0);
parser.addParameter('MinLengthOTARMessage', 0, validMinLengthOTARMessageFn)

% TBA
validTBAFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('TBA', validTBAFn)

% SimLength
validSimLengthFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('SimLength', validSimLengthFn)

% NumUsers
validNumUsersFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('NumUsers', 1, validNumUsersFn)

% WeightingSchemeFile
validWeightingSchemeFileFn = @(x) (isempty(x)) || (strcmp(x(end-3:end), '.mat'));
parser.addParameter('WeightingSchemeFile', [], validWeightingSchemeFileFn)

% MessageConfiguration
validOMTConfigurationFileFn = @(x) (strcmp(x(end-3:end), '.mat'));
parser.addParameter('OMTConfigurationFile', validOMTConfigurationFileFn)

% BroadcastGenerator
% TODO: make a validBroadcastGeneratorFn when you have chosen how to do
% BroadcastGenerator
parser.addParameter('BroadcastGenerator', []) % TODO: Take away '[]' when you have created BroadcastGenerator

% QChannelCRCBits
validQChannelCRCBitsFn = @(x) (floor(x) == x) && (x >= 0);
parser.addParameter('QChannelCRCBits', 0, validQChannelCRCBitsFn)

% Level1PublicKeyLengthBits
validLevel1PublicKeyLengthBitsFn = @(x) (x == 224) || (x == 256) || (x == 384);
parser.addParameter('Level1PublicKeyLengthBits', validLevel1PublicKeyLengthBitsFn)

% Level2PublicKeyLengthBits
validLevel2PublicKeyLengthBitsFn = @(x) (x == 224) || (x == 256) || (x == 384);
parser.addParameter('Level2PublicKeyLengthBits', validLevel2PublicKeyLengthBitsFn)

% TESLAKeyLengthBits
validTESLAKeyLengthBitsFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('TESLAKeyLengthBits', validTESLAKeyLengthBitsFn)

% TESLAMACLengthBits
validTESLAMACLengthBitsFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('TESLAMACLengthBits', validTESLAMACLengthBitsFn)

% TESLASaltLengthBits
validTESLASaltLengthBitsFn = @(x) (floor(x) == x) && (x >= 0);
parser.addParameter('TESLASaltLengthBits', validTESLASaltLengthBitsFn)

% NumIterations
validNumIterationsFn = @(x) (floor(x) == x) && (x > 0);
parser.addParameter('NumIterations', 1, validNumIterationsFn)

% PERVector
% validPERVectorFn = @(x) % TODO: Make validPERVectorFn
parser.addParameter('PERVector', 1)

% WeightsVector
% validWeightsVectorFn = @(x) % TODO: Make validWeightsVectorFn
parser.addParameter('WeightsVector', 1)

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