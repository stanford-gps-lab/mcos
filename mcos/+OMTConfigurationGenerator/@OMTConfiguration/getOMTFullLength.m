function [omtFullLength, omtHeaderBits] = getOMTFullLength(omtConfig, configParameters)
% getOMTFullLength - a function that calculates the number of bits required
% to deliver each OMT. Extra bits are required to identify which OMT is
% being delivered, which sub-message is being delivered, and if there are
% more than one data-level public keys in use because each Master Station
% is using a different key a data field for how many different keys are in
% use. Also known as NumDiffKeys set in config.m.

% Calculate how many bits needed for the OMT Header
maxOMTNum = max(cell2mat(omtConfig(:,1)));
omtHeaderBits = ceil(log2(maxOMTNum));








end