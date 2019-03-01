function output = run_TESLA_sim(run_param, output)
% Master file for running TESLA design and simulation
% Andrew Neish 1/18/2019

%% Global constants
% Calculate how many bits are available in a message
if run_param.I_channel && run_param.L1     % L1 I channel
    output.m_length = 212;
elseif run_param.I_channel && ~run_param.L1  % L5 I channel
    output.m_length = 216;
else   % L1 Q channel - Q channel does not need traditional MT or preamble
    output.m_length = 250;
end

output.OMT_header_bits = 5;    % 5 bits OMT header for TESLA

%% Signature input parameters (Assume fast and slow keys are the same length)
output.TESLA_sig_length_bits = run_param.TESLA_key_length_bits + run_param.TESLA_MAC_length_bits + 1; % 1 bit to identify whether fast or slow keychain
output.TESLA_sig_length_messages = ceil(output.TESLA_sig_length_bits/output.m_length);

% If Q channel, calculate if enough room left for CRC and OMT. Add another 250 bits if not enough room
if ~run_param.I_channel
   output.CRC_OMT_bits = output.TESLA_sig_length_messages*output.m_length - output.TESLA_sig_length_bits;
   if output.CRC_OMT_bits < run_param.Q_CRC_bits + output.OMT_header_bits + run_param.OTAR_min
       output.TESLA_sig_length_messages = output.TESLA_sig_length_messages + 1;
   end
end

% Choose key lengths for level 2 keys
output.level2_sig_length_bits = run_param.level2_key_length_bits*2;  % Defines length of the level 2 signature in bits
output.level2_key_length_messages = ceil(run_param.level2_key_length_bits/output.m_length); % Defines length of level 2 key in messages
output.level2_sig_length_messages = ceil(output.level2_sig_length_bits/output.m_length); % Defines length of level 2 signature in messages

% Choose key lengths for level 1 keys
output.level1_sig_length_bits = run_param.level1_key_length_bits*2;    % Defines length of level 1 signature in bits
output.level1_key_length_messages = ceil(run_param.level1_key_length_bits/output.m_length); % Defines length of level 1 key in messages
output.level1_sig_length_messages = ceil(output.level1_sig_length_bits/output.m_length); % Defines length of level 1 signature in messages

% Calculate number of bits used to denote how many previous messages authenticated
if run_param.I_channel
    output.message_num_bits = ceil(log2(run_param.TBA - output.TESLA_sig_length_messages));
    if output.message_num_bits < 0
        error('Check TBA and I/Q, may not have enough room to send data AND signatures')
    end
else
    output.message_num_bits = ceil(log2(run_param.TBA));
end

% Calculate the number of bits left over for OTAR
output.bits_leftover = output.TESLA_sig_length_messages*output.m_length - output.TESLA_sig_length_bits;   % Bits available for OTAR after signature and message_num_bits
output.OTAR_bits = output.bits_leftover - output.message_num_bits;

if run_param.disp_on
    disp(['OTAR bits available: ', num2str(output.OTAR_bits)])
end

% Calculate all of the OMT lengths in bits
output.OMT = TESLA_OMT_bit_lengths(run_param, output);

%% Execute analysis from "Hameed - Efficient Algorithms for Scheduling Data Broadcast"

% Calculate the spacing, s_i, that minimizes the overall mean access time
output = TESLA_spacing(run_param, output);

% Calculate the fraction of the output bandwidth for each OMT
output.OMT = TESLA_bandwidth(output);

% Calculate average wait time for full transmission of each OMT (s)
output.OMT = TESLA_waittime(run_param, output);

%% Sanity checks
% Check if a valid curve is used
if ~max(run_param.level2_key_length_bits == [224, 256, 384])
    error('Choose valid curve for level 2 ECDSA')
end
if ~max(run_param.level1_key_length_bits == [224, 256, 384])
    error('Choose valid curve for level 1 ECDSA')
end

% Check if TBA is feasible
output.TBA_check = ceil(output.TESLA_sig_length_bits/output.m_length);
if output.TBA_check > run_param.TBA
    error('The TBA chosen is too small for the given key size.')
end
if run_param.TBA - output.TESLA_sig_length_messages < 1
    error('TBA and signature overlapping. Check I/Q channel and TBA.')
end

%% Simulator inputs
if run_param.run_sim
    %% Run Monte Carlo Sim
    output = TESLA_OTAR_sim(run_param, output);
end

%% Output plots
if run_param.run_sim && ~isempty(run_param.plots)
    output.TESLA_sim_plots = TESLA_sim_plot(run_param, output);
end
end

