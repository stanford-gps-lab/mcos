function Loop_output = OTAR_loop_plot(run_param, Loop_output)


% Plot surface plot of max averages
figure
plot(run_param.OTAR_num_vec, Loop_output.total_average_max_error)
xlabel('Simulation Length [Messages]')
ylabel('Simulation Error [seconds]')
title('Error of total average')




end