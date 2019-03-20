classdef Broadcast
    % Broadcast - a container for the OMT broadcast that is generated using
    % the input parameters from config.m.
    
    properties (SetAccess = protected)
        % BroadcastArray - Array of OTAR messages (OMTs) that are in the
        % order in which they are broadcast
        BroadcastArray
        
    end
    
    % Constructor
    methods
       
        function obj = Broadcast(varargin)
            
            % Handle empty constructor
            if nargin < 1
               error('No broadcast algorithm has been input.') 
            end
            
            % Assign properties using generateBroadcast
            obj = generateBroadcast(varargin{:});
            
        end
        
    end
    
    methods (Static)
       % TODO: Create a broadcast generator using Hameed's algorithm
       obj = generateBroadcast(varargin);
    end
    
    
    
    
end