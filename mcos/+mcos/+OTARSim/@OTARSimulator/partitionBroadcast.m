function obj = partitionBroadcast(obj, configParameters, omtConfiguration, iteration)
% obj = partitionBroadcast(obj)
%
% Partitions the generated broadcast into blocks making simulations much
% faster
% Much of this code is taken from the Old Code

% Useful variables
totalNumMessages = sum(omtConfiguration.OMTNumFrames);
broadcastArray = obj.OTARBroadcast{iteration}.BroadcastArray;
per = configParameters.PERVector(iteration);

% Set the blockSize
blockFlag = 0;
if configParameters.SimLength > configParameters.PartitionBlockSize
    blockSize = configParameters.PartitionBlockSize;
else
    blockSize = length(broadcastArray);
    configParameters.PartitionBlockSize = blockSize;    % Overwrite configParameters to show what was actually run
    blockRowNum = 1;
    broadcastMatrix = broadcastArray';
    perBlock = int16(rand(1, blockSize) > per);
    if (sum(unique(obj.OTARBroadcast{iteration}.BroadcastArray.*perBlock)) ~= sum(1:totalNumMessages))
        error('Input larger simulation length')
    end
    blockFlag = 1;
end

% Break the broadcast array into blocks
while ~blockFlag
    
    % Break broadcast arrays into blocks
    blockRowNum = floor(length(broadcastArray)/blockSize);
    broadcastMatrix = reshape(broadcastArray(1:end - rem(length(broadcastArray), blockSize)), [blockSize, blockRowNum])';
    perBlock = int16(rand(1, blockSize) > per);
    
    % Test blocks to see if they carry all messages. Increase their size if
    % they do not carry all messages.
    for i = 1:blockRowNum - 1
        blockFlag = 1;
        if (sum(unique(broadcastMatrix(i,:).*perBlock)) ~= sum(1:totalNumMessages)) % Test if all messages are in each row
            blockSize = blockSize + 1000;
            configParameters.PartitionBlockSize = blockSize;    % Overwrite configParameters to show what was actually run
            if blockSize > length(broadcastArray)
                error('Input larger simulation length')
            end
            blockFlag = 0;
            break
        end
    end
    
    if (blockRowNum == 1)   % If the original block is the only one that works, let it pass on for simulation
        if (sum(unique(broadcastArray)) ~= sum(1:totalNumMessages))
            error('Input larger simulation length')
        else
            broadcastMatrix = broadcastArray';
            blockSize = length(broadcastArray);
            blockFlag = 1;
        end
    end
    
end
broadcastArray = broadcastArray(1:end - rem(length(broadcastArray), blockSize));

% Report results
obj.OTARBroadcast{iteration}.BroadcastArray = broadcastArray;  % Replace BroadcastArray to show the broadcastArray that was carried out in simulation.







end