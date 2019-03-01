function OMT = TESLA_OMT_bit_lengths(run_param, output)
% This function calculates the bit lengths of all OMTs for TESLA
% implementation. OMT0, OMT7 are not included because they are
% not going to be broadcast repeatedly.

% Break out structure
OTAR_bits = output.OTAR_bits;
OMT_header_bits = output.OMT_header_bits;
num_GUS_sites = run_param.num_GUS_sites;
TESLA_key_length_bits = run_param.TESLA_key_length_bits;
salt_length_bits = run_param.salt_length_bits;
level2_key_length_bits = run_param.level2_key_length_bits;
level2_sig_length_bits = output.level2_sig_length_bits;
level1_sig_length_bits = output.level1_sig_length_bits;

% Assign p_vec to OMT
OMT.p_vec = output.OMT.p_vec;

% Initialize OMT.messages_vec
OMT.messages_vec = zeros(31,1);

% Number of GUS sites in bits
num_GUS_sites_bits = ceil(log2(num_GUS_sites)); % Will be zero if same data key for all GUS sites

% OMT 1 - Current salt and root/intermediate keys for slow and fast for this GUS site
M = TESLA_key_length_bits*2 + salt_length_bits; % x2 for fast and slow key
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT1.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT1.bits/OTAR_bits);
end
OMT.messages_vec(1) = temp2;

% OMT 2 - Signature of OMT 1 with level 2 PK for this GUS
M = level2_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT2.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT2.bits/OTAR_bits);
end
OMT.messages_vec(2) = temp2;

% OMT 3 - Expiration for parameters in OMT 1 and OMT 5
M = 34*2; % fast/slow keychains and salt have same expiration time. 2nd is expiration of level 2 key
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT3.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT3.bits/OTAR_bits);
end
OMT.messages_vec(3) = temp2;

% OMT 4 - Signature of OMT 3 with level 1 PK
M = level1_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT4.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT4.bits/OTAR_bits);
end
OMT.messages_vec(4) = temp2;

% OMT 5 - Current level 2 PK for this GUS
M = level2_key_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT5.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT5.bits/OTAR_bits);
end
OMT.messages_vec(5) = temp2;

% OMT 6 - Signature for OMT 5 with level 1 PK
M = level1_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT6.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT6.bits/OTAR_bits);
end
OMT.messages_vec(6) = temp2;

% OMT 9 - Next salt and root/intermediate keys for slow and fast for this GUS
M = TESLA_key_length_bits*2 + salt_length_bits; % x2 for fast and slow key
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT9.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT9.bits/OTAR_bits);
end
OMT.messages_vec(9) = temp2;

% OMT 10 - Signature of OMT 9 with level 2 PK for this GUS
M = level2_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT10.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT10.bits/OTAR_bits);
end
OMT.messages_vec(10) = temp2;

% OMT 11 - Expiration for parameters in OMT 9 and OMT 13
M = 34*2; % fast/slow keychains and salt have same expiration time. 2nd is expiration of level 2 key
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT11.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT11.bits/OTAR_bits);
end
OMT.messages_vec(11) = temp2;

% OMT 12 - Signature of OMT 11 with level 1 PK
M = level1_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT12.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT12.bits/OTAR_bits);
end
OMT.messages_vec(12) = temp2;

% OMT 13 - Next level 2 PK for this GUS
M = level2_key_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT13.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT13.bits/OTAR_bits);
end
OMT.messages_vec(13) = temp2;

% OMT 14 - Signature for OMT 13 with level 1 PK
M = level1_sig_length_bits;
temp1 = ceil(M/OTAR_bits) + 1;
temp2 = ceil(M/OTAR_bits);
while temp1 ~= temp2
    temp1 = temp2;
    ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
    OMT.OMT14.bits = temp1*(OMT_header_bits + num_GUS_sites_bits + ID_num_bits) + M; % Total number of bits for full message
    temp2 = ceil(OMT.OMT14.bits/OTAR_bits);
end
OMT.messages_vec(14) = temp2;

if num_GUS_sites > 1
    
    % OMT 16 - Current salt and root/intermediate keys for slow and fast for all GUS
    M = (TESLA_key_length_bits*2 + salt_length_bits + num_GUS_sites_bits)*num_GUS_sites; % x2 for fast and slow key
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT16.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT16.bits/OTAR_bits);
    end
    OMT.messages_vec(16) = temp2;
    
    % OMT 17 - Signature of OMT 16 with level 1 PK
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT17.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT17.bits/OTAR_bits);
    end
    OMT.messages_vec(17) = temp2;
    
    % OMT 18 - Expiration for parameters in OMT 16 and OMT 20
    M = (34*2 + num_GUS_sites_bits)*num_GUS_sites; % fast/slow keychains and salt have same expiration time. 2nd is expiration of level 2 key
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT18.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT18.bits/OTAR_bits);
    end
    OMT.messages_vec(18) = temp2;
    
    % OMT 19 - Signature of OMT 18 with level 1 PK
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT19.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT19.bits/OTAR_bits);
    end
    OMT.messages_vec(19) = temp2;
    
    % OMT 20 - Current level 2 PK for all GUS
    M = (level2_key_length_bits + num_GUS_sites_bits)*num_GUS_sites;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT20.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT20.bits/OTAR_bits);
    end
    OMT.messages_vec(20) = temp2;
    
    % OMT 21 - Signature for OMT 20 with level 1 PK
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT21.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT21.bits/OTAR_bits);
    end
    OMT.messages_vec(21) = temp2;
    
    % OMT 22 - Next salt and root/intermediate keys for slow and fast for all GUS
    M = (TESLA_key_length_bits*2 + salt_length_bits + num_GUS_sites_bits)*num_GUS_sites; % x2 for fast and slow key
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT22.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT22.bits/OTAR_bits);
    end
    OMT.messages_vec(22) = temp2;
    
    % OMT 23 - Signature for OMT 22 with level 1 PK for all GUS
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT23.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT23.bits/OTAR_bits);
    end
    OMT.messages_vec(23) = temp2;
    
    % OMT 24 - Expiration for parameters in OMT 22 and OMT 26
    M = (34*2 + num_GUS_sites_bits)*num_GUS_sites; % fast/slow keychains and salt have same expiration time. 2nd is expiration of level 2 key
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT24.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT24.bits/OTAR_bits);
    end
    OMT.messages_vec(24) = temp2;
    
    % OMT 25 - Signature for OMT 24 with level 1 PK for all GUS
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT25.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT25.bits/OTAR_bits);
    end
    OMT.messages_vec(25) = temp2;
    
    % OMT 26 - Next level 2 PK for all GUS
    M = (level2_key_length_bits + num_GUS_sites_bits)*num_GUS_sites;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT26.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT26.bits/OTAR_bits);
    end
    OMT.messages_vec(26) = temp2;
    
    % OMT 27 - Signature for OMT 26 with level 1 PK
    M = level1_sig_length_bits;
    temp1 = ceil(M/OTAR_bits) + 1;
    temp2 = ceil(M/OTAR_bits);
    while temp1 ~= temp2
        temp1 = temp2;
        ID_num_bits = ceil(log2(temp1));    % Find how many bits needed for ID number, if one message needed, then no ID number required
        OMT.OMT27.bits = temp1*(OMT_header_bits + ID_num_bits) + M; % Total number of bits for full message
        temp2 = ceil(OMT.OMT27.bits/OTAR_bits);
    end
    OMT.messages_vec(27) = temp2;
    
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
M = level1_sig_length_bits;
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

% OMT 31 - Signature of OMT 31 signed with root PK
M = level1_sig_length_bits;
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
        'current keychains and salt',...
        'current keychains, salt, and level 2 PK exp',...
        'current level 2 PK',...
        'next keychains and salt',...
        'next keychains, salt, and level 2 PK exp',...
        'next level 2 PK',...
        'all current keychains and salt',...
        'all current keychains, salt, and level 2 PK exp',...
        'all current level 2 PK',...
        'all next keychains and salt',...
        'all next keychains, salt, and level 2 PK exp',...
        'all next level 2 PK',...
        'current private key',...
        'next private key'};
    
    OMT.message_groups{1} = [1:6, 9:14, 16:31];    % Total
    OMT.message_groups{8} = 16:17;    % all current keychains and salt
    OMT.message_groups{9} = 18:19;    % all current keychains, salt, and level 2 PK exp
    OMT.message_groups{10} = 20:21;    % all current level 2 PK
    OMT.message_groups{11} = 22:23;    % all next keychains and salt
    OMT.message_groups{12} = 24:25;    % all next keychains, salt, and level 2 PK exp
    OMT.message_groups{13} = 26:27;    % all next level 2 PK
    OMT.message_groups{14} = 28:29;     % current private key
    OMT.message_groups{15} = 30:31;     % next private key
else
    OMT.message_groups_str = {...
        'Total',...
        'current keychains and salt',...
        'current keychains, salt, and level 2 PK exp',...
        'current level 2 PK',...
        'next keychains and salt',...
        'next keychains, salt, and level 2 PK exp',...
        'next level 2 PK',...
        'current private key',...
        'next private key'};
    OMT.message_groups{1} = [1:6, 9:14, 28:31];   % Total
    OMT.message_groups{8} = 28:29;  % current private key
    OMT.message_groups{9} = 30:31;  % next private key
end
OMT.message_groups{2} = 1:2;    % current keychains and salt
OMT.message_groups{3} = 3:4;    % current keychains, salt, and level 2 PK exp
OMT.message_groups{4} = 5:6;    % current level 2 PK
OMT.message_groups{5} = 9:10;    % next keychains and salt
OMT.message_groups{6} = 11:12;    % next keychains, salt, and level 2 PK exp
OMT.message_groups{7} = 13:14;    % next level 2 PK


end