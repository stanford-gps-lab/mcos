function output = ECDSA_OTAR_sim(run_param, output)
% Andrew Neish 1/17/2019
% This simulator generates OTAR information using the "Single channel
% broadcast scheduling algorithm" presented in "Hameed - Efficient
% algorithms for scheduling data broadcast"

% Break out structure
OMT = output.OMT;
n = run_param.OTAR_num;
m = run_param.user_loop;
PER = run_param.PER;
TBA = run_param.TBA;
num_GUS_sites = run_param.num_GUS_sites;

message_fields = output.message_fields;

ticsim = tic;     % Start timer
%% Generate data stream using algorithm
% Initialize B
OMT.B_vec = zeros(31,1);

% Initialize C
OMT.C_vec = zeros(31,1);
for i = message_fields
    OMT.C_vec(i) = OMT.s_vec(i);
end

% Calculate which row each message starts in the broadcast matrix
OMT.col_start_vec = zeros(31,1);
OMT.col_start_vec(1) = 1;
for i = message_fields(2:end)
    k = find(flip(OMT.col_start_vec),1);
    OMT.col_start_vec(i) = OMT.messages_vec(32-k) + OMT.col_start_vec(32-k);
end

% Calculate which rows correspond to each message
for i = message_fields
    OMT.rows_cell{i} = OMT.col_start_vec(i):OMT.col_start_vec(i) + OMT.messages_vec(i) - 1;
end

% Initialize Time
T = 1;  % Time counter (Units of TBA)

% Initialize messages tracker
M = 0;  % Message counter used for outputing which messages happened in what order

% Initialize broadcast matrix
max_num_messages = max(OMT.messages_vec);   % Find the maximum number of messages for a specific OMT
total_num_messages = sum(OMT.messages_vec); % Find the total number of messages for OTAR
broadcast_array = zeros(total_num_messages, n + max_num_messages, 'int8');  % The last addition of max_num_messages is to give buffer just in case there is a run over of T over n

if run_param.disp_on
    disp('Generating Broadcast...')
end

% Initialize OMT.inS_vec
OMT.inS_vec = zeros(31,1);

while T < n
    % Increment M
    M = M + 1;
    
    % Step 1 - Determine set S of items for which B_i <= T
    
    for i = message_fields
        if OMT.B_vec(i) <= T
            OMT.inS_vec(i) = 1;
        end
    end
    
    % Step 2 - Find C_min
    
    % Initialize a Cmin_finder to find Cmin in set of S. All OMTs that are not in S have
    % values set to inf.
    Cmin_finder = ones(31,1)*inf;
    
    for i = message_fields
        if OMT.inS_vec(i) == 1
            Cmin_finder(i) = OMT.C_vec(i);
        else
            Cmin_finder(i) = inf;
        end
    end
    
    % Step 3 - Choose one item that has C_j = C_min
    
    [~ ,Cmin_I] = min(Cmin_finder);  % Choose which item will be broadcast
    
    extra.messages_num(M) = Cmin_I;  % Output message number for debug/plotting purposes
    
    % Step 4 Broadcast item j at time T
    % Step 5 When item j completes transmission, T = T + l_j
    
    % In each check: check if it is the item being broadcast, update B_j
    % and C_j, Release each portion of the message in a for loop, then
    % update T
    for i = message_fields
        if Cmin_I == (i)
            OMT.B_vec(i) = OMT.C_vec(i);
            OMT.C_vec(i) = OMT.B_vec(i) + OMT.s_vec(i);
            for j = 1:OMT.messages_vec(i)
                broadcast_array(OMT.col_start_vec(i) + j - 1, T) = 1;
                T = T + 1;
            end
            break
        end
    end
    
    % Clear set S
    OMT.inS_vec = zeros(31,1);
    
end

% Cut off any zeros at the end of broadcast
broadcast_array = broadcast_array(:,any(broadcast_array~=0));

% % Replicate broadcast m times for each user.
% broadcast_full = repmat(broadcast_array, [1, 1, m]);  % Replicates broadcast m times into the 3rd dimension
% 
% %% Simulate users
% % Credit to Adrien Perkins for helping me streamline this code
% if run_param.disp_on
%     disp('Simulating User...')
% end
% 
% % Initial state of user matrix
% user_results.time_raw = zeros(total_num_messages, T-1, m);  % Initialize time_raw matrix
% T_start = 1;   % Initialize T_start
% if run_param.disp_on
%     T_waitbar = waitbar(0, 'Simulating User Experience...');    % Initialize waitbar
% end
% tic1 = tic; % Debug
% while T_start < T
%     % Update message the users see
%     broadcast_temp = broadcast_full(:,T_start:end,:);
%     
%     % Create random matrix according to PER to see which messages are dropped
%     PER_mat = int8(repmat(rand(1, length(broadcast_array) - T_start + 1, m) > PER, [total_num_messages, 1, 1]));
%     
%     % Dot multiply PER_mat and broadcast_temp to null missed messages by users
%     broadcast_temp = broadcast_temp.*PER_mat;
%     
%     % For each user and find the time it took to receive each part of the message
%     [temp1, temp2] = max(broadcast_temp ~= 0, [], 2 ); % find which column the first submessages were received
%     if sum(temp1 == 0) > 0   % Check to make sure the user received all possible messages
%         user_results.time_raw(:, T_start, :) = NaN(total_num_messages, 1, m);  % Null receiver results if not all messages received
%     else
%         user_results.time_raw(:, T_start, :) = temp2.*TBA; % Report time in seconds
%     end
%     
%     
%     % Increment T_start
%     T_start = T_start + 1;
%     
%     % Increment waitbar
%     if run_param.disp_on
%         waitbar(T_start/T, T_waitbar);
%     end
% end
% tic1time = toc(tic1);   % Debug
% if run_param.disp_on
%     close(T_waitbar)    % Close waitbar
% end

%% New method of carrying out simulation
% Preallocate arrays
user_results.sub_message.max = zeros(total_num_messages,1);
user_results.sub_message.min = zeros(total_num_messages,1);
user_results.sub_message.average = zeros(total_num_messages,1);
user_results.sub_message.mode = zeros(total_num_messages,1);
user_results.sub_message.stdev = zeros(total_num_messages,1);


% Create PER matrix to simulate missed messages
PER_mat = int8(rand(length(broadcast_array), length(broadcast_array), m) > PER); 

for i = 1:total_num_messages    % Loop through all sub messages (I know, for loops suck, but it was the only loop I couldn't figure out how to get rid of)
    % Create 3dim matrix that creates different "start times" for this
    % matrix. sub_message_sim_mat = [
    sub_message_sim_mat = tril(toeplitz(fliplr(broadcast_array(i,:)))); % Create lower triangular toeplitz matrix to create different "start times" for this submessage
    sub_message_sim_mat = repmat(sub_message_sim_mat, [1,1,m]);     % Replicate this message out for number of users specified by m
    
    % dot-multiply PER_mat with sub_message_sim_mat to simulate missed
    % messages
    sub_message_sim_mat = sub_message_sim_mat.*PER_mat;
    
    % Record when messages were received and NaN results that didnt receive
    [temp1, temp2] = max(sub_message_sim_mat, [], 2);
    temp1 = double(temp1);    % Convert temp1 into a class double matrix
    temp1(temp1==0) = NaN;  % Convert zero values to NaN because no max was found
    temp3 = squeeze(temp1.*temp2);   % Finish converting values with no max to NaN

    % Record sub_message results
    user_results.sub_messages(:,:,i) = single(temp3);   % Save space and store as a single-precision floating point. Has NaN so need floating point precision
end

%% Display elapsed time
sim_time = toc(ticsim);
if run_param.disp_on
    disp(['Simulation Elapsed time: ', num2str(sim_time), ' seconds'])
end

%% New method of computing statistics on user
% % Compute statistics (max, min, mean, mode, stdev) May not need this for
% the submessages
%     user_results.sub_message.max(i) = max(max(temp3));
%     user_results.sub_message.min(i) = min(min(temp3));
%     user_results.sub_message.average(i) = mean(nanmean(temp3));
%     user_results.sub_message.mode(i) = mode(temp3, 'all');
%     user_results.sub_message.stdev(i) = nanstd(temp3,0,'all');

% From the submessages, calculate the time it takes to receive each message in seconds
user_results.time = NaN(length(broadcast_array), m, length(OMT.messages_vec));
for i = message_fields
    user_results.time(:,:,i) = max(user_results.sub_messages(:,:,OMT.rows_cell{i}), [], 3, 'includenan').*TBA;
end

% Calculate the standard deviation, max, min, and mode of time for each message in seconds




%% Compute statistics on user
tic2 = tic; % Debug
if run_param.disp_on
    disp('Post-Processing User Data...')
end

% Compute time to complete each message and set of messages and compile into original format
for j = 1:T-1
    for i = 1:m
        % Put into user_results.time format
        user_results.time(:,i,j) = NaN(31,1);
        for k = message_fields
            user_results.time(k,i,j) = max(user_results.time_raw(OMT.rows_cell{k},j,i));
        end
        
        % Calculate the total time it took to receive all messages
        user_results.total.total_time(i,j) = max(user_results.time(:,i,j));
        
        % Calculate the time it took to receive an authenticated current public key
        user_results.current_auth_PK_time.time(i,j) = max(user_results.time(1:2,i,j));
        
        % Calculate the time it took to receive an authenticated expiration of the current keys
        user_results.current_auth_exp_PK_time.time(i,j) = max(user_results.time(3:4,i,j));
        
        % Calculate the time it took to receive an authenticated next public key
        user_results.next_auth_PK_time.time(i,j) = max(user_results.time(5:6,i,j));
        
        % Calculate the time it took to receive an authenticated expiration of the next keys
        user_results.next_auth_exp_PK_time.time(i,j) = max(user_results.time(7:8,i,j));
        
        if num_GUS_sites > 1
            % Calculate the time it took to receive all authenticated current public keys
            user_results.all_current_auth_PK_time.time(i,j) = max(user_results.time(16:17,i,j));
            
            % Calculate the time it took to receive all authenticated expiration of the current keys
            user_results.all_current_auth_exp_PK_time.time(i,j) = max(user_results.time(18:19,i,j));
            
            % Calculate the time it took to receive all authenticated next public keys
            user_results.all_next_auth_PK_time.time(i,j) = max(user_results.time(20:21,i,j));
            
            % Calculate the time it took to receive all authenticated expiration of the next keys
            user_results.all_next_auth_exp_PK_time.time(i,j) = max(user_results.time(22:23,i,j));
        end
        
        % Calculate the time it took to receive an authenticated private key to unlock the next root key
        user_results.auth_priv_key_time.time(i,j) = max(user_results.time(30:31,i,j));
    end
end

% Calculate the average time for each message in seconds
user_results.total.average_time = nanmean(nanmean(user_results.total.total_time));
for i = message_fields
    user_results.average_time_vec(i) =  nanmean(nanmean(user_results.time(i,:,:)));
end
user_results.current_auth_PK_time.average_time = nanmean(nanmean(user_results.current_auth_PK_time.time));
user_results.current_auth_exp_PK_time.average_time = nanmean(nanmean(user_results.current_auth_exp_PK_time.time));
user_results.next_auth_PK_time.average_time = nanmean(nanmean(user_results.next_auth_PK_time.time));
user_results.next_auth_exp_PK_time.average_time = nanmean(nanmean(user_results.next_auth_exp_PK_time.time));
if num_GUS_sites > 1
    user_results.all_current_auth_PK_time.average_time = nanmean(nanmean(user_results.all_current_auth_PK_time.time));
    user_results.all_current_auth_exp_PK_time.average_time = nanmean(nanmean(user_results.all_current_auth_exp_PK_time.time));
    user_results.all_next_auth_PK_time.average_time = nanmean(nanmean(user_results.all_next_auth_PK_time.time));
    user_results.all_next_auth_exp_PK_time.average_time = nanmean(nanmean(user_results.all_next_auth_exp_PK_time.time));
end
user_results.auth_priv_key_time.average_time = nanmean(nanmean(user_results.auth_priv_key_time.time));

% Calculate the standard deviation, max, min, and mode of time for each message in seconds
% Total
temp1 = user_results.total.total_time(:);
user_results.total.stdev_time = nanstd(temp1);
user_results.total.max_time = nanmax(temp1);
user_results.total.min_time = nanmin(temp1);
user_results.total.mode_time = mode(temp1);

% All OMT
for i = message_fields
    temp1 = user_results.time(i,:,:);
    temp1 = temp1(:);
    user_results.stdev_time_vec(i) = nanstd(temp1);
    user_results.max_time_vec(i) = nanmax(temp1);
    user_results.min_time_vec(i) = nanmin(temp1);
    user_results.mode_time_vec(i) = mode(temp1);
end

% Authenticated Current Public Key
temp1 = user_results.current_auth_PK_time.time(:,:);
temp1 = temp1(:);
user_results.current_auth_PK_time.stdev_time = nanstd(temp1);
user_results.current_auth_PK_time.max_time = nanmax(temp1);
user_results.current_auth_PK_time.min_time = nanmin(temp1);
user_results.current_auth_PK_time.mode_time = mode(temp1);

% Expiration of Current Keys
temp1 = user_results.current_auth_exp_PK_time.time(:,:);
temp1 = temp1(:);
user_results.current_auth_exp_PK_time.stdev_time = nanstd(temp1);
user_results.current_auth_exp_PK_time.max_time = nanmax(temp1);
user_results.current_auth_exp_PK_time.min_time = nanmin(temp1);
user_results.current_auth_exp_PK_time.mode_time = mode(temp1);

% Authenticated Next Public Key
temp1 = user_results.next_auth_PK_time.time(:,:);
temp1 = temp1(:);
user_results.next_auth_PK_time.stdev_time = nanstd(temp1);
user_results.next_auth_PK_time.max_time = nanmax(temp1);
user_results.next_auth_PK_time.min_time = nanmin(temp1);
user_results.next_auth_PK_time.mode_time = mode(temp1);

% Expiration of Next Keys
temp1 = user_results.next_auth_exp_PK_time.time(:,:);
temp1 = temp1(:);
user_results.next_auth_exp_PK_time.stdev_time = nanstd(temp1);
user_results.next_auth_exp_PK_time.max_time = nanmax(temp1);
user_results.next_auth_exp_PK_time.min_time = nanmin(temp1);
user_results.next_auth_exp_PK_time.mode_time = mode(temp1);

if num_GUS_sites > 1
    % All Authenticated Current Public Key
    temp1 = user_results.all_current_auth_PK_time.time(:,:);
    temp1 = temp1(:);
    user_results.all_current_auth_PK_time.stdev_time = nanstd(temp1);
    user_results.all_current_auth_PK_time.max_time = nanmax(temp1);
    user_results.all_current_auth_PK_time.min_time = nanmin(temp1);
    user_results.all_current_auth_PK_time.mode_time = mode(temp1);
    
    % All Expiration of Current Keys
    temp1 = user_results.all_current_auth_exp_PK_time.time(:,:);
    temp1 = temp1(:);
    user_results.all_current_auth_exp_PK_time.stdev_time = nanstd(temp1);
    user_results.all_current_auth_exp_PK_time.max_time = nanmax(temp1);
    user_results.all_current_auth_exp_PK_time.min_time = nanmin(temp1);
    user_results.all_current_auth_exp_PK_time.mode_time = mode(temp1);
    
    % All Authenticated Next Public Key
    temp1 = user_results.all_next_auth_PK_time.time(:,:);
    temp1 = temp1(:);
    user_results.all_next_auth_PK_time.stdev_time = nanstd(temp1);
    user_results.all_next_auth_PK_time.max_time = nanmax(temp1);
    user_results.all_next_auth_PK_time.min_time = nanmin(temp1);
    user_results.all_next_auth_PK_time.mode_time = mode(temp1);
    
    % All Expiration of Next Keys
    temp1 = user_results.all_next_auth_exp_PK_time.time(:,:);
    temp1 = temp1(:);
    user_results.all_next_auth_exp_PK_time.stdev_time = nanstd(temp1);
    user_results.all_next_auth_exp_PK_time.max_time = nanmax(temp1);
    user_results.all_next_auth_exp_PK_time.min_time = nanmin(temp1);
    user_results.all_next_auth_exp_PK_time.mode_time = mode(temp1);
end

% Authenticated private key for next root key
temp1 = user_results.auth_priv_key_time.time(:,:);
temp1 = temp1(:);
user_results.auth_priv_key_time.stdev_time = nanstd(temp1);
user_results.auth_priv_key_time.max_time = nanmax(temp1);
user_results.auth_priv_key_time.min_time = nanmin(temp1);
user_results.auth_priv_key_time.mode_time = mode(temp1);

% Create time varying message delivery array
extra.messages_seq_time = NaN(length(user_results.time) + 1,1);
j = 1;
for i = 1:length(extra.messages_num)
    extra.messages_seq_time(j:j + OMT.messages_vec(extra.messages_num(i)) - 1) = ones(OMT.messages_vec(extra.messages_num(i)),1)*extra.messages_num(i);
    j = j + OMT.messages_vec(extra.messages_num(i));
end

% Calculate percentage of OTAR taken up by each message
extra.bandwidth = tabulate(extra.messages_num);

% Report back out in a structure
output.user_results = user_results;
output.broadcast = broadcast_array;
output.extra = extra;

tic2time = toc(tic2); % Debug

disp(num2str(tic1time/tic2time))

end