function OMT = ECDSA_waittime(run_param, output)
% Calcualte average wait time to receive full message in seconds from
% spacing calculation. From  "Hameed - Efficient algorithms for scheduling
% data broadcast"

% Break out structure
OMT = output.OMT;
TBA = run_param.TBA;
message_fields = output.message_fields;

OMT.average_wait_time_vec = zeros(31,1);
for i = message_fields
   OMT.average_wait_time_vec(i) = OMT.s_vec(i)*TBA/2 + OMT.messages_vec(i)*TBA; 
end

end