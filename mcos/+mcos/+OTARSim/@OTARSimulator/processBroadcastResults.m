function obj = processBroadcastResults(obj, configParameters, omtConfiguration, iteration)
% obj = processBroadcastResults(obj, configParamters, omtConfiguration, iteration)
%
% Carrier out the post-processing of the results generated from
% simulateBroadast

% Useful variables
subMessages = obj.SubMessageResults{iteration};
tba = configParameters.TBA;
rowCells = obj.OTARBroadcast{iteration}.RowCells;

% From the subMessages, calculate the time it takes to receive each message
% in seconds
for i = omtConfiguration.OMTInd
    % TODO: Preallocate timeResults
    timeResults(:,:,i) = max(subMessages(:,:,rowCells{i}), [], 3, 'includenan').*tba;
end

% Calculate group time results
groupTimeResults = getGroupTimeResults(omtConfiguration, timeResults);

% Calculate how many users were simulated that received a full message
% digest
totalNumUsers = getTotalNumUsers(obj, groupTimeResults);

% Calculate the average time for each OMT
omtTimeAverages = getOMTTimeAverages(omtConfiguration, timeResults);

% Calculate the average time for each group of OMTs in seconds
groupTimeAverages = getGroupTimeAverages(omtConfiguration, groupTimeResults);







% Record results
obj.TimeResults{iteration} = timeResults;
obj.GroupTimeResults{iteration} = groupTimeResults;
obj.TotalNumUsers{iteration} = totalNumUsers;
obj.OMTTimeAverages{iteration} = omtTimeAverages;
obj.GroupTimeAverages{iteration} = groupTimeAverages;

end

function groupTimeResults = getGroupTimeResults(omtConfiguration, timeResults)
% Useful variables
omtUniqueGroups = omtConfiguration.OMTUniqueGroups;

% Calculate groupTimeResults
groupTimeResults = cell(length(omtUniqueGroups),1);
for i = 1:length(omtUniqueGroups)
    groupTimeResults{i} = max(timeResults(:,:,omtConfiguration.PlottingGroups{i}), [], 3, 'includenan');
end

end

function totalNumUsers = getTotalNumUsers(obj, groupTimeResults)
% Useful variables
omtUniqueGroups = obj.OMTUniqueGroups;

% Find which group is total
totalInd = strcmp(omtUniqueGroups, 'Total');

% Find the number of users that received a full message digest
totalNumUsers = sum(~isnan(groupTimeResults{totalInd}));


end

function omtTimeAverages = getOMTTimeAverages(omtConfiguration, timeResults)

omtTimeAverages = zeros(omtConfiguration.MaxOMTNum, 1);
for i = omtConfiguration.OMTInd
    omtTimeAverages(i) = nanmean(nanmean(timeResults(:,:,i)));
end

end

function groupTimeAverages = getGroupTimeAverages(obj, groupTimeResults)
% Useful variables
omtUniqueGroups = obj.OMTUniqueGroups;

% Calculate groupTimeAverages
groupTimeAverages = cell(length(omtUniqueGroups),1);
for i = 1:length(omtUniqueGroups)
    groupTimeAverages{i} = nanmean(nanmean(groupTimeResults{i}));
end

end















