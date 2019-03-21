classdef OMTConfiguration < handle
    % MessageConfiguration - a container for information pertaining to the
    % message configuration format to be broadcast. This class contains all
    % information about the OTAR messages.
    
    properties (SetAccess = immutable)
        % OMTNum - OTAR Message Type number
        OMTNum
        
        % OMTDataLength - Length of OMT Data in bits
        OMTDataLengthBits
        
        % OMTDescription - Description of the OMT
        OMTDescription
        
        % SBASAuthenticationMessage - The object that is either
        % SBASECDSAMessage or SBASTESLAMessage depending on the
        % configuration parameters.
        SBASAuthenticationMessage
        
    end
    
    properties (SetAccess = protected)
        % OMTFullLengthBits - Length of OMT including OMT# and Sequence#
        OMTFullLengthBits
        
        % OMTSequenceNumBits - Number of bits required to report the
        % sequence number of an OMT if the OMT takes up multiple OTAR
        % Frames
        OMTSequenceNumBits
        
        % OMTNumFrames - How many authentication frames required to deliver
        % the OMT
        OMTNumFrames
                
        % OMTHeaderBits - How many bits are used in the OMTHeader
        OMTHeaderBits
                
        % NumDiffKeysBits - How many bits required to convey information
        % about different data signature keys.
        NumDiffKeysBits
        
        % OMTInd - Index of non-zero OMT messages
        OMTInd
        
        % MaxOMTNum - Largest OMT Number for this simulation
        MaxOMTNum
        
    end
    
    methods
        
        %Constructor
        function obj = OMTConfiguration(configParameters)
            if configParameters.DisplayOn
               disp('Configuring OTAR Messages...') 
            end
            
            % Handle empty constructor
            if nargin < 1
                error('No OMTConfigurationFile specified. Specify this file in config.m')
            end
            
            % Check for the existance of the OMTConfigurationFile specified
            % If file exists, load the contents
            currentDir = pwd;
            cd OMTConfigurationFiles
            if (~exist(configParameters.OMTConfigurationFile, 'file'))
                cd ..
                error('OMTConfiguration file not found. Make sure the full file (including .mat) is written correctly')
            else
                load(configParameters.OMTConfigurationFile, 'omtConfig')
            end
            cd(currentDir)
            
            % Assign .mat inputs to appropriate attributes
            obj.OMTNum = omtConfig(:,1);
            obj.OMTDataLengthBits = omtConfig(:,2);
            obj.OMTDescription = omtConfig(:,3);
            
            % Calculate the OMTFullLength using the OTMConfiguration file
            % and this simulation's configParameters and the chosen
            % sbasAuthenticationMessage
            if (strcmp(configParameters.Scheme, 'ECDSA'))
                obj.SBASAuthenticationMessage = mcos.SBASECDSAMessage(configParameters);
            elseif (strcmp(configParameters.Scheme, 'TESLA'))
                obj.SBASAuthenticationMessage = mcos.SBASTESLAMessage(configParameters);
            end
            
            % Assign Properties from completeOMTConfiguration
            obj = obj.completeOMTConfiguration(configParameters);
            
        end
        
    end
    
    methods
        % Add methods here
        obj = completeOMTConfiguration(obj, configParameters)
    end
    
    methods (Static)
        % Add static methods here
    end
    
    
end