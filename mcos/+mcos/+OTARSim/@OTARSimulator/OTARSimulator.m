classdef OTARSimulator < handle
    % OTARSimulator - a container for running an OTAR simulation using the
    % parameters generated from config.m along with any OMTConfiguration
    % files.
    
    properties (SetAccess = protected)
        % OTARBroadcast - An OTARBroadcast object that is generated using
        % the parameters from config.m using the algorithm specified
        % therein
        OTARBroadcast
        
        % SubMessageResults - index of when sub messages were received for
        % each simulation
        SubMessageResults
        
        % TimeResults - The time it takes to receive each message is
        % seconds
        OMTTimeResults
        
        % OMTUniqueGroups - Taken from OMTConfiguration
        OMTUniqueGroups
        
        % GroupTimeResults - Time results for the different OMT Groups
        GroupTimeResults
        
        % TotalNumUsers - Total number of users that received a full
        % message digest
        TotalNumUsers
        
        % OMTTimeAverages - Average time to receive each OMT
        OMTTimeAverages
        
        % GroupTimeAverages - Average time it to takes to receive each
        % group of OMTs
        GroupTimeAverages
        
        % OMTTimeMax - Max time to receive each OMT
        OMTTimeMax
        
        % OMTTimeMin - Min time to receive each OMT
        OMTTimeMin
        
        % OMTTimeMode - Mode time to receive each OMT
        OMTTimeMode
        
        % OMTTimeStDev - StDev time to receive each OMT
        OMTTimeStDev
        
        % GroupTimeMax - Max time to receive each group of OMTs
        GroupTimeMax
        
        % GroupTimeMin - Min time to receive each group of OMTs
        GroupTimeMin
        
        % GroupTimeMode - Mode time to receive each group of OMTs
        GroupTimeMode
        
        % GroupTimeStDev - StDev time to receive each group of OMTs
        GroupTimeStDev
        
    end
    
    properties (Transient = true, Hidden = true)
       % BlockRowNum - number of blocks
       BlockRowNum
       
       % BroadcastMatrix
       BroadcastMatrix
       
       % TotalNumMessages
       TotalNumMessages
       
       % BlockSize - size of the blocks
       BlockSize
       
    end
    
    % Constructor
    methods
        
        function obj = OTARSimulator(configParameters, omtConfiguration)
            
            % Handle empty constructor
            if nargin < 1
                error('No inputs to OTARSimulator')
            end
            
            if configParameters.DisplayOn
                disp('Running OTAR Simulator...')
                tWaitbar = waitbar(0, 'Iterating OTAR Simulations...'); % Initialize waitbar
                
            end
            
            obj.OMTUniqueGroups = omtConfiguration.OMTUniqueGroups;
            
            % Loop through all iterations
            for iteration = 1:configParameters.NumIterations
                
                
                % Place holder variables
                
                % Generate Broadcast
                obj.OTARBroadcast{iteration} = mcos.BroadcastGenerator.Broadcast(configParameters, omtConfiguration, iteration);
                
                % Partition Broadcast
                obj = obj.partitionBroadcast(configParameters, omtConfiguration, iteration);
                
                % Simulate Broadcast
                obj = obj.simulateBroadcast(configParameters, iteration);
                
                % Process Broadcast Results
                obj = obj.processBroadcastResults(configParameters, omtConfiguration, iteration);
                
                % Iterate waitbar
                if configParameters.DisplayOn
                   waitbar(iteration/configParameters.NumIterations, tWaitbar,...
                       ['Iteration ', num2str(iteration), ' of ', num2str(configParameters.NumIterations)]); 
                end
            end
            
            if configParameters.DisplayOn
               close(tWaitbar) % Close waitbar
            end
            
        end
        
    end
    
    methods
        % Method for partitioning the broadcast array
        obj = partitionBroadcast(obj, configParameters, omtConfiguration, iteration);     % Partitions the generated broadcast into blocks making simulations much faster
        
        % Method for simulating the user experience
        obj = simulateBroadcast(obj, configParameters, iteration);
        
        % Method for processing broadcast results
        obj = processBroadcastResults(obj, configParamters, omtConfiguration, iteration);
        
    end
    
    
    
    
    
    
end