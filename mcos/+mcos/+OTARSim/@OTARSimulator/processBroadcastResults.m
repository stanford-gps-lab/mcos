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
    timeResults(:,:,i) = max(subMessages(:,:,rowCells{i}), [], 3, 'includenan').*tba;
end

% Calculate group time results
groupTimeResults = getGroupTimeResults(omtConfiguration, timeResults);







% Record results
obj.TimeResults{iteration} = timeResults;
obj.OMTUniqueGroups = omtConfiguration.OMTUniqueGroups;
obj.GroupTimeResults{iteration} = groupTimeResults;

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















