function configParameters = config(plotStr)
% This function sets the parameters to be run in the simulation. When the
% simulation is ready, type 'main' into the command line. Make sure that
% you have added mcos to your path

%% Assign configuration parameters to ConfigParameters

if nargin < 1 % Skip if plotData is being called
    % Simulation Parameters
    scheme = 'ECDSA'; % Scheme - 'TESLA' or 'ECDSA'
    saveData = true;   % SaveData - true or false
    frequency = 'L5';   % Frequency - 'L1' or 'L5'
    channel = 'Q';  % Channel - 'I' or 'Q'
    numDiffKeys = 1;    % NumDiffKeys - Number of different keys used to sign data. Nominally 1.
    per = 0;    % PER - Page Error Rate. Nominally 0. Can be an array for sensitivity analyses.
    minLengthOTARMessage = 0;   % MinLengthOTARMessage [messages] - minimum length that an OTAR message is. Nominally 0.
    tba = 2;    % TBA [s] - Time between authentications. Must be greater than the length of the signature
    simLength = 10000;   % SimLength [OTAR messages] - How many OTAR messages are generated for broadcast
    numUsers = 1;   % NumUsers - Number of users that start demodulating at each time interval. Nominally 1.
    weightingSchemeFile = 'Hameed-Semi-Rigid-ECDSA-Test.mat';   % WeightingSchemeFile - Can be an array for sensitivity analyses.
    omtConfigurationFile = 'ECDSA_RevA.mat';  % MessageConfiguration - File containing message configuration information.
    qChannelCRCBits = 0;    % QChannelCRCBits - CRC bits included in the Q channel
    level1PublicKeyLengthBits = 384;   % Level1PublicKeyLengthBits - Length of the level 1 public key in bits
    level2PublicKeyLengthBits = 224;   % Level2PublicKeyLengthBits - Length of the level 2 public key in bits
    partitionBlockSize = 1000;  % PartitionBlockSize - Size of the partitions of the generated broadcast
    displayOn = true;   % DisplayOn - Boolean. Display checkpoints and waitbars
    
    % TESLA parameters
    teslaKeyLengthBits = 115;   % TESLAKeyLengthBits [bits] - Length of the TESLA keys
    teslaMACLengthBits = 30;    % TESLAMACLengthBits [bits] - Length of the TESLA MAC
    teslaSaltLengthBits = 30;   % TESLASaltLengthBits [bits] - Length of the TESLA salt
    
    
    % Plotting parameters
    plottingParameters = {...
        'Total';                                          % Plots time to get all information
        %         'OMT';                                            % Plots time to get all OMTs individually
        'Authenticated current level 2 key';              % Plots time to get authenticated current level 2 key
        %                 'Expiration of current keys';                     % Plots time to get expiration of current keys
        %         'Authenticated next level 2 key';                 % Plots time to get authenticated next level 2 key
        %         'Expiration of next keys';                        % Plots time to get expiration of next keys
        %         'All authenticated current level 2 keys';         % Plots time to get all authenticated current level 2 keys, only if NumDiffKeys > 1
        %         'All expiration of current keys';                 % Plots time to get expiration of all current keys, only if NumDiffKeys > 1
        %         'All authenticated next level 2 keys';            % Plots time to get all authenticated level 2 keys, only if NumDiffKeys > 1
        %         'All expiration of next keys';                    % Plots time to get all expiration of next keys, only if NumDiffKeys > 1
        %         'Authenticated current level 1 key';              % Plots the time to get the current level 1 public key and have it authenticated
        %         'Authenticated next level 1 key';                 % Plots the time to get the next level 1 public key and have it authenticated
        %         'Box and whisker';                                % Plots box and whisker plot for all above results except for OMT
        %         'Message sequence plot';                          % Plots message sequence in a stairs plot
        %         'Frequency of OTAR messages';                     % Plots frequency of OTAR message generation, in total, not taking time of each message into account
        %         'Bandwidth percentages'                           % Plots relative time taken by each message
        %
        %         %% TESLA Only %%%
        %         'Authenticated current TESLA keychain and salt';       % Plot time to get authenticated TESLA key and salt
        %         'Authenticated next TESLA keychain and salt';          % Plot time to get authenticated next TESLA key and salt
        %         'All authenticated current TESLA keys and salt';  % Plot time to get all authenticated current TESLA keys and salt, only if NumDiffKeys > 1
        %         'All authenticated next TESLA keys and salt';     % Plot time to get all authenticated next TESLA keys and salt, only if NumDiffKeys > 1
        };
else
    plottingParameters = plotStr;
end

%% Calculate the number of iterations
numIterations = 1;  % By default, number of iterations is one

% Load weightingSchemeFile here
currentDir = pwd;
cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
temp = load(weightingSchemeFile, 'weights');
cd(currentDir)

% Find how many different sets of weights are included in the
% weightingSchemeFile
weightingScheme = temp;
weights = temp.weights;
clear temp currentDir

% Find all inputs that are doubles. Only variables that should be available
% at this moment should be ones that are going to be in configParameters.
loopVarName = '';
varWhos = struct2cell(whos);
varDouble = varWhos(:, strcmp(varWhos(4,:), 'double'));

% Record the number of different weight sets. IT'S IMPORTANT THAT THIS
% DOESN'T COME BEFORE varWhos.
[numWeights, ~] = size(weights);

% Find the double variable that is an array
loopVarInd = (cellfun(@max, varDouble(2,:)) > 1);
if (numWeights == 1)
    loopVarInd(end) = false;
end
if (sum(loopVarInd) > 1)
    error('Too many variables to loop through. Can only loop through one at a time.')
end

% Define numIterations and the name of the variable that is being looped
% through
if (sum(loopVarInd) == 1)
    numIterations = max(varDouble{2,loopVarInd});
    loopVarName = varDouble{1, loopVarInd};
    loopVarName = setLoopVarName(loopVarName);
end
if (strcmp(loopVarName, 'Weights')) && (numWeights == 1)
    loopVarName = [];
    numIterations = 1;
end

%% Display Status
if displayOn
    disp('Configuring Parameters...')
end

%% Write values to ConfigParameters class
if nargin < 1
    configParameters = mcos.ConfigParameters(...
        'Scheme', scheme,...
        'SaveData', saveData,...
        'Frequency', frequency,...
        'Channel', channel,...
        'NumDiffKeys', numDiffKeys,...
        'PER', per,...
        'MinLengthOTARMessage', minLengthOTARMessage,...
        'TBA', tba,...
        'SimLength', simLength,...
        'NumUsers', numUsers,...
        'WeightingSchemeFile', weightingSchemeFile,...
        'OMTConfigurationFile', omtConfigurationFile,...
        'QChannelCRCBits', qChannelCRCBits,...
        'Level1PublicKeyLengthBits', level1PublicKeyLengthBits,...
        'Level2PublicKeyLengthBits', level2PublicKeyLengthBits,...
        'TESLAKeyLengthBits', teslaKeyLengthBits,...
        'TESLAMACLengthBits', teslaMACLengthBits,...
        'TESLASaltLengthBits', teslaSaltLengthBits,...
        'NumIterations', numIterations,...
        'PartitionBlockSize', partitionBlockSize,...
        'DisplayOn', displayOn,...
        'LoopVarName', loopVarName,...
        'WeightingScheme', weightingScheme,...
        'Weights', weights,...
        'PlottingParameters', plottingParameters...
        );
else
    configParameters = mcos.ConfigParameters('PlottingParameters', plottingParameters);
end


end

function outLoopVarName = setLoopVarName(inLoopVarName)
switch inLoopVarName
    case 'numDiffKeys'
        outLoopVarName = 'NumDiffKeys';
    case 'per'
        outLoopVarName = 'PER';
    case 'minLengthOTARMessage'
        outLoopVarName = 'MinLengthOTARMessage';
    case 'tba'
        outLoopVarName = 'TBA';
    case 'simLength'
        outLoopVarName = 'SimLength';
    case 'numUsers'
        outLoopVarName = 'NumUsers';
    case 'qChannelCRCBits'
        outLoopVarName = 'QChannelCRCBits';
    case 'level1PublicKeyLengthBits'
        outLoopVarName = 'Level1PublicKeyLengthBits';
    case 'level2PublicKeyLengthBits'
        outLoopVarName = 'Level2PublicKeyLengthBits';
    case 'teslaKeyLengthBits'
        outLoopVarName = 'TESLAKeyLengthBits';
    case 'teslaMACLengthBits'
        outLoopVarName = 'TESLAMACLengthBits';
    case 'teslaSaltLengthBits'
        outLoopVarName = 'TESLASaltLengthBits';
    case 'weights'
        outLoopVarName = 'Weights';
    case 'partitionBlockSize'
        outLoopVarName = 'PartitionBlockSize';
    otherwise
        error('No match found for loopVarName')
end

end



