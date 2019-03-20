classdef SBASAuthenticationMessage < mcos.SBASMessage
    % SBASAuthenticationMessage - a container for an SBAS authentication
    % message. This class is a subclass of SBASMessage.
    
    properties (SetAccess = immutable)
        % PreambleLengthBits - Length of the preamble in bits
        PreambleLengthBits
        
        % SBASMTLengthBits - Length of the SBAS message type indicator in
        % bits
        SBASMTLengthBits
        
        % NumMessagesAuthenticatedLengthBits - Number of bits required to
        % send information regarding the number of messages that are
        % authenticated in this frame. This number is nominally set by TBA
        % and represents the maximum number of messages that can be
        % authenticated in a single frame.
        NumMessagesAuthenticationLengthBits
        
        % TESLAMACLengthBits - Number of bits used by the TESLA MAC. 0 if
        % ECDSA is used.
        TESLAMACLengthBits
        
        %TESLAKeyLengthBits - Number of bits used for the TESLA key
        TESLAKeyLengthBits
        
        % OMTLengthBits - Length of an OTAR message in bits
        OMTLengthBits
        
        % CRCLengthBits - Length of the CRC in bits.
        CRCLengthBits
        
    end
    
    % Constructor
    methods
        
        function obj = SBASAuthenticationMessage(configParameters)
            
            % Handle the empty constructor
            if nargin < 1
                error('No configuration parameters selected.')
            end
            
            % Set properties from SBASMessage constructor.
            obj@mcos.SBASMessage();
            
            % Preemptively assign certain properties to 0
            obj.PreambleLengthBits = 0;
            obj.SBASMTLengthBits = 0;
            obj.NumMessagesAuthenticationLengthBits = 0;
            obj.TESLAMACLengthBits = 0;
            obj.TESLAKeyLengthBits = 0;
            
            % Assign properties
            if (strcmp(configParameters.Channel, 'I'))
                % PreambleLengthBits
                if (strcmp(configParameters.Frequency, 'L1'))
                    obj.PreambleLengthBits = 8;
                elseif (strcmp(configParameters.Frequency, 'L5'))
                    obj.PreambleLengthBits = 4;
                end
                
                % SBASMTLengthBits
                obj.SBASMTLengthBits = 6;
                
                % NumMessagesAuthenticationLengthBits
                obj.NumMessagesAuthenticationLengthBits = ceil(log2(configParameters.TBA));
                
                % CRCLengthBits
                obj.CRCLengthBits = 24;
                
            elseif (strcmp(configParameters.Channel, 'Q'))
                % SBASMTLengthBits
                obj.SBASMTLengthBits = 0;
                
                %
                
                % CRCLengthBits
                obj.CRCLengthBits = configParameters.QChannelCRCBits;
                
            end
            
            if (strcmp(configParameters.Scheme, 'TESLA'))
                obj.TESLAMACLengthBits = configParameters.TESLAMACLengthBits;
                obj.TESLAKeyLengthBits = configParameters.TESLAKeyLengthBits;
            end
            
            % Calculate how many bits are left over for OMT
            obj.OMTLengthBits = obj.SBASMessageLength - ...
                obj.PreambleLengthBits - obj.SBASMTLengthBits - ...
                obj.NumMessagesAuthenticationLengthBits - ...
                obj.TESLAMACLengthBits - obj.TESLAKeyLengthBits - ...
                obj.CRCLengthBits;
            
        end
        
    end
    
    methods
        % Add methods here
    end
    
end