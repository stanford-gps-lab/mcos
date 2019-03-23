function plotOTARResults(configParameters, omtConfiguration, otarSimulator)
% plotOTARResults(configParameters, omtConfiguration, otarSimulator)
%
% Plots the results using charts specified in config.m.

% Useful variables
dim = [0.59, 0.61, 0.3, 0.3]; % Textbox dimensions

if ~(configParameters.NumIterations > 1)
    % Plot OMT Histograms
    if any(strcmp(configParameters.PlottingParameters, 'OMT'))
        plotOMTHistograms(omtConfiguration, otarSimulator, dim)
    end
    
    % Plot histograms of OMT groups
    if ~isempty(intersect(configParameters.PlottingParameters, omtConfiguration.OMTUniqueGroups))
        plotGroupHistograms(configParameters, otarSimulator, dim)
    end
end

% Plot the results vs the loop parameter
if (configParameters.NumIterations > 1)
    plotType = 'loglog';    % TODO: add plotType to config.m
    plotLoopParameter(configParameters, otarSimulator, plotType)
end

end

function plotOMTHistograms(omtConfiguration, otarSimulator, dim)

for i = omtConfiguration.OMTInd
    temp = otarSimulator.OMTTimeResults{end}(:,:,i);
    temp = temp(:);
    figure
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    xlim([0 inf])
    xlabel('seconds')
    str = ['Time to receive OMT', num2str(i)];
    title(str)
    str = {['Average time: ', num2str(otarSimulator.OMTTimeAverages{end}(i)), 's'];...
        ['Mode time: ', num2str(otarSimulator.OMTTimeMode{end}(i)), 's'];...
        ['Min time: ', num2str(otarSimulator.OMTTimeMin{end}(i)), 's'];...
        ['Max time: ', num2str(otarSimulator.OMTTimeMax{end}(i)), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

end

function plotGroupHistograms(configParameters, otarSimulator, dim)

for i = 1:length(configParameters.PlottingParameters)
    indPlot = (strcmp(configParameters.PlottingParameters{i}, otarSimulator.OMTUniqueGroups));
    if ~any(indPlot)
        return; % Return if plot not available
    end
    temp = otarSimulator.GroupTimeResults{end}{indPlot};
    temp = temp(:);
    figure
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    xlim([0 inf])
    xlabel('Seconds')
    title(configParameters.PlottingParameters{i});
    str = {['Average time: ', num2str(otarSimulator.GroupTimeAverages{end}{indPlot}), 's'];...
        ['Mode time: ', num2str(otarSimulator.GroupTimeMode{end}{indPlot}), 's'];...
        ['Min time: ', num2str(otarSimulator.GroupTimeMin{end}{indPlot}), 's'];...
        ['Max time: ', num2str(otarSimulator.GroupTimeMax{end}{indPlot}), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end


end

function plotLoopParameter(configParameters, otarSimulator, plotType)
% Plot results over looped parameters

% Useful variables
loopVarName = eval('configParameters.LoopVarName');
eval(['loopVar = configParameters.', loopVarName, ';'])

if (strcmp(loopVarName, 'Weights'))
    % Load weightingSchemeFile here
    currentDir = pwd;
    cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
    temp = load(configParameters.WeightingSchemeFile, 'inputWeights');
    cd(currentDir)
    loopVar = temp.inputWeights(:,1); % It's important that inputWeights varies by row
end

% Make sure loopVar is a column vector
[temp, ~] = size(loopVar);
if temp == 1
    loopVar = loopVar';
end

hi = [];
figure
for i = 1:length(configParameters.PlottingParameters)
    indPlot = (strcmp(configParameters.PlottingParameters{i}, otarSimulator.OMTUniqueGroups));
    if ~any(indPlot)
        return; % Return if plot not available
    end
    
    tempAverage = getArray(otarSimulator.GroupTimeAverages, indPlot);
    tempMax = getArray(otarSimulator.GroupTimeMax, indPlot);
    tempMin = getArray(otarSimulator.GroupTimeMin, indPlot);
    switch plotType
        case 'loglog'
            htemp = loglog(loopVar, tempAverage, '--', 'LineWidth', 2);
            hi = [hi, htemp];
            hold on
            loglog(loopVar, tempMax, '--', 'color', get(htemp, 'color'), 'LineWidth', 0.01)
            loglog(loopVar, tempMin, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
        case 'semilogx'
            htemp = semilogx(loopVar, tempAverage, '--', 'LineWidth', 2);
            hi = [hi, htemp];
            hold on
            semilogx(loopVar, tempMax, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
            semilogx(loopVar, tempMin, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
        case 'semilogy'
            htemp = semilogy(loopVar, tempAverage, '--', 'LineWidth', 2);
            hi = [hi, htemp];
            hold on
            semilogy(loopVar, tempMax, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
            semilogy(loopVar, tempMin, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
        otherwise
            htemp = plot(loopVar, tempAverage, '--', 'LineWidth', 2);
            hi = [hi, htemp];
            hold on
            plot(loopVar, tempMax, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
            plot(loopVar, tempMin, '--', 'color', get(htemp, 'color'),  'LineWidth', 0.01)
    end
    idx = loopVar > 0 & tempMin > 0 & tempMax > 0;  % Eliminate negative numbers and zeros
    temp1 = [loopVar(idx)', fliplr(loopVar(idx)')];
    temp2 = [tempMin(idx)', fliplr(tempMax(idx)')];
    h = fill(temp1, temp2, get(htemp, 'color'));
    set(h,'facealpha',0.2,'edgealpha',0)
end
legend(hi, configParameters.PlottingParameters, 'Location', 'northwest')
ylim([0 inf])
title(['Loop over ', loopVarName])
xlabel(loopVarName)
ylabel('Time to receive set of messages')
% legend(hi, )
yticks([1, 60, 5*60, 10*60, 30*60, 3600, 6*3600, 12*3600, 3600*24])
yticklabels({'1 second', '1 minute', '5 minutes', '10 minutes', '30 minutes', '1 hour', '6 hours', '12 hours', '1 day'})



end

function funOut = getArray(funIn, indPlot)
% This function creates arrays for plotting. Must be done in a for loop
% unfortunately.

% Preallocate
funOut = NaN(length(funIn), 1);

% For loop and get funOut
for i = 1:length(funOut)
    funOut(i) = funIn{i}{indPlot};
end



end









