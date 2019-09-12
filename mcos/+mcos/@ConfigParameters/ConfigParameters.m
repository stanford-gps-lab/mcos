classdef ConfigParameters
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
        
        % WeightingScheme - Denotes the function that will be used to
        % weight the relative importance of each OTAR message or
        % sub-message.
        WeightingSchemeFile
        
        % MessageConfiguration - Grabs the message configuration used for
        % this run. Allows the user to create an OTAR message configuration
        % file to test its performance.
        OMTConfigurationFile
        
        % DisplayOn - Show checkpoints and waitbars for the simulations
        DisplayOn
        
        % NumIterations - Number of iterations if there are multiple
        % simulations that need to be run
        NumIterations
        
        % LoopVarName - Name of the variable that is being looped.
        LoopVarName
               
        % WeightingScheme - WeightingScheme struct loaded from
        % WeightingSchemeFile
        WeightingScheme
        
    end
    
    properties (SetAccess = public)
        % NumDiffKeys - Number of different keys that are required to
        % authenticate messages. Ideally, there will only be one public key
        % to sign the data, but if there are multiple because each master
        % station or GUS site has their own keys. This was num_GUS_sites in
        % original code.
        NumDiffKeys
        
        % MessageAuthenticationLength - Include binary count of how many
        % data messages each authentication message authenticates.
        MessageAuthenticationLength
        
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
        
        % QChannelCRCBits - Number of bits reserved for CRC for each
        % signature frame
        QChannelCRCBits
        
        % Level1PublicKeyLengthBits - Number of bits used for the level 1
        % public key
        Level1PublicKeyLengthBits
        
        % Level2PublicKeyLengthBits - Number of bits used for the level 2
        % public key
        Level2PublicKeyLengthBits
        
        % Level1SignatureLengthBits - Number of bits used for the level-1
        % signature
        Level1SignatureLengthBits
        
        % Level2SignatureLengthBits - Number of bits used for the level-2
        % signature
        Level2SignatureLengthBits
        
        % TESLAKeyLengthBits - Number of bits used for the TESLA key
        TESLAKeyLengthBits
        
        % TESLAMACLengthBits - Number of bits used for the TESLA MAC
        TESLAMACLengthBits
        
        % TESLASaltLengthBits - Length of the salt used for each TESLA
        % keychain in bits
        TESLASaltLengthBits
        
        % Weights - Weights that are loaded from WeightingSchemeFile
        Weights
        
        % PartitionBlockSize - Size of the block partitions when breaking
        % up the code. This greatly speeds up the code. Set to empty if the
        % broadcast should not be broken into blocks.
        PartitionBlockSize
        
        % PlottingParameters - cell array describing which plots are
        % desired when running this code
        PlottingParameters
        
    end
    
    % Constructor
    methods
        
        function obj = ConfigParameters(varargin)
            
            % Parse inputs
            res = mcos.internal.parseConfig(varargin{:});
            
            % Assign Parsed Statements
            obj.Scheme = res.Scheme;
            obj.SaveData = res.SaveData;
            obj.Frequency = res.Frequency;
            obj.Channel = res.Channel;
            obj.NumDiffKeys = res.NumDiffKeys;
            obj.MessageAuthenticationLength = res.MessageAuthenticationLength;
            obj.PER = res.PER;
            obj.MinLengthOTARMessage = res.MinLengthOTARMessage;
            obj.TBA = res.TBA;
            obj.SimLength = res.SimLength;
            obj.NumUsers = res.NumUsers;
            obj.WeightingSchemeFile = res.WeightingSchemeFile;
            obj.OMTConfigurationFile = res.OMTConfigurationFile;
            obj.QChannelCRCBits = res.QChannelCRCBits;
            obj.Level1PublicKeyLengthBits = res.Level1PublicKeyLengthBits;
            obj.Level2PublicKeyLengthBits = res.Level2PublicKeyLengthBits;
            obj.Level1SignatureLengthBits = res.Level1SignatureLengthBits;
            obj.Level2SignatureLengthBits = res.Level2SignatureLengthBits;
            obj.NumIterations = res.NumIterations;
            obj.PartitionBlockSize = res.PartitionBlockSize;
            obj.DisplayOn = res.DisplayOn;
            obj.LoopVarName = res.LoopVarName;
            obj.WeightingScheme = res.WeightingScheme;
            obj.Weights = res.Weights;
            obj.PlottingParameters = res.PlottingParameters;
            
            % Null TESLA parameters if ECDSA is used
            if (strcmp(obj.Scheme, 'TESLA'))
                obj.TESLAKeyLengthBits = res.TESLAKeyLengthBits;
                obj.TESLAMACLengthBits = res.TESLAMACLengthBits;
                obj.TESLASaltLengthBits = res.TESLASaltLengthBits;
            else
                obj.TESLAKeyLengthBits = [];
                obj.TESLAMACLengthBits = [];
                obj.TESLASaltLengthBits = [];
            end
            
        end
        
    end
    
end