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
[temp, ~, ~] = size(subMessages);
omtTimeResults = NaN(temp, configParameters.NumUsers, omtConfiguration.MaxOMTNum);
for i = omtConfiguration.OMTInd
    omtTimeResults(:,:,i) = max(subMessages(:,:,rowCells{i}), [], 3, 'includenan').*tba;
end

% Calculate group time results
groupTimeResults = getGroupTimeResults(omtConfiguration, omtTimeResults);

% Calculate how many users were simulated that received a full message
% digest
totalNumUsers = getTotalNumUsers(obj, groupTimeResults);

% Calculate the average time for each OMT
omtTimeAverages = getOMTTimeAverages(omtConfiguration, omtTimeResults);

% Calculate the average time for each group of OMTs in seconds
groupTimeAverages = getGroupTimeAverages(omtConfiguration, groupTimeResults);

% Calculate the rest of the statistics for each OMT
[omtTimeMax, omtTimeMin, omtTimeMode, omtTimeStDev] = getOMTStatistics(omtConfiguration, omtTimeResults);

% Calculate the rest of the statistics for each group of OMTs
[groupTimeMax, groupTimeMin, groupTimeMode, groupTimeStDev] = getGroupStatistics(obj, groupTimeResults);

% Record results
obj.OMTTimeResults{iteration} = omtTimeResults;
obj.GroupTimeResults{iteration} = groupTimeResults;
obj.TotalNumUsers{iteration} = totalNumUsers;
obj.OMTTimeAverages{iteration} = omtTimeAverages;
obj.GroupTimeAverages{iteration} = groupTimeAverages;
obj.OMTTimeMax{iteration} = omtTimeMax;
obj.OMTTimeMin{iteration} = omtTimeMin;
obj.OMTTimeMode{iteration} = omtTimeMode;
obj.OMTTimeStDev{iteration} = omtTimeStDev;
obj.GroupTimeMax{iteration} = groupTimeMax;
obj.GroupTimeMin{iteration} = groupTimeMin;
obj.GroupTimeMode{iteration} = groupTimeMode;
obj.GroupTimeStDev{iteration} = groupTimeStDev;

end

function groupTimeResults = getGroupTimeResults(omtConfiguration, omtTimeResults)
% Useful variables
omtUniqueGroups = omtConfiguration.OMTUniqueGroups;

% Calculate groupTimeResults
groupTimeResults = cell(length(omtUniqueGroups),1);
for i = 1:length(omtUniqueGroups)
    groupTimeResults{i} = max(omtTimeResults(:,:,omtConfiguration.PlottingGroups{i}), [], 3, 'includenan');
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

function omtTimeAverages = getOMTTimeAverages(omtConfiguration, omtTimeResults)

omtTimeAverages = zeros(omtConfiguration.MaxOMTNum, 1);
for i = omtConfiguration.OMTInd
    omtTimeAverages(i) = nanmean(nanmean(omtTimeResults(:,:,i)));
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

function [omtTimeMax, omtTimeMin, omtTimeMode, omtTimeStDev] = getOMTStatistics(omtConfiguration, omtTimeResults)
% Calculate the rest of the user statistics for each OMT

% Preallocate
omtTimeMax = zeros(omtConfiguration.MaxOMTNum, 1);
omtTimeMin = zeros(omtConfiguration.MaxOMTNum, 1);
omtTimeMode = zeros(omtConfiguration.MaxOMTNum, 1);
omtTimeStDev = zeros(omtConfiguration.MaxOMTNum, 1);

for i = omtConfiguration.OMTInd
    temp = omtTimeResults(:,:,i);
    temp = temp(:);
    omtTimeMax(i) = nanmax(temp);
    omtTimeMin(i) = nanmin(temp);
    omtTimeMode(i) = mode(temp);
    omtTimeStDev(i) = nanstd(temp);
end

end

function [groupTimeMax, groupTimeMin, groupTimeMode, groupTimeStDev] = getGroupStatistics(obj, groupTimeResults)
% Useful variables
omtUniqueGroups = obj.OMTUniqueGroups;

% Preallocate
groupTimeMax = cell(length(omtUniqueGroups),1);
groupTimeMin = cell(length(omtUniqueGroups),1);
groupTimeMode = cell(length(omtUniqueGroups),1);
groupTimeStDev = cell(length(omtUniqueGroups),1);

% Calculate the rest of the statistics for each group of OMTs
for i = 1:length(omtUniqueGroups)
    temp = groupTimeResults{i};
    temp = temp(:);
    groupTimeMax{i} = nanmax(temp);
    groupTimeMin{i} = nanmin(temp);
    groupTimeMode{i} = mode(temp);
    groupTimeStDev{i} = nanstd(temp);
end

end













