% Master code to run OTAR simulator
% Andrew Neish 1/23/2019
clear all
close all
clc
format short

%% Establish run parameters
my_dir = pwd;

run_param.scheme = 'ECDSA';     % 'TESLA' or 'ECDSA'
run_param.run_sim = 1;  % 1 Run simulator, 0 only generate message generating structure
run_param.save_data = 1;    % 1 save data, 0 do not save data
run_param.disp_on = 0;  % 1 Display current status of code, 0 suppresses output on command line
run_param.freq = 'L5';      % 'L1' or 'L5'
run_param.channel = 'Q';  % 'I' or 'Q'
run_param.num_GUS_sites = 1;  % Use 1 for same data PK between all sites. This dictates how many data PKs will need to be kept track of
run_param.PER = 0; % Page error rate, may think about making this into a function of C/N0
run_param.OTAR_min = 0;    % Minimum OTAR length acceptable
run_param.TBA = 2;  % Time between authentication in units of messages
run_param.user_loop = 1;   % Number of times a user is simulated for each 'Start Time'
run_param.plots = {};

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

%% Optimization parameters
res_lim = 1e-3;     % Residual difference to qualify as converged
count_max = 100; % Maximum count before quitting out of optimization
C_wall = 1e9;   % Punish solutions that do not get all values. Meant to influence the sim length parameters
opt_length = 100;     % How many optimization runs to run
min_sim_length = 500;   % Minimum length to prevent convergence on a non-realistic value

alpha = 1;
gamma = 2;
rho = 1/2;
sigma = 1/2;

% Cost Function
% Cost param: min_level_2, ave_level_2, min_total, ave_total
Cnum = [12*3600/30, 12*3600/60, 12, 1, run_param.TBA];
Cost = @(Cnum, cost_param, sim_length) dot(Cnum(1:end-1), cost_param) + Cnum(end)*sim_length;

% Initialize optimization arrays
opt_results.Cost = NaN(opt_length,1);
opt_results.candidate = zeros(5, opt_length);
opt_results.level2_ave_time = zeros(opt_length,1);
opt_results.level2_min_time = zeros(opt_length,1);
opt_results.total_ave_time = zeros(opt_length,1);
opt_results.total_min_time = zeros(opt_length,1);
opt_results.sim_length = zeros(opt_length,1);
opt_results.sim_stop = zeros(opt_length,1);
opt_results.x0 = cell(opt_length,1);

% Initialize the table
table_fig = figure('Name', 'Results so far...', 'NumberTitle', 'off');
table_labels = {'Cost', 'level2_min_time', 'level2_ave_time', 'total_min_time', 'total_ave_time', 'sim_length', 'sim_stop'};
input('Press Enter...')     % To give the user time to move the table figure over

% Initialize guesses
% First four columns are first four levels for p. Last column is simulation length
% x0 = [100, 2, 3, 1, 500;...
%     19.1128, 1, 2, 3, 600;...
%     500, 1, 5, 4, 700;...
%     1000, 6, 7, 8, 800;...
%     1, 3, 7, 10, 900;...
%     200, 3, 5, 7, 1000];

for opt_count = 1:opt_length
    residual = inf;
    
    x0 = [100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)]);...
        100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)]);...
        100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)]);...
        100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)]);...
        100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)]);...
        100*rand, 10*rand, 10*rand, 10*rand, max([min_sim_length, round(1000*rand)])];
    x = x0'    % Better to work with individual x's as columns
    count = 0;
    x_replace = ones(length(x),1);
    
    while residual > res_lim
        count = count + 1;
        disp(['Iteration: ', num2str(count)])
        
        %% For loop for each test point
        for i = 1:length(x)
            if x_replace(i)
                
                disp(['Calculating cost of x_', num2str(i)])
                
                % Set levels
                run_param.levels = x(1:end-1,i);  % Set parameter levels
                run_param.levels_norm = run_param.levels./sum(run_param.levels);
                run_param.levels_vec = zeros(31,1);     % Pre-allocate levels to be zero
                run_param.levels_vec(1:2) = run_param.levels_norm(1);    % Sets level to a set of OMT
                run_param.levels_vec(3:4) = run_param.levels_norm(2);   % Sets level to a set of OMT
                run_param.levels_vec(5:8) = run_param.levels_norm(3);   % Sets level to a set of OMT
                run_param.levels_vec(30:31) = run_param.levels_norm(4);   % Sets level to a set of OMT
                [run_param, output] = set_levels(run_param);
                run_param.OTAR_num = x(end, i);  % Number of OTAR messages to be generated
                
                %% Run Simulator and produce results
                % Run simulator
                if strcmp(run_param.scheme, 'ECDSA')
                    cd([pwd, '/ECDSA'])
                    output = run_ECDSA_sim(run_param);
                elseif strcmp(run_param.scheme, 'TESLA')
                    cd([pwd, '/TESLA'])
                    output = run_TESLA_sim(run_param);
                end
                
                % Change back to this directory
                cd(my_dir)
                
                % Calculate cost function
                cost_param = [output.user_results.current_auth_PK_time.min_time, output.user_results.current_auth_PK_time.average_time, output.user_results.total.min_time, output.user_results.total.average_time];
                C(count, i) = Cost(Cnum, cost_param, x(end, i));
                if isnan(C(count,i))
                    C(count,i) = C_wall;
                end
            else
                % No need to recalculate cost function if it's already been done in a previous iteration
                C(count, i) = C(count-1, i);
            end
        end
        
        %% Order values
        [temp, temp_i] = sort(C(count, :));
        C(count, :) = temp;
        x = x(:, temp_i);
        
        % Display candidates and cost function
        disp('Candidates: ')
        disp(x)
        disp('Cost Difference: ')
        disp(C(count, :) - C(count, 1))
        
        %% Calculate residual
        if count ~= 1
            residual = max(abs(C(count, :) - C(count - 1, :)));
            disp(['Residual: ', num2str(residual)])
            if residual < res_lim
                continue
            end
            
            % Plot residuals as they are occuring
            addpoints(h, count, residual);
            axis([0 count_max 0 10*residual])
            title(['Cost Function Residual, Iteration: ', num2str(opt_count)])
            drawnow
            
            % Break if count > count max
            if count > count_max
                continue
            end
            
            % Throw error if NaNs in Cost function
            if sum(isnan(C(count,:))) == length(x)
                error('NaN in cost function. Check outputs and see if OTAR_num long enough...')
            end
            
        else
            res_figure = figure;
            h = animatedline;
            xlabel('Iteration')
            ylabel('Residual')
        end
        
        %% Calculate the centroid of all points except x_n+1
        x_centroid = abs(mean(x(:, 1:end-1),2));
        
        %% Reflection
        xr = abs(x_centroid + alpha*(x_centroid - x(:, end)));
        xr(end) = max([min_sim_length, round(xr(end))]);
        
        % Compute cost function of reflected point
        run_param.levels = xr(1:end-1);
        run_param = set_levels(run_param);
        run_param.OTAR_num = xr(end);  % Number of OTAR messages to be generated
        
        % Run simulator
        if strcmp(run_param.scheme, 'ECDSA')
            cd([pwd, '/ECDSA'])
            output = run_ECDSA_sim(run_param);
        elseif strcmp(run_param.scheme, 'TESLA')
            cd([pwd, '/TESLA'])
            output = run_TESLA_sim(run_param);
        end
        % Change back to this directory
        cd(my_dir)
        
        % Calculate cost function
        cost_param = [output.user_results.current_auth_PK_time.min_time, output.user_results.current_auth_PK_time.average_time, output.user_results.total.min_time, output.user_results.total.average_time];
        Cr = Cost(Cnum, cost_param, xr(end));
        if isnan(Cr)
            Cr = C_wall;
        end
        
        if Cr < C(count, end) && Cr >= C(count, 1)
            x(:, end) = xr;
            x_replace = zeros(length(x),1); x_replace(length(x)) = 1;   % Mark which x needs to recalculate new cost function
            disp('Reflection')
            continue
        elseif Cr < C(count, 1) % Expansion
            %% Expansion
            xe = abs(x_centroid + gamma*(xr - x_centroid));
            xe(end) = max([min_sim_length, round(xe(end))]);
            
            % Compute cost function of expanded point
            run_param.levels = xe(1:end-1);
            run_param = set_levels(run_param);
            run_param.OTAR_num = xe(end);  % Number of OTAR messages to be generated
            
            % Run simulator
            if strcmp(run_param.scheme, 'ECDSA')
                cd([pwd, '/ECDSA'])
                output = run_ECDSA_sim(run_param);
            elseif strcmp(run_param.scheme, 'TESLA')
                cd([pwd, '/TESLA'])
                output = run_TESLA_sim(run_param);
            end
            % Change back to this directory
            cd(my_dir)
            
            % Calculate cost function
            cost_param = [output.user_results.current_auth_PK_time.min_time, output.user_results.current_auth_PK_time.average_time, output.user_results.total.min_time, output.user_results.total.average_time];
            Ce = Cost(Cnum, cost_param, xe(end));
            if isnan(Ce)
                Ce = C_wall;
            end
            
            if Ce < Cr
                x(:,end) = xe;
                x_replace = zeros(length(x),1); x_replace(length(x)) = 1;   % Mark which x needs to recalculate new cost function
                disp('Expansion')
                continue
            else
                x(:,end) = xr;
                x_replace = zeros(length(x),1); x_replace(length(x)) = 1;   % Mark which x needs to recalculate new cost function
                disp('Reflection -> Expansion')
                continue
            end
            
        else
            %% Contraction and perhaps shrink
            xc = abs(x_centroid + rho*(x(:,end) - x_centroid));
            xc(end) = max([min_sim_length, round(xc(end))]);
            
            % Compute cost function of contracted point
            run_param.levels = xc(1:end-1);
            run_param = set_levels(run_param);
            run_param.OTAR_num = xc(end);  % Number of OTAR messages to be generated
            
            % Run simulator
            if strcmp(run_param.scheme, 'ECDSA')
                cd([pwd, '/ECDSA'])
                output = run_ECDSA_sim(run_param);
            elseif strcmp(run_param.scheme, 'TESLA')
                cd([pwd, '/TESLA'])
                output = run_TESLA_sim(run_param);
            end
            % Change back to this directory
            cd(my_dir)
            
            % Calculate cost function
            cost_param = [output.user_results.current_auth_PK_time.min_time, output.user_results.current_auth_PK_time.average_time, output.user_results.total.min_time, output.user_results.total.average_time];
            Cc = Cost(Cnum, cost_param, xc(end));
            if isnan(Cc)
                Cc = C_wall;
            end
            
            if Cc < C(count, end)
                x(:,end) = xc;
                x_replace = zeros(length(x),1); x_replace(length(x)) = 1;   % Mark which x needs to recalculate new cost function
                disp('Contraction')
                continue
            else
                for i = 2:length(x)
                    x(:,i) = abs(x(:,1) + sigma*(x(:,i) - x(:,1)));
                    x(end,i) = max([min_sim_length, round(x(end,i))]);
                    x_replace = ones(length(x),1); x_replace(1) = 0;   % Mark which x needs to recalculate new cost function
                end
                disp('Shrink')
                continue
            end
        end
    end
    % Finish plot
    addpoints(h, count, residual);
    drawnow
    close(res_figure)
    
    %% Get parameters for optimal configuration
    run_param.levels = x(1:end-1,1);  % Set parameter levels
    run_param = set_levels(run_param);
    run_param.OTAR_num = x(end,1);  % Number of OTAR messages to be generated
    
    %% Run Simulator and produce results
    % Run simulator
    if strcmp(run_param.scheme, 'ECDSA')
        cd([pwd, '/ECDSA'])
        output = run_ECDSA_sim(run_param);
    elseif strcmp(run_param.scheme, 'TESLA')
        cd([pwd, '/TESLA'])
        output = run_TESLA_sim(run_param);
    end
    
    % Change back to this directory
    cd(my_dir)
    
    %% Record Optimal results
    opt_results.Cost(opt_count) = C(end,1);
    opt_results.candidate(:,opt_count) = x(:,1);
    opt_results.level2_ave_time(opt_count) = output.user_results.current_auth_PK_time.average_time;
    opt_results.level2_min_time(opt_count) = output.user_results.current_auth_PK_time.min_time;
    opt_results.total_ave_time(opt_count) = output.user_results.total.average_time;
    opt_results.total_min_time(opt_count) = output.user_results.total.min_time;
    opt_results.sim_length(opt_count) = x(end,1);
    if count > count_max
        opt_results.sim_stop(opt_count) = 1;
    end
    opt_results.x0{opt_count} = x0;
    
    % Sort opt_results
    [temp, temp_I] = sort(opt_results.Cost);
    opt_results.Cost = temp;
    opt_results.candidate = opt_results.candidate(:,temp_I);
    opt_results.level2_ave_time = opt_results.level2_ave_time(temp_I);
    opt_results.level2_min_time = opt_results.level2_min_time(temp_I);
    opt_results.total_ave_time = opt_results.total_ave_time(temp_I);
    opt_results.total_min_time = opt_results.total_min_time(temp_I);
    opt_results.sim_length = opt_results.sim_length(temp_I);
    opt_results.sim_stop = opt_results.sim_stop(temp_I);
    
    % Create table that is updated continuously
    table_data = [opt_results.Cost, opt_results.level2_min_time, opt_results.level2_ave_time, opt_results.total_min_time, opt_results.total_ave_time, opt_results.sim_length, opt_results.sim_stop];
    uit = uitable(table_fig, 'Data', table_data);
    uit.Position(3) = uit.Extent(3);
    uit.OuterPosition(3) = uit.InnerPosition(3) + 100;
    uit.ColumnName = table_labels;
end

% x0 only sorted in the end
opt_results.x0 = opt_results.x0{temp_I};

%% Display results on command line
format long
disp('Optimal Candidate: ')
disp(x(:,1)')
disp('Final Cost: ')
disp(C(count,1))
disp(['Average time to get authenticated level 2 key: ', num2str(output.user_results.current_auth_PK_time.average_time), ' seconds'])
disp(['Average time to get all information: ', num2str(output.user_results.total.average_time), ' seconds'])
disp(['Recommended Simulation Length: ', num2str(x(end,1)), ' messages'])

%% Save data
if run_param.save_data
    % Create name of data file
    str = [run_param.scheme, '_',...
        run_param.freq, '_',...
        run_param.channel, '_',...
        'GUS', num2str(run_param.num_GUS_sites), '_',...
        'TBA', num2str(run_param.TBA), '_',...
        'Iterations', num2str(opt_length)];
    
    % Save to data directory
    try
        cd([pwd, '/Data/Optimized', '/', str])
    catch
        mkdir([pwd, '/Data/Optimized', '/', str])
        cd([pwd, '/Data/Optimized', '/', str])
    end
    
    % Save data
    if strcmp(run_param.scheme, 'ECDSA')
        save(str)
    elseif strcmp(run_param.scheme, 'TESLA')
        save(str)
    end
    
    % Change back to this directory
    cd(my_dir)
end

