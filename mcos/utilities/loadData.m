% Script to plot data that has already been generated
clear; close all;% clc;

%% Load data
filename = 'ECDSA-Weighting-Analysis';
load(filename);

%% Set Plotting parameters
plotStr = {'Total','Authenticated current level 2 key'};  % Choose plotting choices from config.m

%% Run config.m and change plotting parameters
plotConfig = config(plotStr);

%% Change loaded configuration object
configParameters.PlottingParameters = plotConfig.PlottingParameters;

%% Plot data








