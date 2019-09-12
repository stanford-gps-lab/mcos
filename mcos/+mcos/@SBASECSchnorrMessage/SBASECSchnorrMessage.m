classdef SBASECSchnorrMessage < mcos.SBASMessage
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
        
        % ECDSASignatureLengthBits - Length of the ECDSA Signature in bits
        ECSchnorrSignatureLengthBits
        
        % OMTLengthBits - Length of an OTAR message in bits
        OTARWordLengthBits
        
    end
    
    % Constructor
    methods
        
        function obj = SBASECSchnorrMessage(configParameters)
            
            % Handle the empty constructor
            if nargin < 1
                error('No configuration parameters selected.')
            end
            
            % Set properties from SBASMessage constructor.
            obj@mcos.SBASMessage(configParameters);
            
            % Assign ECDSASignatureLengthBits
            obj.ECSchnorrSignatureLengthBits = configParameters.Level2SignatureLengthBits;
            
            % Preemptively assign certain properties to 0
            obj.NumMessagesAuthenticationLengthBits = 0;
            
            if (strcmp(configParameters.Channel, 'I')) && configParameters.MessageAuthenticationLength
                % NumMessagesAuthenticationLengthBits
                obj.NumMessagesAuthenticationLengthBits = ceil(log2(configParameters.TBA));
            end
            
            % Calculate how many messages it will take to deliver an
            % authentication message frame
            obj.MessagesPerAuthenticationFrame = ceil((obj.ECSchnorrSignatureLengthBits + obj.NumMessagesAuthenticationLengthBits)/obj.SBASDataFieldLength);
            
            % OMTLengthBits
            obj.OTARWordLengthBits = ...
                obj.MessagesPerAuthenticationFrame*...
                obj.SBASDataFieldLength - ...
                obj.ECSchnorrSignatureLengthBits - ...
                obj.NumMessagesAuthenticationLengthBits;
            
        end
        
    end
    
    
    
    
    
    
    
    
end