% Code that allows the user to loop the OTAR simulator and compile the results
% Andrew Neish 2/2/2019
clear
close all
clc

%% Establish run parameters
% Get current directory
my_dir = pwd;

run_param.scheme = 'ECDSA';     % 'TESLA' or 'ECDSA'
run_param.run_sim = 1;  % 1 Run simulator, 0 only generate message generating structure
run_param.save_data = 1;    % 1 save data, 0 do not save data
run_param.disp_on = 0;  % 1 Display current status of code, 0 suppresses output on command line
run_param.freq = 'L5';      % 'L1' or 'L5'
run_param.channel = 'Q';  % 'I' or 'Q'
run_param.num_GUS_sites = 1;  % Use 1 for same level 2 PK between all sites. This dictates how many data PKs will need to be kept track of
run_param.PER = 0.1; % Page error rate, may think about making this into a function of C/N0
run_param.OTAR_min = 0;    % Minimum OTAR length acceptable
run_param.TBA = 2;  % Time between authentication in units of messages
run_param.OTAR_num_vec = round(linspace(1000,20000,100));  % Number of OTAR messages to be generated
run_param.user_loop_vec = round(1);   % Number of times a user is simulated for each 'Start Time'
run_param.plots = {};
w12 = 215.4435;         % Set weight ratio of OMT1 and OMT2 to the rest of the OMTs

% Set number of loops to run sim
run_param.sim_loop = 1;

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


%% Run and loop simulator
Loop_tic = tic;
for k = 1:length(run_param.OTAR_num_vec)
    for j = 1:length(run_param.user_loop_vec)   % Middle loop, loop over different number of users
        for i = 1:run_param.sim_loop    % Inner loop, repeat same sim-length and user loop several times. Use parfor to run loops simultaneously
            
            % Define parameters
            run_param.user_loop = run_param.user_loop_vec(j);
            run_param.OTAR_num = run_param.OTAR_num_vec(k);
            
            % Display which variables are being worked on
            clc
            str = ['Sim Length(', num2str(k), '/', num2str(length(run_param.OTAR_num_vec)), '): ', num2str(run_param.OTAR_num_vec(k)), newline,...
                'Num Users(', num2str(j), '/', num2str(length(run_param.user_loop_vec)), '): ', num2str(run_param.user_loop_vec(j)), newline,...
                'Inner Loop(', num2str(i), '/', num2str(run_param.sim_loop), ')', newline,...
                'Sim Loop Iter: (', num2str((k-1)*length(run_param.user_loop_vec)*run_param.sim_loop + (j-1)*run_param.sim_loop + i), '/', num2str(length(run_param.OTAR_num_vec)*length(run_param.user_loop_vec)*run_param.sim_loop), ')'];
            disp(str)
            
            % Run Sim
            if strcmp(run_param.scheme, 'ECDSA')
                cd([pwd, '/ECDSA'])
                output = run_ECDSA_sim(run_param, output);
            elseif strcmp(run_param.scheme, 'TESLA')
                cd([pwd, '/TESLA'])
                output = run_TESLA_sim(run_param, output);
            end
            
            % Change back to this directory
            cd(my_dir)
            
            %% Record outputs
            Loop_output.sim_length(k).user_loop(j).sim_loop(i).total_average = output.user_results.total.average_time;
            Loop_output.sim_length(k).user_loop(j).sim_loop(i).level2_average = output.user_results.current_auth_PK_time.average_time;
            
        end
    end
end
toc(Loop_tic)
%% Post Process and Plot results
Loop_output = OTAR_loop_post(run_param, Loop_output);
Loop_output = OTAR_loop_plot(run_param, Loop_output);

%% Save results
if run_param.save_data
    % Create name of data file
    str = [run_param.scheme, '_',...
        run_param.freq, '_',...
        run_param.channel, '_',...
        'GUS', num2str(run_param.num_GUS_sites), '_',...
        'PER', num2str(run_param.PER,'%.E'), '_',...
        'TBA', num2str(run_param.TBA), '_',...
        'OTAR_num_vec', num2str(length(run_param.OTAR_num_vec)), '_',...
        'User_loop_vec', num2str(length(run_param.user_loop_vec)), '_',...
        'Sim_loop_vec', num2str(length(run_param.sim_loop)), '_',...
        'Levels', run_param.levelstr];
    
    % Save to data directory
    try
        cd([pwd, '/Data', '/Loops/', str])
    catch
        mkdir([pwd, '/Data', '/Loops/', str])
        cd([pwd, '/Data', '/Loops/', str])
    end
    
    % Save data
    save(str);
    
    % Change back to this directory
    cd(my_dir)
end




