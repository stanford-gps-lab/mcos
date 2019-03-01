function output = run_ECDSA_sim(run_param, output)
% Master file for running ECDSA design and simulation
% Andrew Neish 1/17/2019

%% Global constants
% Calculate how many bits are available in a message
if run_param.I_channel && run_param.L1     % L1 I channel
    output.m_length = 212;
elseif run_param.I_channel && ~run_param.L1  % L5 I channel
    output.m_length = 216;
else   % L1 Q channel - Q channel does not need traditional MT or preamble
    output.m_length = 250;
end

output.OMT_header_bits = 5;    % 5 bits OMT header for ECDSA

%% Signature input parameters
% Choose key lengths for data keys
output.level_2_sig_length_bits = run_param.level_2_key_length_bits*2;  % Defines length of the data signature in bits
output.level_2_sig_length_messages = ceil(output.level_2_sig_length_bits/output.m_length); % Defines length of data signature in messages

% If Q channel, calculate if enough room left for CRC and OMT. Add another 250 bits if not enough room
if ~run_param.I_channel
   output.CRC_OMT_bits = output.level_2_sig_length_messages*output.m_length - output.level_2_sig_length_bits;
   if output.CRC_OMT_bits < run_param.Q_CRC_bits + output.OMT_header_bits + run_param.OTAR_min
       output.level_2_sig_length_messages = output.level_2_sig_length_messages + 1;
   end
end

% Choose key lengths for root keys
output.level_1_sig_length_bits = run_param.level_1_key_length_bits*2;    % Defines length of root signature in bits
output.level_1_sig_length_messages = ceil(output.level_1_sig_length_bits/output.m_length); % Defines length of root signature in messages

% Calculate number of bits used to denote how many previous messages authenticated
if run_param.I_channel
    output.message_num_bits = ceil(log2(run_param.TBA - output.level_2_sig_length_messages));
else
    output.message_num_bits = 0; % If Q channel, no need to tell how many messages are being authenticated
end

% Calculate the number of bits left over for OTAR
if run_param.I_channel
    output.bits_leftover = output.level_2_sig_length_messages*output.m_length - output.level_2_sig_length_bits;
else
    output.bits_leftover = output.level_2_sig_length_messages*output.m_length - output.level_2_sig_length_bits - run_param.Q_CRC_bits;
end
output.OTAR_bits = output.bits_leftover - output.message_num_bits;   % Bits available for OTAR after signature

if run_param.disp_on
    disp(['OTAR bits available: ', num2str(output.OTAR_bits)])
end

% Calculate all of the OMT lengths in bits
output.OMT = ECDSA_OMT_bit_lengths(run_param, output);

%% Execute analysis from "Hameed - Efficient Algorithms for Scheduling Data Broadcast"

% Calculate the spacing, s_i, that minimizes the overall mean access time
output = ECDSA_spacing(run_param, output);

% Calculate the fraction of the output bandwidth for each OMT
output.OMT = ECDSA_bandwidth(output);

% Calculate average wait time for full transmission of each OMT (s)
output.OMT = ECDSA_waittime(run_param, output);

%% Sanity checks
% Check if a valid curve is used
if ~max(run_param.level_2_key_length_bits == [224, 256, 384])
    error('Choose valid curve for data ECDSA')
end
if ~max(run_param.level_1_key_length_bits == [224, 256, 384])
    error('Choose valid curve for root ECDSA')
end

% Check if TBA is feasible
TBA_check = ceil(output.level_2_sig_length_bits/output.m_length);
if TBA_check > run_param.TBA
    error('The TBA chosen is too small for the given key size.')
end
if output.message_num_bits < 1 && run_param.I_channel
    error('TBA and signature overlapping. Check I/Q channel and TBA.')
end

%% Run Monte Carlo Sim
if run_param.run_sim
    output = ECDSA_OTAR_sim(run_param, output);
end

%% Output plots
if run_param.run_sim && ~isempty(run_param.plots)
    output = ECDSA_sim_plot(run_param, output);
end

