% Plot Modifier
% This script allows the user to modify the plot that is currently
% referenced. It is advised to run each section at a time as needed.

%% Plot from loaded file
filename = 'testData';
load(filename);

%% Plot origin results
mcos.internal.plotOTARResults(configParameters, omtConfiguration, otarSimulator);

%% Modify title, axes, etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot black dashed line
legend('AutoUpdate', 'off')
line(xlim, [5*60 5*60], 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 2)

%% Change Title
title('Time to receive messages vs Message Loss Rate')

%% Change legend sensitivity plots
fig = gcf;
axObjs = fig.Children;
dataObjs = [axObjs.Children];
% legend([dataObjs(4), dataObjs(8), dataObjs(12)], 'Authenticated current TESLA keychain and salt', 'Authenticated current level-2 key', 'All OTAR messages')
legend([dataObjs(4), dataObjs(8)], 'Data Keys (Average Time)', 'All Keys (Average Time)')
legend('Location', 'northwest')

%% Change ylim
ylim([60*2 3600*20])

%% Change y ticks and labels
yticks([60, 5*60, 10*60, 30*60, 60*60])
yticklabels({'1 minute', '5 minutes', '10 minutes', '30 minutes', '1 hour'})

%% Change xlim
xlim([200 2000])

%% Change y axis title
ylabel('Time to receive messages')

%% Change x axis title
xlabel('Message Loss Rate')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save plot as a png
filename = 'Defense-WER-Sensitivity';
print(filename, '-dpng', '-r300')

















