classdef Broadcast
    % Broadcast - a container for the OMT broadcast that is generated using
    % the input parameters from config.m.
    
    properties (SetAccess = protected)
        % BroadcastMessageNum - OMT Message numbers that are broadcast
        BroadcastMessageNum
        
        % Algorithm - Character array denoting which broadcast generating
        % algorithm is being used
        Algorithm
        
        % WeightingSchemeFile - Character array denoting which
        % WeightingSchemeFile was used for this simulation
        WeightingSchemeFile
        
        % Weights - Matrix of weights that are loaded from
        % WeightingSchemeFile
        Weights
    end
    
    properties (SetAccess = public)
        % BroadcastArray - Array of OTAR messages (OMTs) that are in the
        % order in which they are broadcast
        BroadcastArray
    end
    
    % Constructor
    methods
        
        function obj = Broadcast(configParameters, omtConfiguration, iteration)
            
            % Handle empty constructor
            if nargin < 1
                error('No broadcast algorithm has been input.')
            end
            
            % Assign some properties to 0
            obj.Weights = 0;
            
            % Assign properties using generateBroadcast
            temp = mcos.BroadcastGenerator.Broadcast.generateBroadcast(configParameters, omtConfiguration, iteration);
            obj.Algorithm = temp.Algorithm;
            obj.WeightingSchemeFile = temp.WeightingSchemeFile;
            obj.Weights = temp.Weights;
            obj.BroadcastArray = temp.BroadcastArray;
            obj.BroadcastMessageNum = temp.BroadcastMessageNum;
            
        end
        
    end
    
    methods (Static)
        obj = generateBroadcast(configParameters, omtConfiguration, iteration);
    end
    
    
    
    
end