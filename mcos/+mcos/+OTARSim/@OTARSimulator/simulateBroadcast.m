function obj = simulateBroadcast(obj, configParameters, omtConfiguration, iteration)
% obj = simulateBroadcast(configParameters, omtConfiguration, iteration)
%
% Simulate the broadcast using toeplitz matrices on the previously
% generated blocks. This code was copied almost exactly from the old code.

% Useful variables
blockRowNum = obj.BlockRowNum;
broadcastMatrix = obj.BroadcastMatrix;
numUsers = configParameters.NumUsers;
per = configParameters.PERVector(iteration);

for j = 1:blockRowNum
    
    % Grab broadcastSubArray
    broadcastSubArray = broadcastMatrix(j,:);
    
    % Create PER matrix to simulate missed messages
    perMat = int16(rand(length(broadcastSubArray), length(broadcastSubArray), numUsers) > per);
    
    if j == blockRowNum     % Final block
        % Create matrix that creates different 'start times' for different
        % users.
        subMessageSimMat = tril(toeplitz(fliplr(broadcastSubArray))); % Create lower triangular toeplitz matrix to create different 'start times' for this submessage
        subMessageSimMat = repmat(subMessageSimMat, [1, 1, numUsers]);  % Replicate this message out for number of users specified in config.m
    else
        % Create matrix that creates different 'start times' for different
        % users. Fill in upper part of triangle for blocks.
        subMessageSimMat = tril(toeplitz(fliplr(broadcastSubArray))); % Create lower triangular toeplitz matrix to create different 'start times' for this submessage
        temp = [broadcastSubArray(end), broadcastMatrix(j+1, 1:end-1)];
        subMessageSimMat = subMessageSimMat + triu(toeplitz(temp), 1);     % Fill in for zeros of upper triangular matrix to complete the block
        subMessageSimMat = repmat(subMessageSimMat, [1, 1, numUsers]);
    end
    
    % dot-multiply perMat with subMessageSimMat to simulate missed messages
    subMessageSimMat = subMessageSimMat.*perMat;
end



end