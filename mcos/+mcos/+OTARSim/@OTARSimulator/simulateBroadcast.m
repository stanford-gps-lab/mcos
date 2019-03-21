function obj = simulateBroadcast(obj, configParameters, iteration)
% obj = simulateBroadcast(configParameters, omtConfiguration, iteration)
%
% Simulate the broadcast using toeplitz matrices on the previously
% generated blocks. This code was copied almost exactly from the old code.

% waitbar
if configParameters.DisplayOn
   bWaitbar = waitbar(0, 'Simulating User Experience...');  % Initialize waitbar 
end

% Useful variables
blockRowNum = obj.BlockRowNum;
broadcastMatrix = obj.BroadcastMatrix;
numUsers = configParameters.NumUsers;
per = configParameters.PERVector(iteration);
totalNumMessages = obj.TotalNumMessages;
blockSize = obj.BlockSize;

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
    
    for i = 1:totalNumMessages % Loop through all sub messages (I know, for loops suck, but it was the only loop I couldn't figure out how to get rid of)
        % Record when messages were received and NaN results that weren't
        % received
        [temp1, temp2] = max(subMessageSimMat == i, [], 2);
        temp1 = double(temp1);  % Convert temp1 into a class double matrix
        temp1(temp1 == 0) = NaN;    % Convert zero values to NaN because no max was found
        temp3 = squeeze(temp1.*temp2);  % Finish converting values with no max to NaN
        
        % Record subMessage results
        obj.SubMessageResults{iteration}((j-1)*blockSize + 1:j*blockSize, :, i) = single(temp3);    % Save space and store as a single-precision floating point. Has NaN so need floating point precision
        
        if configParameters.DisplayOn
           waitbar((i + (j-1)*totalNumMessages)/(totalNumMessages*blockRowNum),...
               bWaitbar,...
               ['Looping through block ', num2str(j), ' of ', num2str(blockRowNum)]); 
        end
        
    end
end

if configParameters.DisplayOn
   close(bWaitbar) 
end

end