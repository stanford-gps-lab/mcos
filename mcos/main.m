% Main.m
%
% This script runs an OTAR study according to the parameters set in
% config.m. This script allows the user to choose to run a single instance
% of MCOS or loop through different variables for a sensitivity analysis.
% Be sure to add mcos to your path. Type 'main' in the command line to run
% simulator. TODO: Citation for MCOS paper here.
%
% Contact Andrew Neish (amneish@stanford.edu) for questions.
clear; close all; clc;

%% Read run parameters from config.m in the current directory

try
    configParameters = config();    % Run config.m
catch ME
    if (strcmp(ME.identifier, 'MATLAB:run:FileNotFound'))
        error('config.m not found. Make sure to have it in the current working directory.')
    end
    disp(ME.identifier) % Display error identifier for debug purposes
end

%% Construct SBAS and OMT messages from OMTConfigurationFile stated in config.m
omtConfiguration = OMTConfigurationGenerator.OMTConfiguration(configParameters);

%% Perform sanity check on run parameters
% Check to make sure that the key lengths in config.m match the loaded 
% OMTConfigurationFile
if (strcmp(configParameters.Scheme, 'ECDSA'))
    if any([...
            configParameters.Level1PublicKeyLengthBits - omtConfiguration.OMTDataLengthBits{2}/2;...
            configParameters.Level2PublicKeyLengthBits - omtConfiguration.OMTDataLengthBits{1};...
            ])
       error('ECDSA keys in config.m must match those in the chosen OMTConfigurationFile') 
    end
elseif (strcmp(configParameters.Scheme, 'TESLA'))
    if any([...
            configParameters.Level1PublicKeyLengthBits - omtConfiguration.OMTDataLengthBits{4}/2;...
            configParameters.Level2PublicKeyLengthBits - omtConfiguration.OMTDataLengthBits{3};...
            configParameters.TESLAKeyLengthBits + configParameters.TESLAMACLengthBits - omtConfiguration.OMTDataLengthBits{1}...
            ])
       error('TESLA parameters in config.m must match those in the chosen OMTConfigurationFile') 
    end
end
% TODO: Make a class for SanityChecks

%% Run Simulator

%% Plot results

%% Save data (if requested)
if configParameters.SaveData
    save('saveData')
end














