function [broadcastArray, broadcastMessageNum, rowCells] = generateHameedSemiRigidBroadcast(configParameters, omtConfiguration)
% Generate broadcast array using algorithm from "Hameed - Efficient
% algorithms for scheduling data broadcast"
% Much of this is straight taken from the original code

% Load information from the WeightingSchemeFile
currentDir = pwd;
cd +mcos/+BroadcastGenerator/weightingSchemeFiles;
load(configParameters.WeightingSchemeFile, 'maxFrameLatency', 'crucialMessages')
cd(currentDir)

% Read Weights from WeightsVector
weights = configParameters.Weights;

%% Generate data stream using Hameed algorithm
% Generate eVec and sVec
eVec = generateEVec(configParameters, omtConfiguration);
sVec = generateSVec(weights, omtConfiguration, eVec);

% Initialize bVec
bVec = zeros(omtConfiguration.MaxOMTNum, 1);

% Initialize cVec
cVec = bVec;
for i = omtConfiguration.OMTInd
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
inSVec = zeros(omtConfiguration.MaxOMTNum, 1);

% Initialize tCrucial
tCrucial = 1;

while t < configParameters.SimLength
    % Increment m
    m = m + 1;
    
    % Step 1 - Determine set of S of items for which B_i <= T
    
    for i = omtConfiguration.OMTInd
        if bVec(i) <= t
            inSVec(i) = 1;
        end
    end
    
    % Step 2 - Find cMin
    
    % Initialize a cMinFinder to find cMin in set of S. All OMTs that are
    % not in S have values set to inf.
    cMinFinder = ones(omtConfiguration.MaxOMTNum, 1)*inf;
    
    for i = omtConfiguration.OMTInd
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
    for j = 1:omtConfiguration.OMTNumFrames(cMinI)
        if any(cMinI == crucialMessages)
            tCrucial = 1; % Reset tCrucial
            for i = crucialMessages
                % Track which messages are being delivered
                m = m + 1;
                broadcastMessageNum(m) = crucialMessages(i);
                
                % Change bVec and cVec
                cVec(crucialMessages(i)) = min(cVec(cVec ~= 0));
                bVec(crucialMessages(i)) = cVec(crucialMessages(i));
                cVec(crucialMessages(i)) = bVec(crucialMessages(i)) + sVec(crucialMessages(i));
                
                for k = 1:omtConfiguration.OMTNumFrames(crucialMessages(i))
                    % Broadcast crucial message(s)
                    broadcastArray(t) = columnStartVector(crucialMessages(i)) + k - 1;
                    t = t + 1;
                    tCrucial = tCrucial + 1;
                end
            end
        else
            broadcastArray(t) = columnStartVector(cMinI) + j - 1;    % Broadcast array writes each sub message to be broadcast
            t = t + 1;
            if any(cMinI == crucialMessages) && (j == omtConfiguration.OMTNumFrames(cMinI))
                tCrucial = sum(omtConfiguration.OMTNumFrames(crucialMessages));
            else
                tCrucial = tCrucial + 1; % Keep track of frames since last imporatant message start
            end
            if tCrucial > maxFrameLatency
                tCrucial = 1; % Reset tCrucial
                for i = crucialMessages
                    % Track which messages are being delivered
                    m = m + 1;
                    broadcastMessageNum(m) = crucialMessages(i);
                    
                    % Change bVec and cVec
                    cVec(crucialMessages(i)) = min(cVec(cVec ~= 0));
                    bVec(crucialMessages(i)) = cVec(crucialMessages(i));
                    cVec(crucialMessages(i)) = bVec(crucialMessages(i)) + sVec(crucialMessages(i));
                    
                    for k = 1:omtConfiguration.OMTNumFrames(crucialMessages(i))
                        % Broadcast crucial message(s)
                        broadcastArray(t) = columnStartVector(crucialMessages(i)) + k - 1;
                        t = t + 1;
                        tCrucial = tCrucial + 1;
                    end
                end
            end
        end
    end
    
    % Clear set S
    inSVec = zeros(omtConfiguration.MaxOMTNum, 1);
end

broadcastArray = broadcastArray(broadcastArray ~= 0);
broadcastMessageNum = broadcastMessageNum(broadcastMessageNum ~= 0);

end

function eVec = generateEVec(configParameters, omtConfiguration)
% Find the error probability for each OMT (item)

eVec = zeros(omtConfiguration.MaxOMTNum, 1);
for i = omtConfiguration.OMTInd
    eVec(i) = 1 - (1 - configParameters.PER)^omtConfiguration.OMTNumFrames(i);
end

end

function sVec = generateSVec(weights, omtConfiguration, eVec)
% Find SVector from Hameed et al.

% Find first half of equation (5)
temp = 0;
for i = omtConfiguration.OMTInd
    temp = temp + sqrt(weights(i)*omtConfiguration.OMTNumFrames(i)*(1 + eVec(i))/(1 - eVec(i)));
end

% Find S for each OMT
sVec = zeros(omtConfiguration.MaxOMTNum, 1);
for i = omtConfiguration.OMTInd
    sVec(i) = temp*sqrt((omtConfiguration.OMTNumFrames(i)/weights(i))*(1 - eVec(i))/(1 + eVec(i)));
end

end











