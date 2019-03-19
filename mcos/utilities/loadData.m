% Script to plot data that has already been generated
clear; close all;% clc;

%% Load data
filename = 'saveData';
load(filename);

%% Set Plotting parameters
plotStr = {'Total','OMT'};  % Choose plotting choices from config.m

%% Run config.m and change plotting parameters
plotConfig = config(plotStr);

%% Change loaded configuration object
configParameters.PlottingParameters = plotConfig.PlottingParameters;

%% Plot data








