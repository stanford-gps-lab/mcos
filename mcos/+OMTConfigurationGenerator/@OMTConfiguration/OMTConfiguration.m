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
        
        % OMTHeaderBits - How many bits are used in the OMTHeader
        OMTHeaderBits
        
    end
    
    methods
        
        %Constructor
        function obj = OMTConfiguration(omtConfigurationFile, configParameters)
            % TODO: Build a constructor for OMTConfiguration
            
            % Handle empty constructor
            if nargin < 1
                error('No OMTConfigurationFile specified. Specify this file in config.m')
            end
            
            % Check for the existance of the OMTConfigurationFile specified
            % If file exists, load the contents
            currentDir = pwd;
            cd OMTConfigurationFiles
            if (~exist(omtConfigurationFile))
                cd ..
                error('OMTConfiguration file not found. Make sure the full file (including .mat) is written correctly')
            else
                load(omtConfigurationFile, 'omtConfig')
            end
            cd(currentDir)
            
            % Assign .mat inputs to appropriate attributes
            obj.OMTNum = omtConfig(:,1);
            obj.OMTDataLength = omtConfig(:,2);
            obj.OMTDescription = omtConfig(:,3);
            
            % Calculate the OMTFullLength using the OTMConfiguration file
            % and this simulation's configParameters
            
            
            % Temporary
            derp = configParameters;
            obj.OMTFullLength = 0;
            
            
            
        end
        
    end
    
    methods
        % TODO: Create a method that can pull out information for a given
        % OMT
        
    end
    
    methods (Static)
        % TODO: Create a method for determining the OMTLength given other inputs from configParameters
        [omtFullLength, omtHeaderBits] = getOMTFullLength(omtConfig, configParameters)
    end
    
    
end