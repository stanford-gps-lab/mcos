function obj = organizeOMTMessages(obj)
% obj = organizeOMTMessages(obj)
% 
% Organize the OMT Messages for post-processing

% Concatenate OMTGroups and find unique groups
temp = {};
for i = 1:obj.MaxOMTNum
    temp = [temp, obj.OMTGroupAssignments{i}];
end
obj.OMTUniqueGroups = unique(temp);

% Assign which messages are included in which group
obj.PlottingGroups = getPlottingGroups(obj);


end

function plottingGroups = getPlottingGroups(obj)
% Loop through unique messages
for j = 1:length(obj.OMTUniqueGroups)
    plottingGroups{j} = [];
    % Loop through messages
    for i = 1:obj.MaxOMTNum
        if any(strcmp(obj.OMTGroupAssignments{i}, obj.OMTUniqueGroups{j}))
            plottingGroups{j} = [plottingGroups{j}, cell2mat(obj.OMTNum(i))];
        end
    end
end


end