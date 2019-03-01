function [run_param, output] = set_levels(run_param)
%% Set levels of parameters

% Create p_vec
run_param.levelstr = '';
output.OMT.p_vec = zeros(length(run_param.levels_vec),1);
for i = 1:length(run_param.levels)
    temp = run_param.levels_vec == run_param.levels_norm(i);
    output.OMT.p_vec(temp) = run_param.levels_vec(temp)./sum(temp);     % Create p_vec
    run_param.levelstr = [run_param.levelstr, num2str(round(run_param.levels(i)))];    % Create level string
    if i ~= length(run_param.levels)
        run_param.levelstr = [run_param.levelstr, '_'];
    end
end
end