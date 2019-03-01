function output = ECDSA_sim_plot(run_param, output)

% Break out structure
user_results = output.user_results;
extra = output.extra;
OMT = output.OMT;
plots = run_param.plots;
num_GUS_sites = run_param.num_GUS_sites;
message_fields = output.message_fields;

tic
if run_param.disp_on
    disp('Plotting Simulation Results...')
end

%% Plot histogram with Gaussian overlay plot for each OMT, total time and grouping
dim = [0.59, 0.61, 0.3, 0.3]; % Textbox dimensions

% Total time
if any(strcmp(run_param.plots, 'Total'))
    temp = user_results.total.time(:); % Put all elements in a vector
%     norm_x = [0:user_results.total.max_time];
%     pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
%     norm = pdf(pd, norm_x);
    ECDSA_sim_plots.total_hist = figure;
    hold on
%     yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
%     yyaxis right
%     plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
%     ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title('Total time to receive full OTAR digest')
    str = {['Average time: ', num2str(user_results.total.average_time), 's'];...
        ['Mode time: ', num2str(user_results.total.mode_time), 's'];...
        ['Min time: ', num2str(user_results.total.min_time), 's'];...
        ['Max time: ', num2str(user_results.total.max_time), 's']};
    annotation('textbox', [0.2, 0.61, 0.3, 0.3], 'String', str, 'FitBoxToText', 'on')
end

% Plot OMT Histograms
if any(strcmp(run_param.plots, 'OMT'))
    for i = message_fields
        temp = user_results.time(i,:,:);
        temp = temp(:);     % Put all elements in a vector
        norm_x = [0:user_results.max_time_vec(i)];
        pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
        norm = pdf(pd, norm_x);
        ECDSA_sim_plots.OMT_hist{i} = figure;
        hold on
        yyaxis left
        histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
        ylabel('Normalized Histogram')
        yyaxis right
        plot(norm_x + min(temp) - 1, norm)
        xlim([0, inf])
        ylabel('Normalized Log-Logistic pdf')
        xlabel('Seconds')
        str = ['Time to receive OMT', num2str(i)];
        title(str)
        str = {['Average time: ', num2str(user_results.average_time_vec(i)), 's'];...
            ['Mode time: ', num2str(user_results.mode_time_vec(i)), 's'];...
            ['Min time: ', num2str(user_results.min_time_vec(i)), 's'];...
            ['Max time: ', num2str(user_results.max_time_vec(i)), 's']};
        annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
    end
end

if num_GUS_sites > 1
    this_GUS_str = ' for this GUS site';
else
    this_GUS_str = '';
end

% Authenticated Current Public Key
if any(strcmp(run_param.plots, 'Authenticated current level 2 key'))
    temp = user_results.current_auth_PK_time.time(:,:);
    temp = temp(:);     % Put all elements in a vector
%     norm_x = [0:user_results.current_auth_PK_time.max_time];
%     pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
%     norm = pdf(pd, norm_x);
    ECDSA_sim_plots.current_auth_PK_time_hist = figure;
    hold on
%     yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
%     yyaxis right
%     plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
%     ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title(['Time to receive authenticated current level 2 key', this_GUS_str])
    str = {['Average time: ', num2str(user_results.current_auth_PK_time.average_time), 's'];...
        ['Mode time: ', num2str(user_results.current_auth_PK_time.mode_time), 's'];...
        ['Min time: ', num2str(user_results.current_auth_PK_time.min_time), 's'];...
        ['Max time: ', num2str(user_results.current_auth_PK_time.max_time), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

% Expiration of Current Keys
if any(strcmp(run_param.plots, 'Expiration of current keys'))
    temp = user_results.current_auth_exp_PK_time.time(:,:);
    temp = temp(:);     % Put all elements in a vector
    norm_x = [0:user_results.current_auth_exp_PK_time.max_time];
    pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
    norm = pdf(pd, norm_x);
    ECDSA_sim_plots.current_auth_exp_PK_time = figure;
    hold on
    yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    yyaxis right
    plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
    ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title(['Time to receive authenticated expiration of current keys', this_GUS_str])
    str = {['Average time: ', num2str(user_results.current_auth_exp_PK_time.average_time), 's'];...
        ['Mode time: ', num2str(user_results.current_auth_exp_PK_time.mode_time), 's'];...
        ['Min time: ', num2str(user_results.current_auth_exp_PK_time.min_time), 's'];...
        ['Max time: ', num2str(user_results.current_auth_exp_PK_time.max_time), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

% Authenticated Next Public Key
if any(strcmp(run_param.plots, 'Authenticated next level 2 key'))
    temp = user_results.next_auth_PK_time.time(:,:);
    temp = temp(:);     % Put all elements in a vector
    norm_x = [0:user_results.next_auth_PK_time.max_time];
    pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
    norm = pdf(pd, norm_x);
    ECDSA_sim_plots.next_auth_PK_time = figure;
    hold on
    yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    yyaxis right
    plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
    ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title(['Time to receive authenticated next public key', this_GUS_str])
    str = {['Average time: ', num2str(user_results.next_auth_PK_time.average_time), 's'];...
        ['Mode time: ', num2str(user_results.next_auth_PK_time.mode_time), 's'];...
        ['Min time: ', num2str(user_results.next_auth_PK_time.min_time), 's'];...
        ['Max time: ', num2str(user_results.next_auth_PK_time.max_time), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

% Expiration of Next Keys
if any(strcmp(run_param.plots, 'Expiration of next keys'))
    temp = user_results.next_auth_exp_PK_time.time(:,:);
    temp = temp(:);     % Put all elements in a vector
    norm_x = [0:user_results.next_auth_exp_PK_time.max_time];
    pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
    norm = pdf(pd, norm_x);
    ECDSA_sim_plots.next_auth_exp_PK_time = figure;
    hold on
    yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    yyaxis right
    plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
    ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title(['Time to receive authenticated expiration of next keys', this_GUS_str])
    str = {['Average time: ', num2str(user_results.next_auth_exp_PK_time.average_time), 's'];...
        ['Mode time: ', num2str(user_results.next_auth_exp_PK_time.mode_time), 's'];...
        ['Min time: ', num2str(user_results.next_auth_exp_PK_time.min_time), 's'];...
        ['Max time: ', num2str(user_results.next_auth_exp_PK_time.max_time), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

if num_GUS_sites > 1
    
    % All Authenticated Current Public Keys
    if any(strcmp(run_param.plots, 'All authenticated current level 2 keys'))
        temp = user_results.all_current_auth_PK_time.time(:,:);
        temp = temp(:);     % Put all elements in a vector
        norm_x = [0:user_results.all_current_auth_PK_time.max_time];
        pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
        norm = pdf(pd, norm_x);
        ECDSA_sim_plots.all_current_auth_PK_time_hist = figure;
        hold on
        yyaxis left
        histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
        ylabel('Normalized Histogram')
        yyaxis right
        plot(norm_x + min(temp) - 1, norm)
        xlim([0 inf])
        ylabel('Normalized Log-Logistic pdf')
        xlabel('Seconds')
        title('Time to receive all authenticated current public keys')
        str = {['Average time: ', num2str(user_results.all_current_auth_PK_time.average_time), 's'];...
            ['Mode time: ', num2str(user_results.all_current_auth_PK_time.mode_time), 's'];...
            ['Min time: ', num2str(user_results.all_current_auth_PK_time.min_time), 's'];...
            ['Max time: ', num2str(user_results.all_current_auth_PK_time.max_time), 's']};
        annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
    end
    
    % All Expiration of Current Keys
    if any(strcmp(run_param.plots, 'All expiration of current keys'))
        temp = user_results.all_current_auth_exp_PK_time.time(:,:);
        temp = temp(:);     % Put all elements in a vector
        norm_x = [0:user_results.all_current_auth_exp_PK_time.max_time];
        pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
        norm = pdf(pd, norm_x);
        ECDSA_sim_plots.all_current_auth_exp_PK_time = figure;
        hold on
        yyaxis left
        histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
        ylabel('Normalized Histogram')
        yyaxis right
        plot(norm_x + min(temp) - 1, norm)
        xlim([0 inf])
        ylabel('Normalized Log-Logistic pdf')
        xlabel('Seconds')
        title('Time to receive all authenticated expiration of current keys')
        str = {['Average time: ', num2str(user_results.all_current_auth_exp_PK_time.average_time), 's'];...
            ['Mode time: ', num2str(user_results.all_current_auth_exp_PK_time.mode_time), 's'];...
            ['Min time: ', num2str(user_results.all_current_auth_exp_PK_time.min_time), 's'];...
            ['Max time: ', num2str(user_results.all_current_auth_exp_PK_time.max_time), 's']};
        annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
    end
    
    % All Authenticated Next Public Keys
    if any(strcmp(run_param.plots, 'All authenticated next level 2 keys'))
        temp = user_results.all_next_auth_PK_time.time(:,:);
        temp = temp(:);     % Put all elements in a vector
        norm_x = [0:user_results.all_next_auth_PK_time.max_time];
        pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
        norm = pdf(pd, norm_x);
        ECDSA_sim_plots.all_next_auth_PK_time = figure;
        hold on
        yyaxis left
        histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
        ylabel('Normalized Histogram')
        yyaxis right
        plot(norm_x + min(temp) - 1, norm)
        xlim([0 inf])
        ylabel('Normalized Log-Logistic pdf')
        xlabel('Seconds')
        title('Time to receive all authenticated next public keys')
        str = {['Average time: ', num2str(user_results.all_next_auth_PK_time.average_time), 's'];...
            ['Mode time: ', num2str(user_results.all_next_auth_PK_time.mode_time), 's'];...
            ['Min time: ', num2str(user_results.all_next_auth_PK_time.min_time), 's'];...
            ['Max time: ', num2str(user_results.all_next_auth_PK_time.max_time), 's']};
        annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
    end
    
    % All Expiration of Next Keys
    if any(strcmp(run_param.plots, 'All expiration of next keys'))
        temp = user_results.all_next_auth_exp_PK_time.time(:,:);
        temp = temp(:);     % Put all elements in a vector
        norm_x = [0:user_results.all_next_auth_exp_PK_time.max_time];
        pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
        norm = pdf(pd, norm_x);
        ECDSA_sim_plots.all_next_auth_exp_PK_time = figure;
        hold on
        yyaxis left
        histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
        ylabel('Normalized Histogram')
        yyaxis right
        plot(norm_x + min(temp) - 1, norm)
        xlim([0 inf])
        ylabel('Normalized Log-Logistic pdf')
        xlabel('Seconds')
        title('Time to receive all authenticated expiration of next keys')
        str = {['Average time: ', num2str(user_results.all_next_auth_exp_PK_time.average_time), 's'];...
            ['Mode time: ', num2str(user_results.all_next_auth_exp_PK_time.mode_time), 's'];...
            ['Min time: ', num2str(user_results.all_next_auth_exp_PK_time.min_time), 's'];...
            ['Max time: ', num2str(user_results.all_next_auth_exp_PK_time.max_time), 's']};
        annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
    end
    
end

% Authenitcated private key for next root key
if any(strcmp(run_param.plots, 'Authenticated private key for next root key'))
    temp = user_results.auth_priv_key_time.time(:,:);
    temp = temp(:);     % Put all elements in a vector
    norm_x = [0:user_results.auth_priv_key_time.max_time];
    pd = fitdist(temp - min(temp) + 1, 'Loglogistic');  % Fit a Log-Logistic distribution
    norm = pdf(pd, norm_x);
    ECDSA_sim_plots.auth_priv_key_time = figure;
    hold on
    yyaxis left
    histogram(temp, 'Normalization', 'probability')  % Plot normalized histogram
    ylabel('Normalized Histogram')
    yyaxis right
    plot(norm_x + min(temp) - 1, norm)
    xlim([0 inf])
    ylabel('Normalized Log-Logistic pdf')
    xlabel('Seconds')
    title('Time to receive authenticated private key unlocking the next root key')
    str = {['Average time: ', num2str(user_results.auth_priv_key_time.average_time), 's'];...
        ['Mode time: ', num2str(user_results.auth_priv_key_time.mode_time), 's'];...
        ['Min time: ', num2str(user_results.auth_priv_key_time.min_time), 's'];...
        ['Max time: ', num2str(user_results.auth_priv_key_time.max_time), 's']};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on')
end

% Plot a Box and Whisker plot for design outputs
if any(strcmp(run_param.plots, 'Box and whisker'))
    temp1 = user_results.total.time(:);
    temp2 = user_results.current_auth_PK_time.time(:,:); temp2 = temp2(:);
    temp3 = user_results.current_auth_exp_PK_time.time(:,:); temp3 = temp3(:);
    temp4 = user_results.next_auth_PK_time.time(:,:); temp4 = temp4(:);
    temp5 = user_results.next_auth_exp_PK_time.time(:,:); temp5 = temp5(:);
    if num_GUS_sites > 1
        temp6 = user_results.all_current_auth_PK_time.time(:,:); temp6 = temp6(:);
        temp7 = user_results.all_current_auth_exp_PK_time.time(:,:); temp7 = temp7(:);
        temp8 = user_results.all_next_auth_PK_time.time(:,:); temp8 = temp8(:);
        temp9 = user_results.all_next_auth_exp_PK_time.time(:,:); temp9 = temp9(:);
    end
    temp10 = user_results.auth_priv_key_time.time(:,:); temp10 = temp10(:);
    ECDSA_sim_plots.bandw = figure;
    if num_GUS_sites > 1
        boxplot([temp1(~isnan(temp1)), temp2(~isnan(temp2)), temp3(~isnan(temp3)), temp4(~isnan(temp4)), temp5(~isnan(temp5)), temp6(~isnan(temp6)), temp7(~isnan(temp7)), temp8(~isnan(temp8)), temp9(~isnan(temp9)), temp10(~isnan(temp10))],'Labels',{'(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(7)', '(8)', '(9)', '(10)'},'symbol','.')
    else
        boxplot([temp1(~isnan(temp1)), temp2(~isnan(temp2)), temp3(~isnan(temp3)), temp4(~isnan(temp4)), temp5(~isnan(temp5)), temp10(~isnan(temp10))],'Labels',{'(1)', '(2)', '(3)', '(4)', '(5)', '(6)'},'symbol','.')
    end
    title('Time to receive sets of messages')
    ylabel('Time (s)')
    if num_GUS_sites > 1
        str = {['(1): Total Time'];...
            ['(2) Authenticated Current PK'];...
            ['(3) Expiration of Current Keys'];...
            ['(4) Authenticated Next PK'];...
            ['(5) Expiration of Next Keys'];...
            ['(6) All Authenticated Current PK'];...
            ['(7) All Expiration of Current Keys'];...
            ['(8) All Authenticated Next PK'];...
            ['(9) All Expiration of Next Keys'];...
            ['(10) Authenticated Private Key Unlocking Next Root Key']};
    else
        str = {['(1): Total Time'];...
            ['(2) Authenticated Current PK'];...
            ['(3) Expiration of Current Keys'];...
            ['(4) Authenticated Next PK'];...
            ['(5) Expiration of Next Keys'];...
            ['(6) Authenticated Private Key Unlocking Next Root Key']};
    end
    annotation('textbox', [0.25, 0.8, 0.1, 0.1], 'String', str, 'FitBoxToText', 'on', 'FontSize', 10, 'BackgroundColor', [1 1 1], 'FaceAlpha', 1)
end

% Plot message sequence plot
if any(strcmp(run_param.plots, 'Message sequence plot'))
    ECDSA_sim_plots.message_sequence_plot = figure;
    stairs(1:length(extra.messages_seq_time), extra.messages_seq_time)
    title('Message Sequence Generated')
    xlabel('Seconds')
    ylabel('Message #')
end

% Plot frequency of OTAR messages
if any(strcmp(run_param.plots, 'Frequency of OTAR messages'))
    ECDSA_sim_plots.frequency = figure;
    histogram(extra.messages_num, 'Normalization', 'probability');  % Plot normalized histogram);
    xlabel('Message Number')
    ylabel('Normalized Histogram')
    title('Frequency of OTAR messages')
end

% Plot bandwidth percentages of each OTAR message
if any(strcmp(run_param.plots, 'Bandwidth percentages'))
    ECDSA_sim_plots.bandwidth = figure;
    histogram(extra.messages_seq_time, 'Normalization', 'probability');  % Plot normalized histogram);
    xlabel('Message Number')
    ylabel('Normalized Histogram')
    title('Bandwidth usage of each OMT within the OTAR messages')
end

% Report in a structure
output.ECDSA_sim_plots = ECDSA_sim_plots;
output.extra = extra;


disp_time = toc;
if run_param.disp_on
    disp(['Plotting Elapsed time: ', num2str(disp_time)])
end

end