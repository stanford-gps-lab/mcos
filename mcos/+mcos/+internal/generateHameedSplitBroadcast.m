function [broadcastArray, broadcastMessageNum, rowCells] = generateHameedSplitBroadcast(configParameters, omtConfiguration)
% Generate broadcast array using algorithm from "Hameed - Efficient
% algorithms for scheduling data broadcast"
% Much of this is straight taken from the original code

% Useful variables
maxSubOMTNum = sum(omtConfiguration.OMTNumFrames);

% Read Weights from WeightsVector
weights = configParameters.Weights;

%% Generate data stream using Hameed algorithm
% Generate eVec and sVec
eVec = generateEVec(configParameters, omtConfiguration);
subWeights = normalizeSubWeights(omtConfiguration, weights);
sVec = generateSVec(subWeights, omtConfiguration, eVec);

% Initialize bVec
bVec = zeros(maxSubOMTNum, 1);

% Initialize cVec
cVec = bVec;
for i = 1:maxSubOMTNum
    cVec(i) = sVec(i);
end

% Calculate which row each message starts in the broadcast matrix
columnStartVector = zeros(omtConfiguration.MaxOMTNum, 1);
columnStartVector(1) = 1;
for i = omtConfiguration.OMTInd(2:end)
    temp = find(flip(columnStartVector), 1);
    columnStartVector(i) = omtConfiguration.OMTNumFrames(omtConfiguration.MaxOMTNum + 1 - temp) + ...
        columnStartVector(omtConfiguration.MaxOMTNum + 1 - temp);
end

% Calculate which rows correspond to each message
rowCells = cell(omtConfiguration.MaxOMTNum, 1);
for i = omtConfiguration.OMTInd
    rowCells{i} = columnStartVector(i):columnStartVector(i) +  omtConfiguration.OMTNumFrames(i) - 1;
end

% Initialize Time
t = 1; % Time counter (Units of TBA)

% Initialize message tracker
m = 0; % Message counter used for outputing which messages happened in what order

% Initialize broadcast matrix
maxNumFrames = max(omtConfiguration.OMTNumFrames); % Find maximum number of frames for a specific OMT
broadcastArray = zeros(configParameters.SimLength + maxNumFrames, 1, 'int16');  % The last addition of maxNumFrames is to give buffer just in case there is a run over of t over configParameters.SimLength
broadcastMessageNum = zeros(configParameters.SimLength + maxNumFrames, 1, 'int16'); % Extra buffer, will be slimmed down eventually

% Initialize inSVec
inSVec = zeros(maxSubOMTNum, 1);

while t < configParameters.SimLength
    % Increment m
    m = m + 1;
    
    % Step 1 - Determine set of S of items for which B_i <= T
    
    for i = 1:maxSubOMTNum
        if bVec(i) <= t
            inSVec(i) = 1;
        end
    end
    
    % Step 2 - Find cMin
    
    % Initialize a cMinFinder to find cMin in set of S. All OMTs that are
    % not in S have values set to inf.
    cMinFinder = ones(maxSubOMTNum, 1)*inf;
    
    for i = 1:maxSubOMTNum
        if inSVec(i) == 1
            cMinFinder(i) = cVec(i);
        else
            cMinFinder(i) = inf;
        end
    end
    
    % Step 3 - Choose one item that has C_j = cMin
    
    [~, cMinI] = min(cMinFinder);   % Choose which item will be broadcast
    
    broadcastMessageNum(m) = cMinI;     % Output message number for debug/plotting purposes
    
    % Step 4 Broadcast item j at time t
    % Step 5 When item j completes transmission, t = t + l_j
    
    % In each check: check if it is the item being broadcast, updateB_j and
    % C_j, Release each portion of the message in a for loop, then update t
    bVec(cMinI) = cVec(cMinI);
    cVec(cMinI) = bVec(cMinI) + sVec(cMinI);
    broadcastArray(t) = cMinI;
    t = t + 1;
    
    % Clear set S
    inSVec = zeros(maxSubOMTNum, 1);
end

broadcastArray = broadcastArray(broadcastArray ~= 0);
broadcastMessageNum = broadcastMessageNum(broadcastMessageNum ~= 0);

end

function eVec = generateEVec(configParameters, omtConfiguration)
% Find the error probability for each OMT (item)
maxSubOMTNum = sum(omtConfiguration.OMTNumFrames);

eVec = zeros(maxSubOMTNum, 1);
for i = 1:maxSubOMTNum
    eVec(i) = configParameters.PER;
end

end

function subWeights = normalizeSubWeights(omtConfiguration, weights)
% Distribute the normalized message weights into subMessage weights
k = 1;
temp = cumsum(omtConfiguration.OMTNumFrames);
subWeights = zeros(temp(end), 1);
for i = omtConfiguration.OMTInd
    for j = k:temp(i)
        subWeights(j) = weights(i)/omtConfiguration.OMTNumFrames(i);
    end
    k = temp(i) + 1;
end

end

function sVec = generateSVec(subWeights, omtConfiguration, eVec)
% Find SVector from Hameed et al.
maxSubOMTNum = sum(omtConfiguration.OMTNumFrames);

% Find first half of equation (5)
temp = 0;
for i = 1:maxSubOMTNum
    temp = temp + sqrt(subWeights(i)*(1 + eVec(i))/(1 - eVec(i)));
end

% Find S for each OMT
sVec = zeros(maxSubOMTNum, 1);
for i = 1:maxSubOMTNum
    sVec(i) = temp*sqrt((1/subWeights(i))*(1 - eVec(i))/(1 + eVec(i)));
end

end
