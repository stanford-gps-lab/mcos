classdef SBASMessage < handle
    % SBASMessage - a container for information pertaining to an SBAS
    % message.
    
    properties (SetAccess = immutable)
        % SBASMessageLength - Length of the SBAS message in bits
        SBASMessageLength
    end
    
    % Constructor
    methods
        
        function obj = SBASMessage()
            
            % Handle empty constructor
            if nargin < 1
               obj.SBASMessageLength = 250;     % 250 bits for most SBAS Messages
            end
            
        end
        
    end
    
    methods
       % Add methods here 
    end
        
end