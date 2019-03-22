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
broadcast_array = zeros(n + max_num_messages, 1, 'int16');  % The last addition of max_num_messages is to give buffer just in case there is a run over of T over n

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
    OMT.B_vec(Cmin_I) = OMT.C_vec(Cmin_I);
    OMT.C_vec(Cmin_I) = OMT.B_vec(Cmin_I) + OMT.s_vec(Cmin_I);
    for j = 1:OMT.messages_vec(Cmin_I)
        broadcast_array(T) = OMT.col_start_vec(Cmin_I) + j - 1;     % Broadcast array writes each sub message to be broadcast
        T = T + 1;
    end
    
    % Clear set S
    OMT.inS_vec = zeros(31,1);
    
end

% Cut off any zeros at the end of broadcast
broadcast_array = broadcast_array(broadcast_array~=0);

%% Break broadcast_array into blocks
block_flag = 0;
if run_param.OTAR_num > 1000
    block_size = 1000;
else
    block_size = length(broadcast_array);
    block_row_num = 1;
    broadcast_mat = broadcast_array';
    PER_block = int16(rand(1,block_size) > PER);
    if (sum(unique(broadcast_array.*PER_block)) ~= sum(1:total_num_messages))
            error('Input larger simulation length')
    end
    block_flag = 1;
end

while ~block_flag
    
    % Break broadcast arrays into blocks
    block_row_num = floor(length(broadcast_array)/block_size);
    broadcast_mat = reshape(broadcast_array(1:end - rem(length(broadcast_array),block_size)), [block_size, block_row_num])';  % Create matrix where each row is the length of a block size
    PER_block = int16(rand(1,block_size) > PER);    % Multiply broadcast_mat rows with this to ensure block_size is long enough when there is a PER
    
    % Test blocks to see if they carry all messages
    for i = 1:block_row_num-1
        block_flag = 1;
        if sum(unique(broadcast_mat(i,:).*PER_block)) ~= sum(1:total_num_messages)     % Test if all messages are in each row
            block_size = block_size + 1000;     % Increase block size by 2000
            if block_size > length(broadcast_array)
                error('Input larger simulation length')
            end
            block_flag = 0;
            break
        end
    end
    
    if (block_row_num == 1)     % If the original block is the only one that works, let it pass on for simulation
        if (sum(unique(broadcast_array)) ~= sum(1:total_num_messages))
            error('Input larger simulation length')
        else
            broadcast_mat = broadcast_array';
            block_size = length(broadcast_array);
            block_flag = 1;
        end
    end
    
end
broadcast_array = broadcast_array(1:end - rem(length(broadcast_array),block_size));     % Omit part of broadcast_array not used in simulation

if run_param.disp_on
    disp([num2str(block_row_num), ' blocks of size ', num2str(block_size)])
end

%% New method of carrying out simulation that involves toeplitz matrices
if run_param.disp_on
    disp('Simulating User...')
    T_waitbar = waitbar(0, 'Simulating User Experience...');    % Initialize waitbar
end
for j = 1:block_row_num
    
    % Grab broadcast_sub_array
    broadcast_sub_array = broadcast_mat(j,:);
    
    % Create PER matrix to simulate missed messages
    PER_mat = int16(rand(length(broadcast_sub_array), length(broadcast_sub_array), m) > PER);
    
    if j == block_row_num
        % Create matrix that creates different "start times" for different users.
        sub_message_sim_mat = tril(toeplitz(fliplr(broadcast_sub_array))); % Create lower triangular toeplitz matrix to create different "start times" for this submessage
        sub_message_sim_mat = repmat(sub_message_sim_mat, [1,1,m]);     % Replicate this message out for number of users specified by m
    else
        % Create matrix that creates different "start times" for different users. Fill in upper part of triangle for blocks
        sub_message_sim_mat = tril(toeplitz(fliplr(broadcast_sub_array))); % Create lower triangular toeplitz matrix to create different "start times" for this submessage
        temp = [broadcast_sub_array(end), broadcast_mat(j+1,1:end-1)];
        sub_message_sim_mat = sub_message_sim_mat + triu(toeplitz(temp),1);     % Fill in for zeros of upper triangular matrix to complete the block
        sub_message_sim_mat = repmat(sub_message_sim_mat, [1,1,m]);     % Replicate this message out for number of users specified by m
    end
    
    % dot-multiply PER_mat with sub_message_sim_mat to simulate missed messages
    sub_message_sim_mat = sub_message_sim_mat.*PER_mat;
    
    for i = 1:total_num_messages    % Loop through all sub messages (I know, for loops suck, but it was the only loop I couldn't figure out how to get rid of)
        % Record when messages were received and NaN results that didnt receive
        [temp1, temp2] = max(sub_message_sim_mat == i, [], 2);
        temp1 = double(temp1);    % Convert temp1 into a class double matrix
        temp1(temp1==0) = NaN;  % Convert zero values to NaN because no max was found
        temp3 = squeeze(temp1.*temp2);   % Finish converting values with no max to NaN
        
        % Record sub_message results
        user_results.sub_messages((j-1)*block_size + 1:j*block_size,:,i) = single(temp3);   % Save space and store as a single-precision floating point. Has NaN so need floating point precision
        
        if run_param.disp_on
            waitbar((i + (j-1)*total_num_messages)/(total_num_messages*block_row_num), T_waitbar, ['Looping through block ', num2str(j), ' of ', num2str(block_row_num)]);
        end
    end
end

if run_param.disp_on
    close(T_waitbar)    % Close waitbar
end

%% Display elapsed time
sim_time = toc(ticsim);
if run_param.disp_on
    disp(['Simulation Elapsed time: ', num2str(sim_time), ' seconds'])
    disp('Post-Processing User Data...')
end

%% New method of computing statistics on user
% From the submessages, calculate the time it takes to receive each message in seconds
user_results.time = NaN(length(broadcast_array), m, length(OMT.messages_vec));
for i = message_fields
    user_results.time(:,:,i) = max(user_results.sub_messages(:,:,OMT.rows_cell{i}), [], 3, 'includenan').*TBA;
end

% Calculate how long it took to receive certain sets of messages
user_results.total.time = max(user_results.time(:,:,OMT.message_groups{1}), [], 3, 'includenan');
% Calculate the time it took to receive an authenticated current level 2 PK
user_results.current_auth_PK_time.time = max(user_results.time(:,:,OMT.message_groups{2}), [], 3, 'includenan');
% Calculate the time it took to receive an authenticated expiration of current level 2 PK
user_results.current_auth_exp_PK_time.time = max(user_results.time(:,:,OMT.message_groups{3}), [], 3, 'includenan');
% Calculate the time it took to receive an authenticated next level 2 PK
user_results.next_auth_PK_time.time = max(user_results.time(:,:,OMT.message_groups{4}), [], 3, 'includenan');
% Calculate the time it took to receive an authenticated expiration of next level 2 PK
user_results.next_auth_exp_PK_time.time = max(user_results.time(:,:,OMT.message_groups{5}), [], 3, 'includenan');
if num_GUS_sites > 1
    % Calculate the time it took to receive all authenticated current public keys
    user_results.all_current_auth_PK_time.time = max(user_results.time(:,:,OMT.message_groups{6}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated expiration of the current keys
    user_results.all_current_auth_exp_PK_time.time = max(user_results.time(:,:,OMT.message_groups{7}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated next public keys
    user_results.all_next_auth_PK_time.time = max(user_results.time(:,:,OMT.message_groups{8}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated expiration of the next keys
    user_results.all_next_auth_exp_PK_time.time = max(user_results.time(:,:,OMT.message_groups{9}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated expiration of the current keys
    user_results.current_auth_priv_key_time.time = max(user_results.time(:,:,OMT.message_groups{10}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated expiration of the next keys
    user_results.next_auth_priv_key_time.time = max(user_results.time(:,:,OMT.message_groups{11}), [], 3, 'includenan');
else
    % Calculate the time it took to receive all authenticated expiration of the current keys
    user_results.current_auth_priv_key_time.time = max(user_results.time(:,:,OMT.message_groups{6}), [], 3, 'includenan');
    % Calculate the time it took to receive all authenticated expiration of the next keys
    user_results.next_auth_priv_key_time.time = max(user_results.time(:,:,OMT.message_groups{7}), [], 3, 'includenan');
end

% Calculate how many users that were simulated received a full message digest
user_results.num_sim_users = sum(~isnan(user_results.total.time(:)));
if run_param.disp_on
    disp(['Number of users simulated: ', num2str(user_results.num_sim_users)])
end

% Calculate the average time for each message in seconds
user_results.total.average_time = nanmean(nanmean(user_results.total.time));
for i = message_fields
    user_results.average_time_vec(i) =  nanmean(nanmean(user_results.time(i,:,:))); % This might be a typo. Indexing might be (:,:,i) instead.
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
user_results.current_auth_priv_key_time.average_time = nanmean(nanmean(user_results.current_auth_priv_key_time.time));
user_results.next_auth_priv_key_time.average_time = nanmean(nanmean(user_results.next_auth_priv_key_time.time));

% Calculate the standard deviation, max, min, and mode of time for each message in seconds
% Total
temp1 = user_results.total.time(:);
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

% Authenticated private key for current root key
temp1 = user_results.current_auth_priv_key_time.time(:,:);
temp1 = temp1(:);
user_results.current_auth_priv_key_time.stdev_time = nanstd(temp1);
user_results.current_auth_priv_key_time.max_time = nanmax(temp1);
user_results.current_auth_priv_key_time.min_time = nanmin(temp1);
user_results.current_auth_priv_key_time.mode_time = mode(temp1);

% Authenticated private key for next root key
temp1 = user_results.next_auth_priv_key_time.time(:,:);
temp1 = temp1(:);
user_results.next_auth_priv_key_time.stdev_time = nanstd(temp1);
user_results.next_auth_priv_key_time.max_time = nanmax(temp1);
user_results.next_auth_priv_key_time.min_time = nanmin(temp1);
user_results.next_auth_priv_key_time.mode_time = mode(temp1);

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

end