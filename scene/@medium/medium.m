classdef medium < hiddenHandle
% Abstract class (interface) for participating media.
%
% This class contains properties for the participating media properties. We
% are starting with transmission through blood (oxy and deoxy).
%
% Subclasses of @medium inherit spectral properties and methods from
% @medium.  Using this superclass scheme, enforces consistency amongst all
% subclasses in terms of how they handle spectral properties.  We might
% make the blood types subclasses.  Not sure.
%
% Description:
%    Our understanding of the terminology for describing medium
%    properties is below.
%
%    In general, the spectral data for the different media are stored in
%    columns.  This applies to all of the parameters below.
%
%    obj.absorbance  - the absorbance spectra of the medium, normalized to
%    a peak value of 1. The normalization to peak of 1 is just a
%    convention, the quantity that matters is the product
%    obj.opticalDensity*ojb.absorbance. Some might call that product the
%    absorbance.  But we prefer to keep the density and normalized
%    absorbance separate.
%
%    (Re ISETBio: This quantity is called obj.unitDensity in the Lens
%    and Macular objects, and in the Lens object it is not normalized. 
%
%    obj.opticalDensity - the peak optical density (sometimes just
%    called optical density). The interpretation as peak optical
%    density depends on the convention followed here of normalizing
%    obj.absorbance to a peak of 1.
%
%    obj.absorptance - the absorptance spectrum.  This tells us the
%    probability that a photon of a given wavelength is absorbed as it
%    passes through a thin layer of the medium with absorbance given by
%    obj.opticalDensity*obj.absorbance.  See the formula below.
%
%    Useful formulae:
%       
%           absorptance = 1 - 10.^(-opticalDensity * absorbance). 
%
%       Absorbance spectra are normalized to a peak value of 1, and
%       then scaled by optical density to get the specific system
%       absorbance.
%
%       Absorptance spectra are the proportion of quanta actually absorbed.
%       This is the term used in this routine.
%
% Input:
%	 None required.
%
% Output:
%    medium          - The created medium object.
%   
% Optional key/value pairs:
%    'opticalDensity' - Default optical density (1).
%    'absorbance'     - Spectral data read from data file
%	 'wave'           - Vector of wavelengths in nm read from data file
%
%    The raw absorbance data are read in from a file.  The full wavelength
%    and absorbance are stored in wave_ and absorbance_. Typically wave_ is
%    set to a large wavelength support.
% 
%    The user can set 'wave', and the set will interpolate the raw data
%    onto this sampling of wave. After creating, you can't change wave_, or
%    absorbance_, but you can change wave.
%
% See also
%   ISETBio:  @receptorPigment, @Lens

% Example:
%{
   deoxyblood = medium('deoxyHemoglobin.mat');
%}
%{
  oxyblood = medium('oxyHemoglobin.mat','wave',400:1:700);
%}

% Public properties 
properties 
    % opticalDensity - photopigment optical densities for different cone types
    opticalDensity;

    % peakEfficiency - peak absorptance efficiency
    % peakEfficiency;
    
end

properties (Dependent)

    % absorbance - spectral absorbance of the cones
    absorbance;
    
    % absorptance - cone absorptance without ocular media
    absorptance;

    % % quantaFundamentals - normalized cone absorptance. Because of the
    % % normalization, not useful for actual calculation, only for examining
    % % the relative shape.
    % quantaFundamentals;
    % 
    % % energyFundamentals - normalized cone absorptance converrted
    % % to energy units from the normalized obj.quantaFundamentals.
    % % Useful only for shape, because of the normalization.
    % energyFundamentals;
    % 
    % % quantalEfficiency - probability of isomerization in quantal units.
    % % Gives the probability that an incident photon isomerizes
    % % photopigment. These are actually useful.  Does not take into account
    % % effect of inert pigments (lens, macular pigment).
    % quantalEfficiency;
end

properties (SetAccess = protected)
    % File that contains the absorbance data
    filename;
end

% ReceptorPigment subclasses do not have any access to these properties directly
properties (SetAccess = protected, GetAccess = protected)
        
end

properties (SetObservable, AbortSet)
    % wave - wavelength samples
    wave;
end

properties (SetAccess = public)
    % I made these public so I could change them from a script.  But NC may
    % want us to do this a different way with set operations.
    %
    
    % wave_ - The internal wavelength samples
    wave_;

    % absorbance_ - The absorbance data sampled at wave_
    absorbance_;
end

% % Abstract, public methods. Each subclass of @medium *must* implement
% %  its own version of all functions listed as abstract. If it does not, 
% % it cannot instantiate objects.
% methods(Abstract)
%     description(obj, varargin)
% end

% Public methods
methods
    % Constructor
    function obj = medium(filename,varargin)
        
        varargin = ieParamFormat(varargin);
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.addRequired('filename',@(x)(exist(x,'file') == 2));
        p.addParameter('opticaldensity', 1, @isnumeric);
        p.addParameter('wave',400:10:700,@isvector);
        p.parse(filename,varargin{:});
        
        obj.filename = which(filename);
        [obj.absorbance_,obj.wave_] = ieReadSpectra(filename);

        % set object properties
        obj.wave = p.Results.wave(:); 
        obj.opticalDensity = p.Results.opticaldensity(:);

    end % Constructor
    
    % Getter methods for dependent variables
    function val = get.absorbance(obj) % interpolate for absorbance
        % Retrieve photo pigment object's absorbance value
        %
        % Syntax:
        %   obj = get.absorbance(obj)
        %
        % Description:
        %    Retrieve the absorbance from the photoPigment object obj
        %
        % Inputs:
        %    obj - The photoPigment object
        %
        % Outputs:
        %    val - The absorbance value for obj
        %
        % Optional key/value pairs:
        %    None.
        
        % DHB: Careful handling of long wavelengths beyond those in our table of
        % photopigment absorbance. We linearly extrapolate the values out,
        % but do so not just on the last 1 nm base but on a larger spacing
        % to stablilize the extrapolation.  Perhaps too clever by half but
        % we need estimates for wavelengths greater then the 830 in our
        % typical table for AO modeling.  We don't need these to be
        % perfect, but the extrapolation based on the last two points was
        % not good. I wrote this not to change the behavior if no requested
        % wavelengths exceed those in the table.
        maxWlInTable = max(obj.wave_(:));
        index2 = find(obj.wave > maxWlInTable);
        if (isempty(index2))
            val = interp1(obj.wave_, obj.absorbance_, obj.wave, ...
                'linear', 'extrap');
        else
            extrapolationBaseNm = 30;
            index1 = find(obj.wave <= maxWlInTable);
            temp1 = interp1(obj.wave_, obj.absorbance_, obj.wave(index1), ...
                'linear', 'extrap');
            index3 = find(obj.wave_ < maxWlInTable - extrapolationBaseNm);
            if (isempty(index3))
                error('Do not have enough data in table for requested long wavelength extrapolation base');
            else
                index4 = find(obj.wave_ == maxWlInTable);
                if (length(index4) ~= 1)
                    error('We do not understand something really basic about Matlab');
                end
                temp2 = 10.^interp1(obj.wave_([index3(end) index4(1)]), log10(obj.absorbance_([index3(end) index4(1)],:)), obj.wave(index2), ...
                    'linear', 'extrap');
                val = [temp1 ; temp2];
            end
        end
        val = ieClip(val, 0, 1);
    end

    function val = get.absorptance(obj) % compute absorptance
        % Retrieve photo pigment object's absorptance value
        %
        % Syntax:
        %   obj = get.absorptance(obj)
        %
        % Description:
        %    Retrieve the absorptance from the photoPigment object obj
        %
        % Inputs:
        %    obj - The photoPigment object
        %
        % Outputs:
        %    val - The absorptance value for obj
        %
        % Optional key/value pairs:
        %    None.
        %
        val = 1 - 10 .^ (-obj.absorbance * diag(obj.opticalDensity));
    end

    % function val = get.quantalEfficiency(obj) % compute absorptance
    %     % Retrieve photo pigment object's isomerization efficiency.
    %     %
    %     % Syntax:
    %     %   obj = get.quantalEfficiency(obj)
    %     %
    %     % Description:
    %     %    Retrieve the quantal efficiency from the photoPigment object obj
    %     %
    %     % Inputs:
    %     %    obj - The photoPigment object
    %     %
    %     % Outputs:
    %     %    val - The LMS quantal efficiencies for obj
    %     %
    %     % Optional key/value pairs:
    %     %    None.
    %     %
    %     val = obj.absorptance*diag(obj.peakEfficiency);
    % end
    % 
    % function val = get.quantaFundamentals(obj)
    %     % compute and return quanta fundamentals
    %     %
    %     % Syntax:
    %     %   obj = get.quantaFundamentals(obj)
    %     %
    %     % Description:
    %     %    Compute and return the quanta fundamentals for the photo
    %     %    pigment object obj.
    %     %
    %     % Inputs:
    %     %    obj - The photoPigment object
    %     %
    %     % Outputs:
    %     %    val - The quanta fundamentals for obj
    %     %
    %     % Optional key/value pairs:
    %     %    None.
    %     %
    %     val = bsxfun(@rdivide, obj.absorptance, max(obj.absorptance));
    % end
    % 
    % function val = get.energyFundamentals(obj)
    %     % Retrieve photo pigment object's energy fundamentals
    %     %
    %     % Syntax:
    %     %   obj = get.energyFundamentals(obj)
    %     %
    %     % Description:
    %     %    Retrieve the energy fundamentals from the photoPigment object
    %     %
    %     % Inputs:
    %     %    obj - The photoPigment object
    %     %
    %     % Outputs:
    %     %    val - The energy fundamentls for obj
    %     %
    %     % Optional key/value pairs:
    %     %    None.
    %     %
    %     h = vcConstants('planck');
    %     c = vcConstants('speed of light');
    %     val = 1e-9 * bsxfun(@times, obj.quantaFundamentals / h / c, ...
    %         obj.wave);
    % end
    % 
end % Public methods


end