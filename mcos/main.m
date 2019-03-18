% Main.m
% 
% This script runs an OTAR study according to the parameters set in 
% config.m. This script allows the user to choose to run a single instance
% of MCOS or loop through different variables for a sensitivity analysis.
% 
% Contact Andrew Neish (amneish@stanford.edu) for questions.
clear; close all; clc;

%% Read run parameters from config.m in the current directory

try 
run('config')
catch ME
    if (strcmp(ME.identifier, 'MATLAB:run:FileNotFound'))
        error('config.m not found. Make sure to have it in the current working directory.')
        
        % TODO: Add conditional statement if path to mcos not found.
    end
    disp(ME.identifier)
end

%% Perform sanity check on run parameters

%% Run Simulator

%% Plot results

%% Save data (if requested)













