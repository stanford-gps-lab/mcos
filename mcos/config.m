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
    per = 0;    % PER - Page Error Rate. Nominally 0.
    minLengthOTARMessage = 0;   % MinLengthOTARMessage [messages] - minimum length that an OTAR message is. Nominally 0.
    tba = 6;    % TBA [s] - Time between authentications. Must be greater than the length of the signature
    simLength = 1000;   % SimLength [OTAR messages] - How many OTAR messages are generated for broadcast
    numUsers = 1;   % NumUsers - Number of users that start demodulating at each time interval. Nominally 1.
    weightingScheme = [];   % WeightingScheme - TODO: WeightingScheme to be defined
    omtConfigurationFile = 'ECDSA_RevA.mat';  % MessageConfiguration - File containing message configuration information.
    broadcastGenerator = [];    % BroadcastGenerator - Which function to call when generating OMT broadcast
    qChannelCRCBits = 0;    % QChannelCRCBits - CRC bits included in the Q channel
    level1PublicKeyLengthBits = 384;   % Level1PublicKeyLengthBits - Length of the level 1 public key in bits
    level2PublicKeyLengthBits = 224;   % Level2PublicKeyLengthBits - Length of the level 2 public key in bits
    % TODO: Make key lengths dependent upon the OMTConfiguration chosen
    
    % TESLA parameters
    teslaKeyLengthBits = 115;   % TESLAKeyLengthBits [bits] - Length of the TESLA keys
    teslaMACLengthBits = 30;    % TESLAMACLengthBits [bits] - Length of the TESLA MAC
    teslaSaltLengthBits = 30;   % TESLASaltLengthBits [bits] - Length of the TESLA salt
    
    
    % Plotting parameters
    plottingParameters = {...
        'Total';                                          % Plots time to get all information
        %     'OMT';                                            % Plots time to get all OMTs individually
        %     'Authenticated current level 2 key';              % Plots time to get authenticated current level 2 key
        %     'Expiration of current keys';                     % Plots time to get expiration of current keys
        %     'Authenticated next level 2 key';                 % Plots time to get authenticated next level 2 key
        %     'Expiration of next keys';                        % Plots time to get expiration of next keys
        %     'All authenticated current level 2 keys';         % Plots time to get all authenticated current level 2 keys, only if NumDiffKeys > 1
        %     'All expiration of current keys';                 % Plots time to get expiration of all current keys, only if NumDiffKeys > 1
        %     'All authenticated next level 2 keys';            % Plots time to get all authenticated level 2 keys, only if NumDiffKeys > 1
        %     'All expiration of next keys';                    % Plots time to get all expiration of next keys, only if NumDiffKeys > 1
        %     'Authenticated private key for next root key';    % Plots time to get authenticated private key for next root key
        %     'Box and whisker';                                % Plots box and whisker plot for all above results except for OMT
        %     'Message sequence plot';                          % Plots message sequence in a stairs plot
        %     'Frequency of OTAR messages';                     % Plots frequency of OTAR message generation, in total, not taking time of each message into account
        %     'Bandwidth percentages'                           % Plots relative time taken by each message
        %
        %     %%% TESLA Only %%%
        %     'Authenticated current TESLA key and salt';       % Plot time to get authenticated TESLA key and salt
        %     'Authenticated current level 2 key';              % Plots time to get authenticated current level 2 key
        %     'Authenticated next TESLA key and salt';          % Plot time to get authenticated next TESLA key and salt
        %     'All authenticated current TESLA keys and salt';  % Plot time to get all authenticated current TESLA keys and salt, only if NumDiffKeys > 1
        %     'All authenticated next TESLA keys and salt';     % Plot time to get all authenticated next TESLA keys and salt, only if NumDiffKeys > 1
        };
else
    plottingParameters = plotStr;
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
    'WeightingScheme', weightingScheme,...
    'OMTConfigurationFile', omtConfigurationFile,...
    'BroadcastGenerator', broadcastGenerator,...
    'QChannelCRCBits', qChannelCRCBits,...
    'Level1PublicKeyLengthBits', level1PublicKeyLengthBits,...
    'Level2PublicKeyLengthBits', level2PublicKeyLengthBits,...
    'TESLAKeyLengthBits', teslaKeyLengthBits,...
    'TESLAMACLengthBits', teslaMACLengthBits,...
    'TESLASaltLengthBits', teslaSaltLengthBits,...
    'PlottingParameters', plottingParameters...
    );
else
    configParameters = mcos.ConfigParameters('PlottingParameters', plottingParameters);
end

end



