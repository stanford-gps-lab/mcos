function obj = completeOMTConfiguration(obj, configParameters)
% getOMTFullLength - a function that calculates the number of bits required
% to deliver each OMT. Extra bits are required to identify which OMT is
% being delivered, which sub-message is being delivered, and if there are
% more than one data-level public keys in use because each Master Station
% is using a different key a data field for how many different keys are in
% use. Also known as NumDiffKeys set in config.m.

% Useful variables
obj.OMTInd = cell2mat(obj.OMTNum(cell2mat(obj.OMTDataLengthBits) ~= 0))'; % Grab the index of non-zero OMTs

% Calculate how many bits needed for the OMT Header
maxOMTNum = max(cell2mat(obj.OMTNum));
obj.OMTHeaderBits = ceil(log2(maxOMTNum));

% Grab how many bits are availabe in OTAR Message
otarWordLengthBits = obj.SBASAuthenticationMessage.OTARWordLengthBits;

% Calculate NumDiffKeysBits
obj.NumDiffKeysBits = ceil(log2(configParameters.NumDiffKeys));

% Calculate the full number of bits required for each OMT
for i = obj.OMTInd
    temp1 = ceil(obj.OMTDataLengthBits{i}/otarWordLengthBits) + 1;
    temp2 = temp1 - 1;
    while temp1 ~= temp2
        temp1 = temp2;
        obj.OMTSequenceNumBits(i,1) = ceil(log2(temp1));    % How many bits required for the sequence number if there are more than one OTAR frames for an OMT Message
        obj.OMTFullLengthBits(i,1) = temp1*...
            (obj.OMTHeaderBits + obj.NumDiffKeysBits + obj.OMTSequenceNumBits(i))...
            + obj.OMTDataLengthBits{i};
        temp2 = ceil(obj.OMTFullLengthBits(i)/otarWordLengthBits); % OMTNumFrames, if another frame is needed, the OTMSequenceNumBits might increase making this process iterative.
    end
    obj.OMTNumFrames(i,1) = temp2;
end


end