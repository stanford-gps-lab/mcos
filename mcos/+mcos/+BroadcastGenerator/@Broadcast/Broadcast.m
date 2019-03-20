classdef Broadcast
    % Broadcast - a container for the OMT broadcast that is generated using
    % the input parameters from config.m.
    
    properties (SetAccess = protected)
        % BroadcastArray - Array of OTAR messages (OMTs) that are in the
        % order in which they are broadcast
        BroadcastArray
        
        % Algorithm - Character array denoting which broadcast generating
        % algorithm is being used
        Algorithm
        
        % WeightingSchemeFile - Character array denoting which
        % WeightingSchemeFile was used for this simulation
        WeightingSchemeFile
    end
    
    % Constructor
    methods
       
        function obj = Broadcast(weightingSchemeFile)
            
            % Handle empty constructor
            if nargin < 1
               error('No broadcast algorithm has been input.') 
            end
            
            % Assign properties using generateBroadcast
            temp = mcos.BroadcastGenerator.Broadcast.generateBroadcast(weightingSchemeFile);
            obj.Algorithm = temp.Algorithm;
            obj.WeightingSchemeFile = temp.WeightingSchemeFile;
            
            % Temporary
            obj.BroadcastArray = 0;
            
        end
        
    end
    
    methods (Static)
       % TODO: Create a broadcast generator using Hameed's algorithm
       obj = generateBroadcast(weightingSchemeFile);
    end
    
    
    
    
end