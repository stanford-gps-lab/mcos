% OMTConfigurationGenerator
% This script is used to generate .mat files with OMTConfigurations
clear; close all; clc;

%% Set the OMT Parameters
% Format: Nx3 cell array, where N are the number of messages defined
% First column: OMT Number as an integer
% Second column: Length of OMT Data in bits as an integer
% Third column: Short description of the OMT as a character string
% Fourth column: List of defined groups of messages
%
% Ex: omtConfig = {1, 224, 'ECDSA level 2 public key';...
%                  2, 768, 'ECDSA level 1 signature of level 2 public key';...
%                  ...etc.}
%
% Notes: - For fields that have no defined bit structure yet, leave 2nd
%          column as []

%% ECDSA_RevA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OMTConfiguration Filename
filename = 'ECDSA_RevA';

level2PublicKeyLengthBits = 224;
level1PublicKeyLengthBits = 384;

% Define first three columns
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

% Define final column for message groupings
omtConfig = [omtConfig,...
    {{'Total', 'Current level 2 public key'};... % 1
    {'Total', 'Current level 2 public key'};... % 2
    {'Total', 'Current expirations'};... % 3
    {'Total', 'Current expirations'};... % 4
    {'Total', 'Next level 2 public key'};... % 5
    {'Total', 'Next level 2 public key'};... % 6
    {'Total', 'Next expirations'};... % 7
    {'Total', 'Next expirations'};... % 8
    {'Total', 'Current level 1 public key'};... % 12
    {'Total', 'Current level 1 public key'};... % 13
    {'Total', 'Next level 1 public key'};... % 14
    {'Total', 'Next level 1 public key'}... % 15
    }];



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
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Past Iterations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ECDSA_RevA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OMTConfiguration Filename
% filename = 'ECDSA_RevA';
% 
% level2PublicKeyLengthBits = 224;
% level1PublicKeyLengthBits = 384;
% 
% % Define first three columns
% omtConfig = {...
%     1, level2PublicKeyLengthBits, 'ECDSA current level 2 public key';...
%     2, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of current level 2 public key';...
%     3, 34*2, 'Expiration time of current level 2 public key and level 1 public key, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for both levels of keys.';...
%     4, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 3';...
%     5, level2PublicKeyLengthBits, 'ECDSA next level 2 public key';...
%     6, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 5';...
%     7, 34*2, 'Expiration time of next level 2 public key and level 1 public key, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for both levels of keys.';...
%     8, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 7';...
%     12, level1PublicKeyLengthBits, 'ECDSA level 1 current public key';...
%     13, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 12, self-signed public key';...
%     14, level1PublicKeyLengthBits, 'ECDSA level 1 next public key';...
%     15, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 14';...
%     };
% 
% % Define final column for message groupings
% omtConfig = [omtConfig,...
%     {{'Total', 'Current level 2 public key'};... % 1
%     {'Total', 'Current level 2 public key'};... % 2
%     {'Total', 'Current level 2 public key expiration'};... % 3
%     {'Total', 'Current level 2 public key expiration'};... % 4
%     {'Total', 'Next level 2 public key'};... % 5
%     {'Total', 'Next level 2 public key'};... % 6
%     {'Total', 'Next level 2 public key expiration'};... % 7
%     {'Total', 'Next level 2 public key expiration'};... % 8
%     {'Total', 'Current level 1 public key'};... % 12
%     {'Total', 'Current level 1 public key'};... % 13
%     {'Total', 'Next level 1 public key'};... % 14
%     {'Total', 'Next level 1 public key'}... % 15
%     }];

%% TESLA_RevA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OMTConfiguration Filename
% filename = 'TESLA_RevA';
% 
% teslaKeyLengthBits = 115;
% teslaSaltLengthBits = 30;
% level2PublicKeyLengthBits = 224;
% level1PublicKeyLengthBits = 384;
% 
% % Define first three columns
% omtConfig = {...
%     1, teslaKeyLengthBits + teslaSaltLengthBits, 'TESLA current keychain root/intermediate key and salt';...
%     2, level2PublicKeyLengthBits*2, 'ECDSA level 2 signature of current TESLA keychain';...
%     3, level2PublicKeyLengthBits, 'ECDSA current level 2 public key';...
%     4, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 3';...
%     5, 34*3, 'Expiration time of current level 1 and level 2 public key and TESLA keychain, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x3 for all keys.';...
%     6, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 5';...
%     9, teslaKeyLengthBits + teslaSaltLengthBits, 'TESLA next keychain root/intermediate key and salt';...
%     10, level2PublicKeyLengthBits*2, 'ECDSA level 2 signature of next TESLA keychain';...
%     11, level2PublicKeyLengthBits, 'ECDSA next level 2 public key';...
%     12, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 11';...
%     13, 34*3, 'Expiration time of next level 1 and level 2 public key and TESLA keychain, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x3 for all keys.';...
%     14, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 13';...
%     28, level1PublicKeyLengthBits, 'ECDSA level 1 current public key';...
%     29, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 28, self-signed public key';...
%     30, level1PublicKeyLengthBits, 'ECDSA level 1 next public key';...
%     31, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 31';...
%     };
% 
% % Define final column for message groupings
% omtConfig = [omtConfig,...
%     {{'Total', 'Current TESLA keychain'};... % 1
%     {'Total', 'Current TESLA keychain'};... % 2
%     {'Total', 'Current level 2 public key'};... % 3
%     {'Total', 'Current level 2 public key'};... % 4
%     {'Total', 'Current expirations'};... % 5
%     {'Total', 'Current expirations'};... % 6
%     {'Total', 'Next TESLA keychain'};... % 9
%     {'Total', 'Next TESLA keychain'};... % 10
%     {'Total', 'Next level 2 public key'};... % 11
%     {'Total', 'Next level 2 public key'};... % 12
%     {'Total', 'Next expirations'};... % 13
%     {'Total', 'Next expirations'};... % 14
%     {'Total', 'Current level 1 public key'};... % 28
%     {'Total', 'Current level 1 public key'};... % 29
%     {'Total', 'Next level 1 public key'};... % 30
%     {'Total', 'Next level 1 public key'};... % 31
%     }];







