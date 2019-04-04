% Plot Modifier
% This script allows the user to modify the plot that is currently
% referenced. It is advised to run each section at a time as needed.

%% Plot from loaded file
filename = 'ECDSA-Split';
load(filename);

%% Plot origin results
mcos.internal.plotOTARResults(configParameters, omtConfiguration, otarSimulator);

%% Modify title, axes, etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot black dashed line
legend('AutoUpdate', 'off')
line(xlim, [5*60 5*60], 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 2)

%% Change Title
title('ECDSA PFQ-Semi-Rigid Authenticated current level 2 key')

%% Change ylim
ylim([0 .7])

%% Change xlim
xlim([20 80])

%% Change x axis title
xlabel('Page Error Rate (PER)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save plot as a png
filename = 'ECDSA PFQ-Semi-Rigid Level 2 Results';
print(filename, '-dpng', '-r300')