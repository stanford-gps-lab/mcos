classdef ConfigParameters < handle
    % ConfigParameters - Class of configuration parameters set by the
    % config.m file.
    
    
    % Configuration parameters
    % Set to immutable so they cannot be changed once defined
    properties (SetAccess = immutable)
        % Scheme - scheme to be run, TESLA or ECDSA
        Scheme
        
        % SaveData - Boolean: true or false
        SaveData
        
        % Frequency - 'L5' or 'L1'
        Frequency
        
        % Channel - 'I' or 'Q'
        Channel
        
        % NumDiffKeys - Number of different keys that are required to
        % authenticate messages. Ideally, there will only be one public key
        % to sign the data, but if there are multiple because each master
        % station or GUS site has their own keys. This was num_GUS_sites in
        % original code.
        NumDiffKeys
        
        % PER - Page error rate
        PER
        
        % MinLengthOTARMessage - Sets the minimum length of an OTAR
        % message. This may be used if there needs to be more messages used
        % per signature in order to fascillitate OTAR. Nominally set to 0.
        MinLengthOTARMessage
        
        % TBA - Time between authentications. Represented in units of
        % messages.
        TBA
        
        % SimLength - Number of OTAR messages to be generated for the
        % simulation.
        SimLength
        
        % NumUsers - Number of users that start demodulating at each time
        % interval. This is nominally set to 0 if a PER of 0 is set,
        % otherwise it expands the Monte Carlo results to include the
        % effect of PER for the same message sequence.
        NumUsers
        
        % WeightingScheme - Denotes the function that will be used to
        % weight the relative importance of each OTAR message or
        % sub-message.
        WeightingScheme
        
        % MessageConfiguration - Grabs the message configuration used for
        % this run. Allows the user to create an OTAR message configuration
        % file to test its performance.
        MessageConfiguration
        
        % BroadcastGenerator - Selects which function will be used to
        % generate the broadcast.
        BroadcastGenerator
        
        
    end
    
    % Constructor
    methods
        
        function obj = ConfigParameters(varargin)
            
            % handle an empty constructor
            if nargin == 0
                error('No configurations input.')
            end
            
            % Parse inputs
            res = mcos.internal.parseConfig(varargin{:});
            
            % Temporary
            obj.Scheme = res.Scheme;
            obj.SaveData = res.SaveData;
            obj.Frequency = res.Frequency;
            obj.Channel = res.Channel;
            obj.NumDiffKeys = res.NumDiffKeys;
            obj.PER = res.PER;
            obj.MinLengthOTARMessage = res.MinLengthOTARMessage;
            obj.TBA = res.TBA;
            obj.SimLength = res.SimLength;
            obj.NumUsers = res.NumUsers;
            obj.WeightingScheme = res.WeightingScheme;
            obj.MessageConfiguration = res.MessageConfiguration;
            obj.BroadcastGenerator = res.BroadcastGenerator;
            
            
            
            
        end
        
    end
    
    methods
        % TODO: define any methods here
        
    end
    
    
    methods (Static)
        % TODO: define static methods here
        obj = createFromLoadData(filename) % TODO: Make function to create ConfigParameters from LoadData
    end
    
    
    
    
    
end