classdef SBASECDSAMessage < mcos.SBASMessage
    % SBASECDSAMessage - a container for information pertaining to an ECDSA
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
        
        % OMTLengthBits - Length of an OTAR message in bits
        OMTLengthBits
        
    end
    
    % Constructor
    methods
        
        function obj = SBASECDSAMessage(configParameters)
            
            % Handle the empty constructor
            if nargin < 1
                error('No configuration parameters selected.')
            end
            
            % Set properties from SBASMessage constructor.
            obj@mcos.SBASMessage(configParameters);
            
            % Preemptively assign certain properties to 0
            obj.NumMessagesAuthenticationLengthBits = 0;
            
            % Calculate how many messages it will take to deliver an
            % authentication message frame
            obj.MessagesPerAuthenticationFrame = ceil(configParameters.Level2PublicKeyLengthBits*2/obj.SBASDataFieldLength);
            
            if (strcmp(configParameters.Channel, 'I'))
                % NumMessagesAuthenticationLengthBits
                obj.NumMessagesAuthenticationLengthBits = ceil(log2(configParameters.TBA));
            end
            
            % OMTLengthBits
            obj.OMTLengthBits = ...
                obj.MessagesPerAuthenticationFrame*...
                obj.SBASDataFieldLength - ...
                configParameters.Level2PublicKeyLengthBits*2 - ...
                obj.NumMessagesAuthenticationLengthBits;
            
        end
        
    end
    
    
    
    
    
    
    
    
end