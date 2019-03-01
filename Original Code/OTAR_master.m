% Master code to run OTAR simulator
% Andrew Neish 1/23/2019
clear
close all
clc

%% Load data
% Get current directory
my_dir = pwd;

run_param.load_data = 0;    % 1 to load data, 0 otherwise
if run_param.load_data
    run_param.load_data_str = 'ECDSA_L5_Q_GUS1_PER1E-03_TBA3_OTAR_num1000_User_loop10_Levels90_6_3_1';    % file name to load
    % Search directory for data
    str = [my_dir, '/Data/', run_param.load_data_str];
    cd(str)
    load(run_param.load_data_str)
    cd(my_dir)
    run_param.load_data = 1;
end

%% Establish run parameters
if ~run_param.load_data
    run_param.scheme = 'TESLA';     % 'TESLA' or 'ECDSA'
    run_param.run_sim = 1;  % 1 Run simulator, 0 only generate message generating structure
    run_param.save_data = 1;    % 1 save data, 0 do not save data
    run_param.disp_on = 1;  % 1 Display current status of code, 0 suppresses output on command line
    run_param.freq = 'L5';      % 'L1' or 'L5'
    run_param.channel = 'I';  % 'I' or 'Q'
    run_param.num_GUS_sites = 1;  % Use 1 for same level 2 PK between all sites. This dictates how many data PKs will need to be kept track of
    run_param.PER = 0; % Page error rate, may think about making this into a function of C/N0
    run_param.OTAR_min = 0;    % Minimum OTAR length acceptable
    run_param.TBA = 6;  % Time between authentication in units of messages
    run_param.OTAR_num = 10000;  % Number of OTAR messages to be generated
    run_param.user_loop = 1;   % Number of times a user is simulated for each 'Start Time'
    w12 = 120.4504;         % Set weight ratio of OMT1 and OMT2 to the rest of the OMTs   

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
            run_param.Q_CRC_bits = 0;  % If Q channel, decide how many bits for CRC, usually 24 or 32, 0 for no CRC
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
            run_param.Q_CRC_bits = 0;  % If Q channel, decide how many bits for CRC, usually 24 or 32, 0 for no CRC
        end
    end
end
%% Establish plotting results
%ECDSA parameters
if strcmp(run_param.scheme, 'ECDSA')
    run_param.plots = {...
        'Total';                                        % Plots time to get all information
        %         'OMT';                                          % Plots time to get all OMTs individually
        'Authenticated current level 2 key';            % Plots time to get authenticated current level 2 key
        %         'Expiration of current keys';                   % Plots time to get expiration of current keys
        %         'Authenticated next level 2 key';               % Plots time to get authenticated next level 2 key
        %         'Expiration of next keys';                      % Plots time to get expiration of next keys
        %         'All authenticated current level 2 keys';       % Plots time to get all authenticated current level 2 keys, only if num_GUS_sites > 1
        %         'All expiration of current keys';               % Plots time to get expiration of all current keys, only if num_GUS_sites > 1
        %         'All authenticated next level 2 keys';          % Plots time to get all authenticated level 2 keys, only if num_GUS_sites > 1
        %         'All expiration of next keys';                  % Plots time to get all expiration of next keys, only if num_GUS_sites > 1
        %         'Authenticated private key for next root key';  % Plots time to get authenticated private key for next root key
        %         'Box and whisker';                              % Plots box and whisker plot for all above results except for OMT
        %         'Message sequence plot';                        % Plots message sequence in a stairs plot
        %         'Frequency of OTAR messages';                   % Plots frequency of OTAR message generation, in total, not taking time of each message into account
        %         'Bandwidth percentages'                       % Plots relative time taken by each message
        };
elseif strcmp(run_param.scheme, 'TESLA')
    run_param.plots = {...
        'Total';                                        % Plots time to get all information
        %         'OMT';                                          % Plots time to get all OMTs individually
        'Authenticated current fast/slow keys and salt';% Plot time to get authenticated current fast, slow and salt
        'Authenticated current level 2 key';            % Plots time to get authenticated current level 2 key
        %         'Expiration of current keys';                   % Plots time to get expiration of current keys
        %         'Authenticated next fast/slow keys and salt';% Plot time to get authenticated next fast, slow and salt
        %         'Authenticated next level 2 key';               % Plots time to get authenticated next level 2 key
        %         'Expiration of next keys';                      % Plots time to get expiration of next keys
        %         'All Authenticated current fast/slow keys and salt'; % Plot time to get all authenticated current fast, slow and salt, only if num_GUS_sites > 1
        %         'All authenticated current level 2 keys';       % Plots time to get all authenticated current level 2 keys, only if num_GUS_sites > 1
        %         'All expiration of current keys';               % Plots time to get expiration of all current keys, only if num_GUS_sites > 1
        %         'All Authenticated next fast/slow keys and salt'; % Plot time to get all authenticated next fast, slow and salt, only if num_GUS_sites > 1
        %         'All authenticated next level 2 keys';          % Plots time to get all authenticated level 2 keys, only if num_GUS_sites > 1
        %         'All expiration of next keys';                  % Plots time to get all expiration of next keys, only if num_GUS_sites > 1
        %         'Authenticated private key for next root key';  % Plots time to get authenticated private key for next root key
        %         'Box and whisker';                              % Plots box and whisker plot for all above results except for OMT
        %         'Message sequence plot';                        % Plots message sequence in a stairs plot
        %         'Frequency of OTAR messages';                   % Plots frequency of OTAR message generation, in total, not taking time of each message into account
        %         'Bandwidth percentages'                       % Plots relative time taken by each message
        };
end

%% Run Simulator and produce results
% Run simulator
if ~run_param.load_data
    if strcmp(run_param.scheme, 'ECDSA')
        cd([pwd, '/ECDSA'])
        output = run_ECDSA_sim(run_param, output);
    elseif strcmp(run_param.scheme, 'TESLA')
        cd([pwd, '/TESLA'])
        output = run_TESLA_sim(run_param, output);
    end
end
close all;  % To avoid double plotting...

% Change back to this directory
cd(my_dir)

%% Plot results
if ~isempty(run_param.plots)
    if strcmp(run_param.scheme, 'ECDSA')
        cd([my_dir, '/ECDSA'])
        output = ECDSA_sim_plot(run_param, output);
    elseif strcmp(run_param.scheme, 'TESLA')
        cd([my_dir, '/TESLA'])
        output = TESLA_sim_plot(run_param, output);
    end
end

% Change back to this directory
cd(my_dir)
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
        'Levels', run_param.levelstr];
    
    % Save to data directory
    try
        cd([pwd, '/Data', '/Single_Runs/', str])
    catch
        mkdir([pwd, '/Data', '/Single_Runs/', str])
        cd([pwd, '/Data', '/Single_Runs/', str])
    end
    
    % Save data
    if strcmp(run_param.scheme, 'ECDSA')
        run_param = rmfield(run_param, 'load_data');
        output = rmfield(output, 'ECDSA_sim_plots');
        save(str)
    elseif strcmp(run_param.scheme, 'TESLA')
        run_param = rmfield(run_param, 'load_data');
        output = rmfield(output, 'TESLA_sim_plots');
        save(str)
    end
    
    % Change back to this directory
    cd(my_dir)
end

