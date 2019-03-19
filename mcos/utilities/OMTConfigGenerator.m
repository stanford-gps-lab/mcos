% OMTConfigurationGenerator
% This script is used to generate .mat files with OMTConfigurations
clear; close all; clc;

%% Set the OMT Parameters
% Format: Nx3 cell array, where N are the number of messages defined
% First column: OMT Number as an integer
% Second column: Length of OMT Data in bits as an integer
% Third column: Short description of the OMT as a character string
% 
% Ex: omtConfig = {1, 224, 'ECDSA level 2 public key';...
%                  2, 768, 'ECDSA level 1 signature of level 2 public key';...
%                  ...etc.}

level2PublicKeyLengthBits = 224;
level1PublicKeyLengthBits = 384;

omtConfig = {...
    1, level2PublicKeyLengthBits, 'ECDSA current level 2 public key';...
    2, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of current level 2 public key';...
    3, 34*2, 'Expiration time of current level 2 public key and level 1 public key, 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for both levels of keys.';...
    4, level1PublicKeyLengthBits*2, 'ECDSA level 1 signature of OMT 3';...
    5, level2PublicKeyLengthBits, 'ECDSA next level 2 public key';...
    6, level1PublicKeyLengthBits*2, ''
    };



