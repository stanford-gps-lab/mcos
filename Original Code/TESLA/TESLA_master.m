% Master file for running TESLA design and simulation
% Andrew Neish 1/18/2019
clear all
close all
clc

%% Run parameters
run_sim = 1;    % Run Simulator
plot_sim_results = 1;   % Plot simulator results
L5 = 1;      % 0 for L1, 1 for L5
I_channel = 1;  % 1 for I channel, 0 for Q channel
num_GUS_sites = 1;  % Use 1 for same data PK between all sites. This dictates how many data PKs will need to be kept track of
PER = 1e-3; % Page error rate, may think about making this into a function of C/N0
TBA = 6;    % Time betweeen authentication in units of time. TBA must be greater than 0

% Set weights for each OMT level. Weights will automatically be normalized.
if num_GUS_sites == 1
    level1p = 90;  % Authenticated current fast/slow keys and salt
    level2p = 6;    % Authenticated Current level 2 PK
    level3p = 3;    % Expiration of current fast/slow keys, salt, and PK
    level4p = 1;    % Authenticated next keys and their authenticated expiration
    level5p = 1;    % Authenticated Private key to unlock next level 1 key
else
    level1p = 90;  % Authenticated current fast/slow keys and salt for this GUS
    level2p = 6;    % Authenticated Current level 2 PK for this GUS
    level3p = 3;    % Expiration of current fast/slow keys, salt, and PK for this GUS
    level4p = 1;    % Authenticated next keys and their authenticated expiration for this GUS
    level5p = 1;    % Authenticated current keys and their authenticated expiration for all GUS
    level6p = 1;    % Authenticated next keys and their authenticated expiration for all GUS
    level7p = 1;    % Authenticated Private key to unlock next level 1 key
end

%% Global constants
if L5
    m_length = 216; % Bits available in the data field
else
    m_length = 212; % Bits available in the data field
end

OMT_header_bits = 5;    % 5 bits OMT header for TESLA

%% Signature input parameters (Assume fast and slow keys are the same length)
% Choose length of slow keys
TESLA_key_length_bits = 115;
TESLA_MAC_length_bits = 30;
TESLA_sig_length_bits = TESLA_key_length_bits + TESLA_MAC_length_bits;
TESLA_sig_length_messages = ceil(TESLA_sig_length_bits/m_length);

% Choose length of salt
salt_length_bits = 30;  % Assume the same salt is used for both fast/slow chains

% Choose key lengths for level 2 keys
level2_key_length_bits = 224;  % Select level 2 public key length. Must be chosen from NIST curve (P-224, P-256, or P-384)
level2_sig_length_bits = level2_key_length_bits*2;  % Defines length of the level 2 signature in bits
level2_key_length_messages = ceil(level2_key_length_bits/m_length); % Defines length of level 2 key in messages
level2_sig_length_messages = ceil(level2_sig_length_bits/m_length); % Defines length of level 2 signature in messages

% Choose key lengths for level 1 keys
level1_key_length_bits = 384;  % Select level 1 key length from above NIST curves
level1_sig_length_bits = level1_key_length_bits*2;    % Defines length of level 1 signature in bits
level1_key_length_messages = ceil(level1_key_length_bits/m_length); % Defines length of level 1 key in messages
level1_sig_length_messages = ceil(level1_sig_length_bits/m_length); % Defines length of level 1 signature in messages

% Calculate number of bits used to denote how many previous messages authenticated
if I_channel
    message_num_bits = ceil(log2(TBA - TESLA_sig_length_messages));
    if message_num_bits < 0
        error('Check TBA and I/Q, may not have enough room to send data AND signatures')
    end
else
    message_num_bits = ceil(log2(TBA));
end

% Calculate the number of bits left over for OTAR
bits_leftover = TESLA_sig_length_messages*m_length - TESLA_sig_length_bits;   % Bits available for OTAR after signature and message_num_bits
OTAR_bits = bits_leftover - message_num_bits;

disp(['OTAR bits available: ', num2str(OTAR_bits)])

% Calculate all of the OMT lengths in bits
OMT = TESLA_OMT_bit_lengths(OTAR_bits, OMT_header_bits, num_GUS_sites, TESLA_key_length_bits, salt_length_bits, level2_key_length_bits, level2_sig_length_bits, level1_sig_length_bits);

%% Execute analysis from "Hameed - Efficient Algorithms for Scheduling Data Broadcast"
% Normalize weights
if num_GUS_sites == 1
    levelpsum = sum([level1p; level2p; level3p; level4p; level5p]);
    level1p = level1p/levelpsum;
    level2p = level2p/levelpsum;
    level3p = level3p/levelpsum;
    level4p = level4p/levelpsum;
    level5p = level5p/levelpsum;
else
    levelpsum = sum([level1p; level2p; level3p; level4p; level5p; level6p; level7p]);
    level1p = level1p/levelpsum;
    level2p = level2p/levelpsum;
    level3p = level3p/levelpsum;
    level4p = level4p/levelpsum;
    level5p = level5p/levelpsum;
    level6p = level6p/levelpsum;
    level7p = level7p/levelpsum;
end

% Split levelxp between different OMTs
OMT.p_vec = [...
    level1p/2;...
    level1p/2;...
    level1p/2;...
    level1p/2;...
    level1p/2;...
    level1p/2;...
    zeros(2,1);...
    level4p/6;...
    level4p/6;...
    level4p/6;...
    level4p/6;...
    level4p/6;...
    level4p/6;...
    zeros(17,1)];
if num_GUS_sites > 1
    OMT.p_vec(16:31) = [...
        level5p/6;...
        level5p/6;...
        level5p/6;...
        level5p/6;...
        level5p/6;...
        level5p/6;...
        zeros(2,1);...
        level6p/6;...
        level6p/6;...
        level6p/6;...
        level6p/6;...
        level6p/6;...
        level6p/6;...
        level7p/2;...
        level7p/2];
else
    OMT.p_vec(30:31) = [...
        level5p/2;...
        level5p/2];
end

% Calculate the spacing, s_i, that minimizes the overall mean access time
[OMT, t_opt, message_fields] = TESLA_spacing(OMT, PER, num_GUS_sites);

% Calculate the fraction of the output bandwidth for each OMT
OMT = TESLA_bandwidth(OMT, message_fields);

% Calculate average wait time for full transmission of each OMT (s)
OMT = TESLA_waittime(OMT, TBA, message_fields);

%% Sanity checks
% Check if a valid curve is used
if ~max(level2_key_length_bits == [224, 256, 384])
    error('Choose valid curve for level 2 ECDSA')
end
if ~max(level1_key_length_bits == [224, 256, 384])
    error('Choose valid curve for level 1 ECDSA')
end

% Check if TBA is feasible
TBA_check = ceil(TESLA_sig_length_bits/m_length);
if TBA_check > TBA
    error('The TBA chosen is too small for the given key size.')
end
if TBA - TESLA_sig_length_messages < 1
    error('TBA and signature overlapping. Check I/Q channel and TBA.')
end

%% Simulator inputs
if run_sim
    n = 3000;  % OTAR messages to be generated
    m = 10;    % Number of times the user loops through the same start point before moving on to the next one
    
    %% Run Monte Carlo Sim
    [user_results, broadcast, extra] = TESLA_OTAR_sim(OMT, n, m, PER, TBA, num_GUS_sites, message_fields);
end

%% Output plots
if run_sim && plot_sim_results
    % Plotting instructions
    Plot_OMT = 0;
    
    TESLA_sim_plots = TESLA_sim_plot(user_results, extra, OMT, Plot_OMT, num_GUS_sites, message_fields);
end

