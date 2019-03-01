function Loop_output = OTAR_loop_post(run_param, Loop_output)
% Grabs relevent parameters from loop_output of OTAR_loop and
% post-processes them.


%% Extract out required information (build matrices: rows = user_loop; columns = sim_length
% Extract values
for k = 1:length(run_param.OTAR_num_vec)
    for j = 1:length(run_param.user_loop_vec)
        for i = 1:run_param.sim_loop
            if isfield(Loop_output.sim_length(k).user_loop(j).sim_loop(i),'total_average') && isfield(Loop_output.sim_length(k).user_loop(j).sim_loop(i),'level2_average')
                % Average
                Loop_output.total_average(j,k,i) =  Loop_output.sim_length(k).user_loop(j).sim_loop(i).total_average;
                if strcmp(run_param.scheme, 'ECDSA')
                    Loop_output.current_auth_PK_time_average(j,k,i) =  Loop_output.sim_length(k).user_loop(j).sim_loop(i).level2_average;
                end
            else
                Loop_output.total_average(j,k,i) =  NaN;
                if strcmp(run_param.scheme, 'ECDSA')
                    Loop_output.current_auth_PK_time_average(j,k,i) =  NaN;
                end
            end
        end
        % Average
        Loop_output.total_average_max(j,k) = max(Loop_output.total_average(j,k,:));
        if strcmp(run_param.scheme, 'ECDSA')
            Loop_output.current_auth_PK_time_average_max(j,k) =  max(Loop_output.current_auth_PK_time_average(j,k,:));
        end
    end
end

% Calculate errors
Loop_output.total_average_max_error = abs(Loop_output.total_average_max - Loop_output.total_average_max(end,end));
if strcmp(run_param.scheme, 'ECDSA')
    Loop_output.current_auth_PK_time_average_max_error = abs(Loop_output.current_auth_PK_time_average_max - Loop_output.current_auth_PK_time_average_max(end,end));
end











