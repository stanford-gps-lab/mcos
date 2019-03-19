classdef OMTConfiguration < handle
    % MessageConfiguration - a container for information pertaining to the
    % message configuration format to be broadcast. This class contains all
    % information about the OTAR messages.
    
    properties (SetAccess = immutable)
        % OMTNum - OTAR Message Type number
        OMTNum
        
        % OMTLength - Length of OMT in bits
        OMTLength
        
        % OMTDescription - Description of the OMT
        OMTDescription
        
    end
    
    methods
        
        %Constructor
        function obj = OMTConfiguration(OMTNum, OMTLength, OMTDescription)
            % TODO: Build a constructor for MessageConfiguration
        end
        
    end
    
    methods
       % TODO: Create a method for determining the OMTLength given other inputs from configParameters
       
       % TODO: Create a template for creating .mat files using a script in
       % utilities
    end
    
    methods (Static)
        % TODO: Create a method that can pull out information for a given
        % OMT
    end
    
    
end