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
validPERFn = @(x) (x >= 0) && (x < 1);
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

% WeightingScheme
% validWeightingSchemeFn = @(x) % TODO: make a validWeightingSchemeFn when
% you have chosen how to do WeightingScheme
parser.addParameter('WeightingScheme', [])

% MessageConfiguration
% TODO: make a validMessageConfigurationFn when you have chosen how to do
% MessageConfiguration
parser.addParameter('MessageConfiguration', []) % TODO: Take away '[]' when you have created MessageConfiguration files

% BroadcastGenerator
% TODO: make a validBroadcastGeneratorFn when you have chosen how to do
% BroadcastGenerator
parser.addParameter('BroadcastGenerator', []) % TODO: Take away '[]' when you have created BroadcastGenerator




%% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;






end