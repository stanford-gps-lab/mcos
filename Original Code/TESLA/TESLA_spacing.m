function output = TESLA_spacing(run_param, output)
% This function uses Theorem 2 in "Hameed - Efficient algorithms for
% scheduling data broadcast"

% Break out structure
OMT = output.OMT;
PER = run_param.PER;
num_GUS_sites = run_param.num_GUS_sites;

% Define message fields
if num_GUS_sites > 1
    message_fields = [1:6, 9:14, 16:31];
else
    message_fields = [1:6, 9:14, 28:31];
end

% Define error probability for each OMT (item)
OMT.E_vec = zeros(31,1);
for i = message_fields
   OMT.E_vec(i) = 1 - (1 - PER)^OMT.messages_vec(i);
end

% Find first half of equation (5)
sum1 = 0;
for i = message_fields
    sum1 = sum1 + sqrt(OMT.p_vec(i)*OMT.messages_vec(i)*(1 + OMT.E_vec(i))/(1 - OMT.E_vec(i)));
end

% Find s_i for each OMT
OMT.s_vec = zeros(31,1);
for i = message_fields
    OMT.s_vec(i) = sum1*sqrt(OMT.messages_vec(i)/OMT.p_vec(i)*(1 - OMT.E_vec(i))/(1 + OMT.E_vec(i)));
end

% Solve for optimal overall mean access time
t_opt = 0.5*(sum1)^2;

% Report values in structure
output.OMT = OMT;
output.t_opt = t_opt;
output.message_fields = message_fields;
end