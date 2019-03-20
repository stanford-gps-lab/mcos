classdef SBASTESLAMessage < mcos.SBASMessage
    % SBASTESLAMessage - a container for information pertaining to a TESLA
    % SBAS Authentication Message.
    
    properties (SetAccess = immutable)
        % NumMessagesAuthenticatedLengthBits - Number of bits required to
        % send information regarding the number of messages that are
        % authenticated in this frame. This number is nominally set by TBA
        % and represents the maximum number of messages that can be
        % authenticated in a single frame.
        NumMessagesAuthenticationLengthBits
        
        % MessagesPerAuthenticationFrame - Number of SBAS messages used per
        % authentication frame.
        MessagesPerAuthenticationFrame
        
        % TESLAMACLengthBits - Number of bits used by the TESLA MAC. 0 if
        % ECDSA is used.
        TESLAMACLengthBits
        
        %TESLAKeyLengthBits - Number of bits used for the TESLA key
        TESLAKeyLengthBits
        
        % OMTLengthBits - Length of an OTAR message in bits
        OMTLengthBits
        
    end
    
    % Constructor
    methods
        
        function obj = SBASTESLAMessage(configParameters)
            
            % Handle the empty constructor
            if nargin < 1
                error('No configuration parameters selected.')
            end
            
            % Set properties from SBASMessage constructor.
            obj@mcos.SBASMessage(configParameters);
            
            % Assign properties from configParamters
            obj.TESLAMACLengthBits = configParameters.TESLAMACLengthBits;
            obj.TESLAKeyLengthBits = configParameters.TESLAKeyLengthBits;
            
            % Preemptively assign certain properties to 0
            obj.NumMessagesAuthenticationLengthBits = 0;
            
            if (strcmp(configParameters.Channel, 'I'))
                % NumMessagesAuthenticationLengthBits
                obj.NumMessagesAuthenticationLengthBits = ceil(log2(configParameters.TBA));
            end
            
            % Calculate how many messages it will take to deliver an
            % authentication message frame
            obj.MessagesPerAuthenticationFrame = ceil((obj.TESLAMACLengthBits + obj.TESLAKeyLengthBits + obj.NumMessagesAuthenticationLengthBits)/obj.SBASDataFieldLength);
            
            % OMTLengthBits
            obj.OMTLengthBits = ...
                obj.MessagesPerAuthenticationFrame*...
                obj.SBASDataFieldLength - ...
                obj.TESLAMACLengthBits - ...
                obj.TESLAKeyLengthBits - ...
                obj.NumMessagesAuthenticationLengthBits;
            
            
        end
        
    end
    
    
    
    
end