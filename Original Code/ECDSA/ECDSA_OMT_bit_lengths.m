function OMT = ECDSA_OMT_bit_lengths(run_param, output)
% This function calculates the bit lengths of all OMTs for ECDSA
% implementation. OMT0, OMT9, and OMT10 are not included because they are
% not going to be broadcast repeatedly.

%% break out structure inputs
OTAR_bits = output.OTAR_bits;
OMT_header_bits = output.OMT_header_bits;
num_GUS_sites = run_param.num_GUS_sites;
data_key_length_bits = run_param.level_2_key_length_bits;
root_sig_length_bits = output.level_1_sig_length_bits;

% Assign p_vec to OMT
OMT.p_vec = output.OMT.p_vec;

% Initialize OMT.messages_vec
OMT.messages_vec = zeros(31,1);

% Number of GUS sites in bits
num_GUS_sites_bits = ceil(log2(num_GUS_sites)); % Will be zero if same data key for all GUS sites

% OMT 1 - Current data level PK for this GUS site
M = data_key_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT1.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT1.bits/OTAR_bits);
end
OMT.messages_vec(1) = temp2;

% OMT 2 - Signature for OMT 1 signed with root PK for this GUS site
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT2.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT2.bits/OTAR_bits);
end
OMT.messages_vec(2) = temp2;

% OMT 3 - Expiration time of current data level PK and root PK for this GUS site
M = 34*2;   % 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for the data level PK and root PK
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT3.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT3.bits/OTAR_bits);
end
OMT.messages_vec(3) = temp2;

% OMT 4 - Signature of OMT 3 signed with root PK for this GUS site
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT4.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT4.bits/OTAR_bits);
end
OMT.messages_vec(4) = temp2;

% OMT 5 - Next data level PK for this GUS site
M = data_key_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT5.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT5.bits/OTAR_bits);
end
OMT.messages_vec(5) = temp2;

% OMT 6 - Signature of OMT 5 signed with root PK for this GUS site
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT6.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT6.bits/OTAR_bits);
end
OMT.messages_vec(6) = temp2;

% OMT 7 - Expiration time of next data level PK and root PK for this GUS site
M = 34*2;   % 34 = 20 TOW + 10 GPS WN + 4 Rollover. x2 for the data level PK and root PK
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT7.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT7.bits/OTAR_bits);
end
OMT.messages_vec(7) = temp2;

% OMT 8 - Signature of OMT 7 signed with root PK for this GUS site
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT8.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT8.bits/OTAR_bits);
end
OMT.messages_vec(8) = temp2;

if num_GUS_sites > 1
    
    % OMT 16 - Current data level PK for all GUS sites
    M = num_GUS_sites*data_key_length_bits + num_GUS_sites*num_GUS_sites_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT16.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT16.bits/OTAR_bits);
    end
    OMT.messages_vec(16) = temp2;
    
    % OMT 17 - Signature for OMT 16 signed with root PK for all GUS sites
    M = root_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT17.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT17.bits/OTAR_bits);
    end
    OMT.messages_vec(17) = temp2;
    
    % OMT 18 - Expiration time of current data level PK for all GUS site
    M = 34*num_GUS_sites + num_GUS_sites*num_GUS_sites_bits;   % 34 = 20 TOW + 10 GPS WN + 4 Rollover. xnum_GUS_sites for all GUS sites
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT18.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT18.bits/OTAR_bits);
    end
    OMT.messages_vec(18) = temp2;
    
    % OMT 19 - Signature of OMT 18 signed with root PK for all GUS sites
    M = root_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT19.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT19.bits/OTAR_bits);
    end
    OMT.messages_vec(19) = temp2;
    
    % OMT 20 - Next data level PK for all GUS site
    M = num_GUS_sites*data_key_length_bits + num_GUS_sites*num_GUS_sites_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT20.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT20.bits/OTAR_bits);
    end
    OMT.messages_vec(20) = temp2;
    
    % OMT 21 - Signature of OMT 20 signed with root PK for all GUS sites
    M = root_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT21.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT21.bits/OTAR_bits);
    end
    OMT.messages_vec(21) = temp2;
    
    % OMT 22 - Expiration time of next data level PK for all GUS sites
    M = 34*num_GUS_sites + num_GUS_sites*num_GUS_sites_bits;   % 34 = 20 TOW + 10 GPS WN + 4 Rollover. xnum_GUS_sites for all GUS sites
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT22.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT22.bits/OTAR_bits);
    end
    OMT.messages_vec(22) = temp2;
    
    % OMT 23 - Signature of OMT 7 signed with root PK for this GUS site
    M = root_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT23.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT23.bits/OTAR_bits);
    end
    OMT.messages_vec(23) = temp2;
    
end

% OMT 28 - Private key to unlock current root PK and root PK signature specified in message
M = 10 + 256;   % AES 256 with 256 bit key and 10 bit key identifier
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT28.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT28.bits/OTAR_bits);
end
OMT.messages_vec(28) = temp2;

% OMT 29 - Signature of OMT 28 signed with root PK
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT29.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT29.bits/OTAR_bits);
end
OMT.messages_vec(29) = temp2;

% OMT 30 - Private key to unlock next root PK and root PK signature specified in message
M = 10 + 256;   % AES 256 with 256 bit key and 10 bit key identifier
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT30.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT30.bits/OTAR_bits);
end
OMT.messages_vec(30) = temp2;

% OMT 31 - Signature of OMT 30 signed with root PK
M = root_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT31.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT31.bits/OTAR_bits);
end
OMT.messages_vec(31) = temp2;

%% Define groups of messages that will be used for post processing
if num_GUS_sites > 1
    OMT.message_groups_str = {...
        'Total',...
        'current level 2 PK',...
        'current level 2 PK exp',...
        'next level 2 PK',...
        'next level 2 PK exp',...
        'all current level 2 PK',...
        'all current level 2 PK exp',...
        'all next level 2 PK',...
        'all next level 2 PK exp',...
        'current private key',...
        'next private key'};
    
    OMT.message_groups{1} = [1:8, 16:23, 28:31];    % Total
    OMT.message_groups{6} = 16:17;      % all current level 2 PK
    OMT.message_groups{7} = 18:19;      % all current level 2 PK exp
    OMT.message_groups{8} = 20:21;      % all next level 2 PK
    OMT.message_groups{9} = 22:23;      % all next level 2 PK exp
    OMT.message_groups{10} = 28:29;     % current private key
    OMT.message_groups{11} = 30:31;     % next private key
else
    OMT.message_groups_str = {...
        'Total',...
        'current level 2 PK',...
        'current level 2 PK exp',...
        'next level 2 PK',...
        'next level 2 PK exp',...
        'current private key',...
        'next private key'};
    OMT.message_groups{1} = [1:8, 28:31];   % Total
    OMT.message_groups{6} = 28:29;  % current private key
    OMT.message_groups{7} = 30:31;  % next private key
end
OMT.message_groups{2} = 1:2;    % current level 2 PK
OMT.message_groups{3} = 3:4;    % current level 2 PK exp
OMT.message_groups{4} = 5:6;    % next level 2 PK
OMT.message_groups{5} = 7:8;    % next level 2 PK exp



end