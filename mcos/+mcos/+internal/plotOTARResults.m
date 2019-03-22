function plotOTARResults(configParameters, omtConfiguration, otarSimulator)
% plotOTARResults(configParameters, omtConfiguration, otarSimulator)
%
% Plots the results using charts specified in config.m.

% Useful variables
dim = [0.59, 0.61, 0.3, 0.3]; % Textbox dimensions

% Plot OMT Histograms
if any(strcmp(configParameters.PlottingParameters, 'OMT'))
    plotOMTHistograms(omtConfiguration, otarSimulator, dim)
end

% Plot histograms of OMT groups
if ~isempty(intersect(configParameters.PlottingParameters, omtConfiguration.OMTUniqueGroups))
    plotGroupHistograms(configParameters, otarSimulator, dim)
end

% % Plot the results vs the loop parameter
% if (configParameters.NumIterations > 1)
%     plotLoopParameter(configParameters, otarSimulation)
% end




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

% function plotLoopParameter(configParameters, otarSimulation)
% % Plot results over looped parameters
% 
% % Useful variables
% loopVar = eval(configParameters.LoopVarName);
% 
% figure
% loglog()
% 
% 
% 
% 
% end