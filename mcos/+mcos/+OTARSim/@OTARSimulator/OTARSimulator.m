classdef OTARSimulator < handle
    % OTARSimulator - a container for running an OTAR simulation using the
    % parameters generated from config.m along with any OMTConfiguration
    % files.
    
    properties (SetAccess = protected)
        % OTARBroadcast - An OTARBroadcast object that is generated using
        % the parameters from config.m using the algorithm specified
        % therein
        OTARBroadcast
        
    end
    
    % Constructor
    methods
        
        function obj = OTARSimulator(configParameters, omtConfiguration, iteration)
            
            % Handle empty constructor
            if nargin < 1
               error('No inputs to OTARSimulator') 
            end
            
            % Place holder variables
            
            % Generate Broadcast
            obj.OTARBroadcast = mcos.BroadcastGenerator.Broadcast(configParameters, omtConfiguration, iteration);
            
        end
        
    end
    
    methods
        % Add any methods here
        % TODO: write partitionBroadcast
        obj = partitionBroadcast(obj);     % Partitions the generated broadcast into blocks making simulations much faster
        
    end
    
    
    
    
    
    
end