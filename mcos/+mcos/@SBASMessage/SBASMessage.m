classdef SBASMessage < handle
    % SBASMessage - a container for information pertaining to an SBAS
    % message.
    
    properties (SetAccess = immutable)
        % SBASMessageLength - Length of the SBAS message in bits
        SBASMessageLength
        
        % SBASDataFieldLength - Length of the message available for data
        SBASDataFieldLength
        
        % PreambleLengthBits - Length of the preamble in bits
        PreambleLengthBits
        
        % SBASMTLengthBits - Length of the SBAS message type indicator in
        % bits
        SBASMTLengthBits
        
        % CRCLengthBits - Length of the CRC in bits.
        CRCLengthBits
        
    end
    
    % Constructor
    methods
        
        function obj = SBASMessage(configParameters)
            
            % Handle empty constructor
            if nargin < 1
                error('No configuration parameters detected.')
            end
            
            % Assign Properties
            obj.SBASMessageLength = 250;
            
            % Preemptively assign certain properties to 0
            obj.PreambleLengthBits = 0;
            obj.SBASMTLengthBits = 0;
            
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
                
                % CRCLengthBits
                obj.CRCLengthBits = 24;
                
            elseif (strcmp(configParameters.Channel, 'Q'))                
                % CRCLengthBits
                obj.CRCLengthBits = configParameters.QChannelCRCBits;
                
            end
            
            % Calculate SBASDataFieldLength
            obj.SBASDataFieldLength = obj.SBASMessageLength - ...
                obj.PreambleLengthBits - obj.SBASMTLengthBits - ...
                obj.CRCLengthBits;
            
        end
        
    end
    
    methods
        % Add methods here
    end
    
end