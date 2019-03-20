function obj = completeOMTConfiguration(obj, omtConfig, configParameters, sbasAuthenticationMessage)
% getOMTFullLength - a function that calculates the number of bits required
% to deliver each OMT. Extra bits are required to identify which OMT is
% being delivered, which sub-message is being delivered, and if there are
% more than one data-level public keys in use because each Master Station
% is using a different key a data field for how many different keys are in
% use. Also known as NumDiffKeys set in config.m.

% Useful variables
omtNum = cell2mat(omtConfig(:,1));
omtDataLength = cell2mat(omtConfig(:,2));

% Calculate how many bits needed for the OMT Header
maxOMTNum = max(omtNum);
omtHeaderBits = ceil(log2(maxOMTNum));

% Grab how many bits are availabe in OTAR Message
omtLengthBits = sbasAuthenticationMessage.OTMLengthBits;

% Calculate the full number of bits required for each OMT
for i = 1:length(omtNum)
    M = omtDataLength(i);    % Grab OMTDataLength
    temp1 = ceil(M/omtLengthBits) + 1;
    temp2 = ceil(M/omtLengthBits);
    while temp1 ~= temp2
        temp1 = temp2;
        
        
    end
    % TODO: Grab this information from subclass SBASAuthenticationMessage
end








end