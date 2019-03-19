classdef OMTConfiguration < handle
    % MessageConfiguration - a container for information pertaining to the
    % message configuration format to be broadcast. This class contains all
    % information about the OTAR messages.
    
    properties (SetAccess = immutable)
        % OMTNum - OTAR Message Type number
        OMTNum
        
        % OMTDataLength - Length of OMT Data in bits
        OMTDataLength
        
        % OMTDescription - Description of the OMT
        OMTDescription
        
        % OMTFullLength - Length of OMT including OMT# and Sequence#
        OMTFullLength
        
    end
    
    methods
        
        %Constructor
        function obj = OMTConfiguration(omtConfig, configParameters)
            % TODO: Build a constructor for OMTConfiguration
            
            
            
        end
        
    end
    
    methods
       % TODO: Create a method for determining the OMTLength given other inputs from configParameters
       
    end
    
    methods (Static)
        % TODO: Create a method that can pull out information for a given
        % OMT
    end
    
    
end