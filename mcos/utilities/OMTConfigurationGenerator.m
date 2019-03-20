% OMTConfigurationGenerator
% This script is used to generate .mat files with OMTConfigurations
clear; close all; clc;

%% OMTConfiguration Filename
filename = 'ECDSA_RevA';

%% Set the OMT Parameters
% Format: Nx3 cell array, where N are the number of messages defined
% First column: OMT Number as an integer
% Second column: Length of OMT Data in bits as an integer
% Third column: Short description of the OMT as a character string
% 
% Ex: omtConfig = {1, 224, 'ECDSA level 2 public key';...
%                  2, 768, 'ECDSA level 1 signature of level 2 public key';...
%                  ...etc.}
% 
% Notes: - For fields that have no defined bit structure yet, leave 2nd 
%          column as []

% ECDSA_RevA
level2PublicKeyLengthBits = 224;
level1PublicKeyLengthBits = 384;

omtConfig = {...
    1, level2PublicKeyLengthBits, 'ECDSA current level 2 public key';...
    2, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of current level 2 public key';...
    3, 34*2, 'Expiration time of current level 2 public key and level 1 public key, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for both levels of keys.';...
    4, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 3';...
    5, level2PublicKeyLengthBits, 'ECDSA next level 2 public key';...
    6, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 5';...
    7, 34*2, 'Expiration time of next level 2 public key and level 1 public key, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for both levels of keys.';...
    8, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 7';...
    12, level1PublicKeyLengthBits, 'ECDSA level 1 current public key';...
    13, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 12, self-signed public key';...
    14, level1PublicKeyLengthBits, 'ECDSA level 1 next public key';...
    15, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 14';...
    };

% TESLA_RevA

%% Complete sanity check on input values
% Check to make sure that OMTNum are valid and non-repeated
if any(cell2mat(omtConfig(:,1)) < 0)
    error('Only positive integers are valid OTAR Message Type numbers')
end
if any(~isequal(cell2mat(omtConfig(:,1)), floor(cell2mat(omtConfig(:,1)))))
    error('Only positive integers are valid OTAR Message Type numbers')
end
if (length(cell2mat(omtConfig(:,1))) ~= length(unique(cell2mat(omtConfig(:,1)))))
   error('OTAR Message Type numbers must be non-repeating') 
end

%% Save OMTConfiguration File
currentDir = pwd;

% Change path to save data in OMTConfigurationFiles directory
cd ..
cd OMTConfigurationFiles
save(filename, 'omtConfig')     % Save only omtConfig variable
cd(currentDir)







