function OMT = ECDSA_bandwidth(output)
% This function solves for the output bandwidth according to equation (4)
% in "Hameed - Efficient algorithms for scheduling data broadcast"

% Break out structure
OMT = output.OMT;
message_fields = output.message_fields;

OMT.phi_vec = zeros(31,1);
for i = message_fields
    OMT.phi_vec(i) = OMT.messages_vec(i)/OMT.s_vec(i);
end

end