function broadcastArray = generateHameedStandardBroadcast(configParameters, weights, omtConfiguration)
% Generate broadcast array using algorithm from "Hameed - Efficient
% algorithms for scheduling data broadcast"

% Number of possible messages less message 0
[~, numMessages] = size(weights);

% Index messageFieldsInd
messageFieldsInd = weights ~= 0;

% Initialize bVec
bVec = zeros(numMessages, 1);

% Initialize cVec
cVec = bVec;
for i = messageFieldsInd
   cVec(i) =  
end
    
    
end

function sVec = generateSVec(configParameters, weights, messageFieldsInd, omtConfiguration)
% Find first half of equation (5)
temp = 0;
for i = messageFieldsInd
   temp = temp + sqrt(weights(i)*) 
end
% TODO: Fix OMTConfiguration so the cell locations are related to the
% message number


end