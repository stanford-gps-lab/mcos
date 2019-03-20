function [omtFullLength, omtHeaderBits, omtNumFrames] = getOMTFullLength(omtConfig, configParameters)
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

% Calculate the full number of bits required for each OMT
for i = 1:length(omtNum)
   M = omtDataLength(i);    % Grab OMTDataLength
%    temp1 = ceil(M/configParameters.OTARMessageLengthBits) + 1;
%    temp2 = ceil(M/configParameters.OTARMessageLengthBits);
   % TODO: Grab this information from subclass SBASAuthenticationMessage
end








end