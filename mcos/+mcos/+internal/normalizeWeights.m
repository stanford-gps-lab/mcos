function weights = normalizeWeights(inputWeights, weightAllocation)
% weights = normalizeWeights(originalWeights, weightAllocation)
%
% originalWeights is in the form of an array (of any length). This function
% simply normalizes the weights that are input and puts them in the slots
% allocated by weightAllocation. weightAllocation is a cell array that has
% the same number of columns as there are values in originalWeights. Each
% cell has an array that denotes which OMT (or sub-OMT) the weights in
% originalWeights are allocated to.

% Number of different sets of weights
[numSets, ~] = size(inputWeights);
numOMTs = max(cell2mat(weightAllocation));

% Preallocate
weights = zeros(numSets, numOMTs);

% Distribute originalWeights into each set of messages in weightAllocation
for j = 1:numSets
    for i = 1:length(weightAllocation)
        weights(j,weightAllocation{i}) = inputWeights(j,i)./length(weightAllocation{i});
    end
end

% Normalize all weights
for i = 1:numSets
    weights(i,:) = weights(i,:)./sum(weights(i,:));
end

end