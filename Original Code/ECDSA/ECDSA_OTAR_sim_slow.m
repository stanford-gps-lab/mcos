function [user_results, broadcast, extra] = ECDSA_OTAR_sim(OMT, n, m, PER, TBA)
tic     % Start timer

% This simulator generates OTAR information using the "Single channel
% broadcast scheduling algorithm" presented in "Hameed - Efficient
% algorithms for scheduling data broadcast"

%% Generate data stream using algorithm
% Initialize B
OMT.OMT1.B = 0;
OMT.OMT2.B = 0;
OMT.OMT3.B = 0;
OMT.OMT4.B = 0;
OMT.OMT5.B = 0;
OMT.OMT6.B = 0;
OMT.OMT7.B = 0;
OMT.OMT8.B = 0;
OMT.OMT14.B = 0;
OMT.OMT15.B = 0;

% Initialize C
OMT.OMT1.C = OMT.OMT1.s;
OMT.OMT2.C = OMT.OMT2.s;
OMT.OMT3.C = OMT.OMT3.s;
OMT.OMT4.C = OMT.OMT4.s;
OMT.OMT5.C = OMT.OMT5.s;
OMT.OMT6.C = OMT.OMT6.s;
OMT.OMT7.C = OMT.OMT7.s;
OMT.OMT8.C = OMT.OMT8.s;
OMT.OMT14.C = OMT.OMT14.s;
OMT.OMT15.C = OMT.OMT15.s;

% Initialize Time
T = 1;  % Time counter (Units of TBA)

% Initialize messages tracker
M = 0;  % Message counter used for outputing which messages happened in what order

% Initialize broadcast matrix
max_num_messages = max([OMT.OMT1.messages, OMT.OMT2.messages, OMT.OMT3.messages, OMT.OMT4.messages, OMT.OMT5.messages, OMT.OMT6.messages, OMT.OMT7.messages, OMT.OMT8.messages, OMT.OMT14.messages, OMT.OMT15.messages]);   % Find the maximum number of messages for a specific OMT
broadcast = zeros(max_num_messages, 15, n + max_num_messages);  % The last addition of max_num_messages is to give buffer just in case there is a run over of T over n

disp('Generating Broadcast...')

while T < n
    % Increment M
    M = M + 1;
    
    % Step 1 - Determine set S of items for which B_i <= T
    
    if OMT.OMT1.B <= T
        OMT.OMT1.inS = 1;
    end
    if OMT.OMT2.B <= T
        OMT.OMT2.inS = 1;
    end
    if OMT.OMT3.B <= T
        OMT.OMT3.inS = 1;
    end
    if OMT.OMT4.B <= T
        OMT.OMT4.inS = 1;
    end
    if OMT.OMT5.B <= T
        OMT.OMT5.inS = 1;
    end
    if OMT.OMT6.B <= T
        OMT.OMT6.inS = 1;
    end
    if OMT.OMT7.B <= T
        OMT.OMT7.inS = 1;
    end
    if OMT.OMT8.B <= T
        OMT.OMT8.inS = 1;
    end
    if OMT.OMT14.B <= T
        OMT.OMT14.inS = 1;
    end
    if OMT.OMT15.B <= T
        OMT.OMT15.inS = 1;
    end
    
    % Step 2 - Find C_min
    
    % Initialize a Cmin_finder to find Cmin in set of S. All OMTs that are not in S have
    % values set to inf.
    Cmin_finder = ones(15,1)*inf;
    if OMT.OMT1.inS == 1
        Cmin_finder(1) =  OMT.OMT1.C;
    end
    if OMT.OMT2.inS == 1
        Cmin_finder(2) =  OMT.OMT2.C;
    else
        Cmin_finder(2) = inf;
    end
    if OMT.OMT3.inS == 1
        Cmin_finder(3) =  OMT.OMT3.C;
    else
        Cmin_finder(3) = inf;
    end
    if OMT.OMT4.inS == 1
        Cmin_finder(4) =  OMT.OMT4.C;
    else
        Cmin_finder(4) = inf;
    end
    if OMT.OMT5.inS == 1
        Cmin_finder(5) =  OMT.OMT5.C;
    else
        Cmin_finder(5) = inf;
    end
    if OMT.OMT6.inS == 1
        Cmin_finder(6) =  OMT.OMT6.C;
    else
        Cmin_finder(6) = inf;
    end
    if OMT.OMT7.inS == 1
        Cmin_finder(7) =  OMT.OMT7.C;
    else
        Cmin_finder(7) = inf;
    end
    if OMT.OMT8.inS == 1
        Cmin_finder(8) =  OMT.OMT8.C;
    else
        Cmin_finder(8) = inf;
    end
    if OMT.OMT14.inS == 1
        Cmin_finder(14) =  OMT.OMT14.C;
    else
        Cmin_finder(14) = inf;
    end
    if OMT.OMT15.inS == 1
        Cmin_finder(15) =  OMT.OMT15.C;
    else
        Cmin_finder(15) = inf;
    end
    
    % Step 3 - Choose one item that has C_j = C_min
    
    [Cmin ,Cmin_I] = min(Cmin_finder);  % Choose which item will be broadcast
    
    extra.messages_num(M) = Cmin_I;  % Output message number for debug/plotting purposes
    
    % Step 4 Broadcast item j at time T
    % Step 5 When item j completes transmission, T = T + l_j
    
    % In each check: check if it is the item being broadcast, update B_j
    % and C_j, Release each portion of the message in a for loop, then
    % update T
    if Cmin_I == 1
        OMT.OMT1.B = OMT.OMT1.C;
        OMT.OMT1.C = OMT.OMT1.B + OMT.OMT1.s;
        for i = 1:OMT.OMT1.messages
            broadcast(i,1,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 2
        OMT.OMT2.B = OMT.OMT2.C;
        OMT.OMT2.C = OMT.OMT2.B + OMT.OMT2.s;
        for i = 1:OMT.OMT2.messages
            broadcast(i,2,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 3
        OMT.OMT3.B = OMT.OMT3.C;
        OMT.OMT3.C = OMT.OMT3.B + OMT.OMT3.s;
        for i = 1:OMT.OMT3.messages
            broadcast(i,3,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 4
        OMT.OMT4.B = OMT.OMT4.C;
        OMT.OMT4.C = OMT.OMT4.B + OMT.OMT4.s;
        for i = 1:OMT.OMT4.messages
            broadcast(i,4,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 5
        OMT.OMT5.B = OMT.OMT5.C;
        OMT.OMT5.C = OMT.OMT5.B + OMT.OMT5.s;
        for i = 1:OMT.OMT5.messages
            broadcast(i,5,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 6
        OMT.OMT6.B = OMT.OMT6.C;
        OMT.OMT6.C = OMT.OMT6.B + OMT.OMT6.s;
        for i = 1:OMT.OMT6.messages
            broadcast(i,6,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 7
        OMT.OMT7.B = OMT.OMT7.C;
        OMT.OMT7.C = OMT.OMT7.B + OMT.OMT7.s;
        for i = 1:OMT.OMT7.messages
            broadcast(i,7,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 8
        OMT.OMT8.B = OMT.OMT8.C;
        OMT.OMT8.C = OMT.OMT8.B + OMT.OMT8.s;
        for i = 1:OMT.OMT8.messages
            broadcast(i,8,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 14
        OMT.OMT14.B = OMT.OMT14.C;
        OMT.OMT14.C = OMT.OMT14.B + OMT.OMT14.s;
        for i = 1:OMT.OMT14.messages
            broadcast(i,14,T) = 1;
            T = T + 1;
        end
    elseif Cmin_I == 15
        OMT.OMT15.B = OMT.OMT15.C;
        OMT.OMT15.C = OMT.OMT15.B + OMT.OMT15.s;
        for i = 1:OMT.OMT15.messages
            broadcast(i,15,T) = 1;
            T = T + 1;
        end
    end
    
    % Clear set S
    OMT.OMT1.inS = 0;
    OMT.OMT2.inS = 0;
    OMT.OMT3.inS = 0;
    OMT.OMT4.inS = 0;
    OMT.OMT5.inS = 0;
    OMT.OMT6.inS = 0;
    OMT.OMT7.inS = 0;
    OMT.OMT8.inS = 0;
    OMT.OMT14.inS = 0;
    OMT.OMT15.inS = 0;
    
end

%% Simulate users
% Initial state of user
user_init = zeros(max_num_messages,15);  % Initialize user as having heard no messages
user_results.time = zeros(15,m,T-1);    % This will be the template to record times to receive each message
T_start = 1;    % Initialize T_start
T_waitbar = waitbar(0, 'Simulating User Experience...');

disp('Simulating User...')

while T_start < T    
    for i = 1:m
        listening_flag = 1; % Set listening flag equal to 1
        t = T_start;    % Initialize time
        user = user_init; % Initialize user
        while listening_flag
            
            PER_check = rand;   % Check if message failed to be demodulated
            if PER_check > PER  % Successful message delivery
                user = user + broadcast(:,:,t); % Add to list of messages user has received
            end
            
            % Check for message closure
            
            % OMT 1
            if user_results.time(1,i,T_start) == 0 && sum(user(:,1)) == OMT.OMT1.messages
                user_results.time(1,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 2
            if user_results.time(2,i,T_start) == 0 && sum(user(:,2)) == OMT.OMT2.messages
                user_results.time(2,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 3
            if user_results.time(3,i,T_start) == 0 && sum(user(:,3)) == OMT.OMT3.messages
                user_results.time(3,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 4
            if user_results.time(4,i,T_start) == 0 && sum(user(:,4)) == OMT.OMT4.messages
                user_results.time(4,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 5
            if user_results.time(5,i,T_start) == 0 && sum(user(:,5)) == OMT.OMT5.messages
                user_results.time(5,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 6
            if user_results.time(6,i,T_start) == 0 && sum(user(:,6)) == OMT.OMT6.messages
                user_results.time(6,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 7
            if user_results.time(7,i,T_start) == 0 && sum(user(:,7)) == OMT.OMT7.messages
                user_results.time(7,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 8
            if user_results.time(8,i,T_start) == 0 && sum(user(:,8)) == OMT.OMT8.messages
                user_results.time(8,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 14
            if user_results.time(14,i,T_start) == 0 && sum(user(:,14)) == OMT.OMT14.messages
                user_results.time(14,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            % OMT 15
            if user_results.time(15,i,T_start) == 0 && sum(user(:,15)) == OMT.OMT15.messages
                user_results.time(15,i,T_start) = (t - T_start + 1)*TBA;   % Reports time to receive OMT1 in seconds
            end
            
            % Check if Authenticated public key has been received
            if sum(sum([user(:,1), user(:,2)])) == sum([OMT.OMT1.messages, OMT.OMT2.messages])
                user_results.PK_auth_time.time(i,T_start) = (t - T_start + 1)*TBA;
            end
            
            % Check if all messages have been recorded
            
            if sum([user_results.time(1:8,i,T_start); user_results.time(14:15,i,T_start)] == 0) == 0
                user_results.total.total_time(i,T_start) = (t - T_start + 1)*TBA;  % record total time to listen to messages in seconds
                listening_flag = 0;  % Turn listening flag off to move on to next user
            end
            
            t = t + 1; % Increment t
            
            % Check if we have run over the simulated broadcast results
            if t > T
                user_results.total.total_time(i,T_start) = NaN;    % NaN totaltime for this T_start
                user_results.time(1:8,i,T_start) = NaN(8,1);    % NaN time for results
                user_results.time(14:15,i,T_start) = NaN(2,1);  % NaN time for results
                listening_flag = 0; % Stop listening and do not tabulate recorded results
            end
            
        end
    end
    T_start = T_start + 1;  % Incrememnt T_start
    
    % Increment waitbar
    waitbar(T_start/T, T_waitbar);

end

close(T_waitbar)    % Close waitbar

%% Compute statistics on user

disp('Post-Processing User Data...')

% Calculate the average time for each message in seconds
user_results.total.average_time = nanmean(nanmean(user_results.total.total_time));
user_results.OMT1.average_time = nanmean(nanmean(user_results.time(1,:,:)));
user_results.OMT2.average_time = nanmean(nanmean(user_results.time(2,:,:)));
user_results.OMT3.average_time = nanmean(nanmean(user_results.time(3,:,:)));
user_results.OMT4.average_time = nanmean(nanmean(user_results.time(4,:,:)));
user_results.OMT5.average_time = nanmean(nanmean(user_results.time(5,:,:)));
user_results.OMT6.average_time = nanmean(nanmean(user_results.time(6,:,:)));
user_results.OMT7.average_time = nanmean(nanmean(user_results.time(7,:,:)));
user_results.OMT8.average_time = nanmean(nanmean(user_results.time(8,:,:)));
user_results.OMT14.average_time = nanmean(nanmean(user_results.time(14,:,:)));
user_results.OMT15.average_time = nanmean(nanmean(user_results.time(15,:,:)));
user_results.PK_auth_time.average_time = nanmean(nanmean(user_results.PK_auth_time.time));

% Calculate the standard deviation, max, min, and mode of time for each message in seconds
% Total
temp1 = user_results.total.total_time(:);
user_results.total.stdev_time = nanstd(temp1);
user_results.total.max_time = nanmax(temp1);
user_results.total.min_time = nanmin(temp1);
user_results.total.mode_time = mode(temp1);
% OMT1
temp1 = user_results.time(1,:,:);
temp1 = temp1(:);
user_results.OMT1.stdev_time = nanstd(temp1);
user_results.OMT1.max_time = nanmax(temp1);
user_results.OMT1.min_time = nanmin(temp1);
user_results.OMT1.mode_time = mode(temp1);
% OMT2
temp1 = user_results.time(2,:,:);
temp1 = temp1(:);
user_results.OMT2.stdev_time = nanstd(temp1);
user_results.OMT2.max_time = nanmax(temp1);
user_results.OMT2.min_time = nanmin(temp1);
user_results.OMT2.mode_time = mode(temp1);
% OMT3
temp1 = user_results.time(3,:,:);
temp1 = temp1(:);
user_results.OMT3.stdev_time = nanstd(temp1);
user_results.OMT3.max_time = nanmax(temp1);
user_results.OMT3.min_time = nanmin(temp1);
user_results.OMT3.mode_time = mode(temp1);
% OMT4
temp1 = user_results.time(4,:,:);
temp1 = temp1(:);
user_results.OMT4.stdev_time = nanstd(temp1);
user_results.OMT4.max_time = nanmax(temp1);
user_results.OMT4.min_time = nanmin(temp1);
user_results.OMT4.mode_time = mode(temp1);
% OMT5
temp1 = user_results.time(5,:,:);
temp1 = temp1(:);
user_results.OMT5.stdev_time = nanstd(temp1);
user_results.OMT5.max_time = nanmax(temp1);
user_results.OMT5.min_time = nanmin(temp1);
user_results.OMT5.mode_time = mode(temp1);
% OMT6
temp1 = user_results.time(6,:,:);
temp1 = temp1(:);
user_results.OMT6.stdev_time = nanstd(temp1);
user_results.OMT6.max_time = nanmax(temp1);
user_results.OMT6.min_time = nanmin(temp1);
user_results.OMT6.mode_time = mode(temp1);
% OMT7
temp1 = user_results.time(7,:,:);
temp1 = temp1(:);
user_results.OMT7.stdev_time = nanstd(temp1);
user_results.OMT7.max_time = nanmax(temp1);
user_results.OMT7.min_time = nanmin(temp1);
user_results.OMT7.mode_time = mode(temp1);
% OMT8
temp1 = user_results.time(8,:,:);
temp1 = temp1(:);
user_results.OMT8.stdev_time = nanstd(temp1);
user_results.OMT8.max_time = nanmax(temp1);
user_results.OMT8.min_time = nanmin(temp1);
user_results.OMT8.mode_time = mode(temp1);
% OMT14
temp1 = user_results.time(14,:,:);
temp1 = temp1(:);
user_results.OMT14.stdev_time = nanstd(temp1);
user_results.OMT14.max_time = nanmax(temp1);
user_results.OMT14.min_time = nanmin(temp1);
user_results.OMT14.mode_time = mode(temp1);
% OMT15
temp1 = user_results.time(15,:,:);
temp1 = temp1(:);
user_results.OMT15.stdev_time = nanstd(temp1);
user_results.OMT15.max_time = nanmax(temp1);
user_results.OMT15.min_time = nanmin(temp1);
user_results.OMT15.mode_time = mode(temp1);

% Display elapsed time
sim_time = toc;
disp(['Simulation Elapsed time: ', num2str(sim_time), ' seconds'])

end