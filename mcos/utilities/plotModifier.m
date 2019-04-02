% Plot Modifier
% This script allows the user to modify the plot that is currently
% referenced. It is advised to run each section at a time as needed.

%% Plot from loaded file
filename = 'ECDSA-Weighting-Analysis';
load(filename);

%% Plot origin results
mcos.internal.plotOTARResults(configParameters, omtConfiguration, otarSimulator);

%% Modify title, axes, etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot black dashed line
legend('AutoUpdate', 'off')
line(xlim, [5*60 5*60], 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 2)

%% Change Title
title('ECDSA Weighting Analysis Results')

%% Change x axis title
xlabel('Weighting Ratio w_{12}/w_{rem}')

%% Save plot as a png
filename = 'ECDSA Weighting Analysis Results';
print(filename, '-dpng', '-r300')