% Loop through different levels and plot results
% Andrew Neish - 01/29/2019
clear
close all
clc

%% Establish run parameters
my_dir = pwd;

run_param.scheme = 'TESLA';     % 'TESLA' or 'ECDSA'
run_param.run_sim = 1;  % 1 Run simulator, 0 only generate message generating structure
run_param.save_data = 1;    % 1 save data, 0 do not save data
run_param.load_data = 0;    % 1 to load data, 0 otherwise
run_param.disp_on = 0;  % 1 Display current status of code, 0 suppresses output on command line
run_param.freq = 'L5';      % 'L1' or 'L5'
run_param.channel = 'I';  % 'I' or 'Q'
run_param.num_GUS_sites = 8;  % Use 1 for same data PK between all sites. This dictates how many data PKs will need to be kept track of
run_param.PER = 0; % Page error rate, may think about making this into a function of C/N0
run_param.OTAR_min = 0;    % Minimum OTAR length acceptable
run_param.TBA = 6;  % Time between authentication in units of messages
run_param.OTAR_num = 1000;  % Number of OTAR messages to be generated
run_param.user_loop = 1;   % Number of times a user is simulated for each 'Start Time'
run_param.plots = {};
run_param.levels_loop_ratio = logspace(0,5,100)'.*0.1;   % Set p1/pall for all runs
if strcmp('TESLA', run_param.scheme)
    w12_w56 = 2;
    run_param.levels_loop = [run_param.levels_loop_ratio, (1/w12_w56)*run_param.levels_loop_ratio, ones(length(run_param.levels_loop_ratio),1)];
elseif strcmp('ECDSA', run_param.scheme)
    run_param.levels_loop = [run_param.levels_loop_ratio, ones(length(run_param.levels_loop_ratio),1)];
end
for i = 1:length(run_param.levels_loop_ratio)   % Make sure there are no exact repeating values
    if length(run_param.levels_loop(i,:)) ~= length(unique(run_param.levels_loop(i,:)))
        run_param.levels_loop(i,:) = run_param.levels_loop(i,:) + 1e-5*rand(1,length(run_param.levels_loop(i,:)));
    end
end

% Initialize waitbar
L_waitbar = waitbar(0, ['Looping Through Levels... Sim Length: ', num2str(run_param.OTAR_num)]);    % Initialize waitbar

if strcmp(run_param.scheme, 'ECDSA')
    data = NaN(length(run_param.levels_loop_ratio), 6);
elseif strcmp(run_param.scheme, 'TESLA')
    data = NaN(length(run_param.levels_loop_ratio), 9);
end

levels_ratio = zeros(length(run_param.levels_loop_ratio),1);

for i = 1:length(run_param.levels_loop_ratio)
    clc
    disp(['Simulating user with level ratio (', num2str(i), '/', num2str(length(run_param.levels_loop)), '): '...
        num2str(run_param.levels_loop_ratio(i))])
    disp(['Current Simulation Length: ', num2str(run_param.OTAR_num)])
    data_flag = NaN;
    
    while isnan(data_flag)
        % Set levels and allocate levels to OMT
        run_param.levels = run_param.levels_loop(i,:); % Set value of the levels
        run_param.levels_norm = run_param.levels./sum(run_param.levels);
        run_param.levels_vec = zeros(31,1);     % Pre-allocate levels to be zero
        run_param.levels_vec(1:2) = run_param.levels_norm(1);    % Sets level to a set of OMT
        if run_param.num_GUS_sites > 1 && strcmp('ECDSA', run_param.scheme)
            run_param.levels_vec([3:8, 16:23, 28:31]) = run_param.levels_norm(2);
        elseif run_param.num_GUS_sites == 1 && strcmp('ECDSA', run_param.scheme)
            run_param.levels_vec([3:8, 28:31]) = run_param.levels_norm(2);
        elseif run_param.num_GUS_sites > 1 && strcmp('TESLA', run_param.scheme)
            run_param.levels_vec(5:6) = run_param.levels_norm(2);
            run_param.levels_vec([3:4, 9:14, 16:31]) = run_param.levels_norm(3);
        elseif run_param.num_GUS_sites == 1 && strcmp('TESLA', run_param.scheme)
            run_param.levels_vec(5:6) = run_param.levels_norm(2);
            run_param.levels_vec([3:4, 9:14, 28:31]) = run_param.levels_norm(3);
        end
        [run_param, output] = set_levels(run_param);
        
        % Because original code needs this...
        if strcmp(run_param.freq,'L1')
            run_param.L1 = 1;
        elseif strcmp(run_param.freq,'L5')
            run_param.L1 = 0;
        end
        if strcmp(run_param.channel,'I')
            run_param.I_channel = 1;
        elseif strcmp(run_param.channel,'Q')
            run_param.I_channel = 0;
        end
        
        % ECDSA parameters
        if strcmp(run_param.scheme, 'ECDSA')
            run_param.level_2_key_length_bits = 224;  % Select data public key length. Must be chosen from NIST curve (P-224, P-256, or P-384)
            run_param.level_1_key_length_bits = 384;  % Select root key length from above NIST curves
            if run_param.I_channel == 0
                run_param.Q_CRC_bits = 0;  % If Q channel, decide how many bits for CRC, usually 24 or 32
            end
        end
        
        % TESLA parameters
        if strcmp(run_param.scheme, 'TESLA')
            run_param.TESLA_key_length_bits = 115;    % TESLA key length
            run_param.TESLA_MAC_length_bits = 30;     % TESLA MAC length
            run_param.salt_length_bits = 30;  % Assume the same salt is used for both fast/slow chains
            run_param.level2_key_length_bits = 224;  % Select level 2 public key length. Must be chosen from NIST curve (P-224, P-256, or P-384)
            run_param.level1_key_length_bits = 384;  % Select level 1 key length from above NIST curves
            if run_param.I_channel == 0
                run_param.Q_CRC_bits = 0;  % If Q channel, decide how many bits for CRC, usually 24 or 32
            end
        end
        
        %% Run Simulator and produce results
        % Run simulator
        if strcmp(run_param.scheme, 'ECDSA')
            cd([pwd, '/ECDSA'])
            output = run_ECDSA_sim(run_param, output);
        elseif strcmp(run_param.scheme, 'TESLA')
            cd([pwd, '/TESLA'])
            output = run_TESLA_sim(run_param, output);
        end
        
        % Change back to this directory
        cd(my_dir)
        
        %% List data gathered from runs
        % Columns:
        % min level 2 PK, ave level 2 PK, max level 2 PK, min total, ave total, max total
        if strcmp(run_param.scheme, 'ECDSA')
            data(i,:) = [output.user_results.current_auth_PK_time.min_time,...
                output.user_results.current_auth_PK_time.average_time,...
                output.user_results.current_auth_PK_time.max_time,...
                output.user_results.total.min_time,...
                output.user_results.total.average_time,...
                output.user_results.total.max_time];
            data_flag = data(i,4);
        elseif strcmp(run_param.scheme, 'TESLA')
            data(i,:) = [output.user_results.current_auth_TESLA_time.min_time,...
                output.user_results.current_auth_TESLA_time.average_time,...
                output.user_results.current_auth_TESLA_time.max_time,...
                output.user_results.current_auth_level2_PK_time.min_time,...
                output.user_results.current_auth_level2_PK_time.average_time,...
                output.user_results.current_auth_level2_PK_time.max_time,...
                output.user_results.total.min_time,...
                output.user_results.total.average_time,...
                output.user_results.total.max_time];
            data_flag = data(i,7);
        end
        
        if isnan(data_flag)
            run_param.OTAR_num = run_param.OTAR_num*2;
            disp(['New sim length: ', num2str(run_param.OTAR_num)])
        end
        
        levels_ratio(i) = output.OMT.p_vec(1)/output.OMT.p_vec(31);
        
        
    end
    
    waitbar(i/length(run_param.levels_loop_ratio), L_waitbar, ['Looping Through Levels ', '(', num2str(i), '/', num2str(length(run_param.levels_loop_ratio)), ')', newline,...
        'Sim Length: ', num2str(run_param.OTAR_num)]);
    
end
close(L_waitbar)    % Close waitbar


%% Plot data
if strcmp(run_param.scheme, 'ECDSA')
    % ECDSA and one GUS
    figure
    loglog(levels_ratio, data(:,1), 'g', 'LineWidth', 0.01)
    hold on
    h1 = loglog(levels_ratio, data(:,2), 'g--', 'LineWidth', 2);
    loglog(levels_ratio, data(:,3), 'g', 'LineWidth', 0.01)
    loglog(levels_ratio, data(:,4),'b', 'LineWidth', 0.01)
    h2 = loglog(levels_ratio, data(:,5),'b--', 'LineWidth', 2);
    loglog(levels_ratio, data(:,6),'b', 'LineWidth', 0.01)
    temp1 = [levels_ratio', fliplr(levels_ratio')];
    temp2 = [data(:,1)', fliplr(data(:,3)')];
    h = fill(temp1, temp2, 'g');
    set(h,'facealpha',.2,'edgealpha',0)
    temp2 = [data(:,4)', fliplr(data(:,6)')];
    h = fill(temp1, temp2, 'b');
    set(h,'facealpha',.2,'edgealpha',0)
    line([levels_ratio(1) levels_ratio(end)], [5*60 5*60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2)
    ylim([30 inf])
    xlim([levels_ratio(1) levels_ratio(end)])
    if run_param.num_GUS_sites == 1
        title('Impact of weighting on message reception - Case 1')
    elseif run_param.num_GUS_sites > 1
        title('Impact of weighting on message reception - Case 2')
    end
    xlabel('Weighting Ratio w_{12}/w_{rem}')
    ylabel('Time to receive set of messages')
    legend([h1, h2], 'Current level 2 PK average', 'All messages average','Location','northwest')
    yticks([1, 60, 5*60, 10*60, 30*60, 3600, 6*3600, 12*3600, 3600*24])
    yticklabels({'1 second', '1 minute', '5 minutes', '10 minutes', '30 minutes', '1 hour', '6 hours', '12 hours', '1 day'})
elseif strcmp(run_param.scheme, 'TESLA')
    % ECDSA and one GUS
    figure
    loglog(levels_ratio, data(:,1), 'g', 'LineWidth', 0.01)
    hold on
    h1 = loglog(levels_ratio, data(:,2), 'g-.', 'LineWidth', 2);
    loglog(levels_ratio, data(:,3), 'g', 'LineWidth', 0.01)
    loglog(levels_ratio, data(:,4),'r', 'LineWidth', 0.01)
    h2 = loglog(levels_ratio, data(:,5),'r-.', 'LineWidth', 2);
    loglog(levels_ratio, data(:,6),'r', 'LineWidth', 0.01)
    loglog(levels_ratio, data(:,7),'b', 'LineWidth', 0.01)
    h3 = loglog(levels_ratio, data(:,8),'b-.', 'LineWidth', 2);
    loglog(levels_ratio, data(:,9),'b', 'LineWidth', 0.01)
    temp1 = [levels_ratio', fliplr(levels_ratio')];
    temp2 = [data(:,1)', fliplr(data(:,3)')];
    h = fill(temp1, temp2, 'g');
    set(h,'facealpha',.2,'edgealpha',0)
    temp2 = [data(:,4)', fliplr(data(:,6)')];
    h = fill(temp1, temp2, 'r');
    set(h,'facealpha',.2,'edgealpha',0)
    temp3 = [data(:,7)', fliplr(data(:,9)')];
    h = fill(temp1, temp3, 'b');
    set(h,'facealpha',.2,'edgealpha',0)
    line([levels_ratio(1) levels_ratio(end)], [5*60 5*60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2)
    ylim([30 inf])
    xlim([levels_ratio(1) levels_ratio(end)])
    if run_param.num_GUS_sites == 1
        title('Impact of weighting on message reception - Case 3')
    elseif run_param.num_GUS_sites > 1
        title('Impact of weighting on message reception - Case 4')
    end
    xlabel('Weighting Ratio w_{12}/w_{rem} (w_{12}/w_{56} = 2)')
    ylabel('Time to receive set of messages')
    legend([h1, h2, h3], 'Current keychains and salt average', 'Current level 2 PK average', 'All messages average','Location','northwest')
    yticks([1, 60, 5*60, 10*60, 30*60, 3600, 6*3600, 12*3600, 3600*24])
    yticklabels({'1 second', '1 minute', '5 minutes', '10 minutes', '30 minutes', '1 hour', '6 hours', '12 hours', '1 day'})
end

%% Save data
if run_param.save_data
    % Create name of data file
    str = [run_param.scheme, '_',...
        run_param.freq, '_',...
        run_param.channel, '_',...
        'GUS', num2str(run_param.num_GUS_sites), '_',...
        'PER', num2str(run_param.PER,'%.E'), '_',...
        'TBA', num2str(run_param.TBA), '_',...
        'OTAR_num', num2str(run_param.OTAR_num), '_',...
        'User_loop', num2str(run_param.user_loop), '_',...
        'Levels_min', num2str(run_param.levels_loop_ratio(1),'%.E'), '_',...
        'Levels_max', num2str(run_param.levels_loop_ratio(end),'%.E'), '_',...
        'Levels_num', num2str(length(run_param.levels_loop_ratio),'%.E'),...
        ];
    
    % Save to data directory
    try
        cd([pwd, '/Data/Levels_Loop/', str])
    catch
        mkdir([pwd, '/Data/Levels_Loop/', str])
        cd([pwd, '/Data/Levels_Loop/', str])
    end
    save(str)
    
    % Change back to this directory
    cd(my_dir)
end














