% Loop through different C/N_0 and plot results
% Andrew Neish - 01/29/2019
clear all
close all
clc

%% Establish run parameters
my_dir = pwd;

run_param.scheme = 'ECDSA';     % 'TESLA' or 'ECDSA'
run_param.run_sim = 1;  % 1 Run simulator, 0 only generate message generating structure
run_param.save_data = 1;    % 1 save data, 0 do not save data
run_param.load_data = 0;    % 1 to load data, 0 otherwise
run_param.disp_on = 0;  % 1 Display current status of code, 0 suppresses output on command line
run_param.freq = 'L5';      % 'L1' or 'L5'
run_param.channel = 'Q';  % 'I' or 'Q'
run_param.num_GUS_sites = 1;  % Use 1 for same data PK between all sites. This dictates how many data PKs will need to be kept track of
run_param.OTAR_min = 0;    % Minimum OTAR length acceptable
run_param.TBA = 2;  % Time between authentication in units of messages
run_param.OTAR_num = 1000;  % Number of OTAR messages to be generated
run_param.user_loop = 1;   % Number of times a user is simulated for each 'Start Time'
run_param.plots = {};
w12 = 215.4435;         % Set weight ratio of OMT1 and OMT2 to the rest of the OMTs



% Set CN0 values to loop through
run_param.CN0 = linspace(27.2, 31, 100)';
run_param.PER_loop = CN02PER(run_param.CN0, 250); % Page error rate, may think about making this into a function of C/N0
run_param.PER_loop = flip(run_param.PER_loop);

% Set levels and allocate levels to OMT
% Set levels and allocate levels to OMT
if strcmp('TESLA', run_param.scheme)
    w12_w56 = 2;
    run_param.levels = [w12, w12/w12_w56, 1]; % Set value of the levels
elseif strcmp('ECDSA', run_param.scheme)
    run_param.levels = [w12, 1]; % Set value of the levels
end
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

% Initialize waitbar
L_waitbar = waitbar(0, ['Looping Through C/N_0... Sim Length: ', num2str(run_param.OTAR_num)]);    % Initialize waitbar

if strcmp(run_param.scheme, 'ECDSA')
    data = NaN(length(run_param.CN0), 6);
elseif strcmp(run_param.scheme, 'TESLA')
    data = NaN(length(run_param.CN0), 9);
end

for i = 1:length(run_param.PER_loop)
    
    run_param.PER = run_param.PER_loop(i);
    
    clc
    disp(['Simulating user with C/N_0 (', num2str(i), '/', num2str(length(run_param.CN0)), '): '...
        num2str(length(run_param.CN0(i)))])
    disp(['Current Simulation Length: ', num2str(run_param.OTAR_num)])
    data_flag = NaN;
    
    while isnan(data_flag)
        
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
        
        waitbar(i/length(run_param.PER_loop), L_waitbar, ['Looping Through C/N_0 ', '(', num2str(i), '/', num2str(length(run_param.CN0)), ')', newline,...
        'Sim Length: ', num2str(run_param.OTAR_num)]);
        
    end
    
    
    
end
close(L_waitbar)    % Close waitbar

data = flipud(data);

%% Plot data
% ECDSA and one GUS
if strcmp(run_param.scheme, 'ECDSA') && run_param.num_GUS_sites == 1    
% ECDSA and one GUS
    figure
    loglog(run_param.CN0, data(:,1), 'g', 'LineWidth', 0.01)
    hold on
    h1 = loglog(run_param.CN0, data(:,2), 'g--', 'LineWidth', 2);
    loglog(run_param.CN0, data(:,3), 'g', 'LineWidth', 0.01)
    loglog(run_param.CN0, data(:,4),'b', 'LineWidth', 0.01)
    h2 = loglog(run_param.CN0, data(:,5),'b--', 'LineWidth', 2);
    loglog(run_param.CN0, data(:,6),'b', 'LineWidth', 0.01)
    temp1 = [run_param.CN0', fliplr(run_param.CN0')];
    temp2 = [data(:,1)', fliplr(data(:,3)')];
    h = fill(temp1, temp2, 'g');
    set(h,'facealpha',.2,'edgealpha',0)
    temp2 = [data(:,4)', fliplr(data(:,6)')];
    h = fill(temp1, temp2, 'b');
    set(h,'facealpha',.2,'edgealpha',0)
    ylim([30 inf])
    if run_param.num_GUS_sites == 1
        title('Impact of C/N_0 on message reception - Case 1')
    elseif run_param.num_GUS_sites > 1
        title('Impact of C/N_0 on message reception - Case 2')
    end
    xlabel('(C/N_0)_{dB} (dB-Hz)')
    ylabel('Time to receive set of messages')
    legend([h1, h2], 'Current level 2 PK average', 'All messages average','Location','northwest')
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
        'Cn0_min', num2str(run_param.CN0(1),'%.E'), '_',...
        'Cn0_max', num2str(run_param.CN0(end),'%.E'), '_',...
        'Cn0_num', num2str(length(run_param.CN0),'%.E'),...
        ];
    
    % Save to data directory
    try
        cd([pwd, '/Data/Cn0_Loops/', str])
    catch
        mkdir([pwd, '/Data/Cn0_Loops/', str])
        cd([pwd, '/Data/Cn0_Loops/', str])
    end
    save(str)
    
    % Change back to this directory
    cd(my_dir)
end














