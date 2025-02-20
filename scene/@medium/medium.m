classdef medium < hiddenHandle
% Abstract class (interface) for participating media.
%
% This class contains properties for the participating media properties. We
% are starting with transmission through blood (oxy and deoxy).
%
% Subclasses of @medium inherit spectral properties and methods from
% @medium.  Using this superclass scheme, enforces consistency amongst all
% subclasses in terms of how they handle spectral properties.  So far,
% though, we have no subclasses.
%
% A file can contain multiple absorbances.  Better have good comments for
% those!
%
% Description:
%    Our understanding of the terminology for describing medium
%    properties is below.
%
%    In general, the spectral data for the different media are stored in
%    columns.  This applies to all of the parameters below.
%
%    obj.absorbance  - the absorbance spectra of the medium, normalized to
%    a peak value of 1. This describes the absorbed light for a thin sheet
%    of the medium. 
% 
%    The normalization to peak of 1 is a convention that lets us explicitly
%    specify the density: obj.opticalDensity*ojb.absorbance. Some
%    scientists might call the product the absorbance, but we prefer to
%    keep the density and normalized absorbance separate.
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
   deoxyblood.comment
%}
%{
  oxyblood = medium('oxyHemoglobin.mat','wave',400:1:700);
  oxyblood.comment
%}
%{
  % Hmm.  This has four terms but only three are in the comment
  skin = medium('SkinComponentAbsorbances.mat','wave',400:1:700);
  ieNewGraphWin; plot(skin.wave,skin.transmittance(:,1));
%}

% Public properties 
properties 
    % opticalDensity - photopigment optical densities for different cone types
    opticalDensity;
end

properties (Dependent)

    % spectral absorbance of the medium
    absorbance;
    
    % absorptance - absorptance without ocular media
    absorptance;

    % transmittance is 1 - absorptance
    transmittance;
    
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
    comment;
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
        
        % Normalize the absorbance to a peak of 1
        obj.filename = which(filename);
        [obj.absorbance_,obj.wave_, obj.comment] = ieReadSpectra(filename);
        obj.absorbance_ = obj.absorbance_/max(obj.absorbance_(:));

        % set wavelength and specified optical density
        obj.wave = p.Results.wave(:); 
        obj.opticalDensity = p.Results.opticaldensity(:);

    end % Constructor
    
    
    % Interpolate from the original data
    % So far, I am not saving the interpolated data.  Maybe I should and
    % then update it when 'wave' changes.
    function val = get.absorbance(obj)
        val = interp1(obj.wave_,obj.absorbance_,obj.wave,'pchip');
    end

    % absorptance and transmittance are complements
    function val = get.transmittance(obj)
        val = 1 - obj.absorptance;
    end


    function val = get.absorptance(obj) % compute absorptance
        val = 1 - 10 .^ (-obj.absorbance * diag(obj.opticalDensity));
    end

    
end % Public methods


end