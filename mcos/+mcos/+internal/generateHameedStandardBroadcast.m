function broadcastArray = generateHameedStandardBroadcast(configParameters, weights, omtConfiguration, iteration)
% Generate broadcast array using algorithm from "Hameed - Efficient
% algorithms for scheduling data broadcast"

% Number of possible messages less message 0
[~, numMessages] = size(weights);

% Initialize bVec
bVec = zeros(numMessages, 1);

% Initialize cVec
cVec = bVec;
for i = omtConfiguration.OMTInd
    cVec(i) =
end


end

function eVec = generateEVec(configParameters, omtConfiguration, iteration)
% Find the error probability for each OMT (item)

eVec = zeros(omtConfiguration.MaxOMTNum, 1);
for i = omtConfigurationOMTInd
    eVec(i) = 1 - (1 - configParameters.PER(iteration))^omtConfiguration.OMTNumFrames(i);
end

end

function sVec = generateSVec(weights, messageFieldsInd, omtConfiguration)
% Find first half of equation (5)
temp = 0;
for i = messageFieldsInd
    temp = temp + sqrt(weights(i)*omtConfiguration.OMTNumFrames(i)*(1 + eVec(i))/(1 - eVec));
end


end