function val = fluorophoreGet(fl,param,varargin)
% The get method of the fluorophore object. 
%
% Syntax
%  val = fluorophoreGet(fl,param,...)
% 
% Extract values from a the fluorophore structure.
%
% Inputs
%  fl:     Fluorophore objects
%  param:  Parameter to retrieve
%
% Optional parameters
%   Depend on the value of param
%
% Examples:
%   em = fluorophoreGet(fl,'emission');
%   name = fluorophoreGet(fl,'name');
% 
%   ill = illuminantCreate('d65');
%   ph = fluorophoreGet(fl,'photons',ill);
%
% Inputs:
%   fl - a fluorophore structure
%   param - a string describing the parameter of the fluorophore to be
%      returned. Param can have the following values
%
%      'name'                     - fluorophore name
%      'solvent'                  - fluorophore solvent
%      'comment'                  - comment string
%      'type'                     - always 'fluorophore'
%
%      'emission'                 - fluorophore's emission spectrum
%      'normalized emission'      - fluorophore's emission normalized to
%                                   unit amplitude
%      'peak emission'            - peak emission wavelenght in nm
%
%      'excitation'               - fluorophore's excitation spectrum
%      'peak excitation'          - peak excitation wavelength in nm
%      'normalized excitation'    - fluorophore's excitation spectrum
%                                   normalized to unit amplitude
%
%      'Donaldson matrix'         - fluorophore's Donaldson matrix
%
%
%      'Stokes shift'             - wavelength shift between excitation and
%                                   emission peaks
%      'qe'                       - fluorophore's quantum efficiency
%
%      'wave'                     - spectral sampling vector
%      'delta wave'               - interval between concescutive spectral
%                                   samples in nm
%      'nwave'                    - number of spectral samples
%
%      'photons'                  - photons emitted by the fluorophore
%                                   under a particular illuminant. The 
%                                   illuminant is an ISET structure and
%                                   needs to be passed as a parameter (see
%                                   example).
%
% Outputs:
%    val - the value of the requested property.
%
% Copyright Henryk Blasinski, 2016

%% Parameter checking
if ~exist('fl','var') || isempty(fl), error('Fluorophore structure required'); end
if ~exist('param','var') || isempty(param), error('param required'); end

val = [];

%% Main switch statement
param = lower(param);
param = strrep(param,' ','');

switch param
    case 'name'
        val = fl.name;

    case 'type'
        % Should always be 'fluorophore'
        val = fl.type;
       
    case {'emission','emission photons','Emission photons','emissionphotons'}
        
        if ~checkfields(fl,'emission'), val = []; return; end
        val = fl.emission;

    case {'norm emission','normemission','normalizedemission'}
        if ~checkfields(fl,'emission'), val = []; return; end
        val = fl.emission/max(fl.emission);
        
    case {'excitation','excitationphotons'}
        
        if ~checkfields(fl,'excitation'), val = []; return; end
        val = fl.excitation;
        
    case {'norm excitation','normexcitation','normalizedexcitation'}
        if ~checkfields(fl,'excitation'), val = []; return; end
        val = fl.excitation/max(fl.excitation);
        
    case {'peakexcitation','peak excitation'}
        if ~checkfields(fl,'excitation'), val = []; return; end
        [~, id] = max(fl.excitation);
        val = fl.spectrum.wave(id);    
        
    case {'peakemission','peak emission'}
        if ~checkfields(fl,'emission'), val = []; return; end
        [~, id] = max(fl.emission);
        val = fl.spectrum.wave(id);
        
    case {'Stokes shift','stokesshift'}
        val = fluorophoreGet(fl,'peakemission') - fluorophoreGet(fl,'peakexcitation');
        
    case 'wave'
        if isfield(fl,'spectrum'), val = fl.spectrum.wave; end
        if isvector(val), val = val(:); end
        
    case {'deltawave','deltaWave'}
        wave = fluorophoreGet(fl,'wave');
        val = wave(2) - wave(1);
     
    case {'donaldsonmatrix'}
        
        % If the fluorophore is defined in terms of the Donaldson matrix,
        % then return the matrix, otherwise compute it from the excitation
        % and emission spectra.
        deltaL = fluorophoreGet(fl,'deltaWave');

        if isfield(fl,'donaldsonMatrix')
            val = fl.donaldsonMatrix*deltaL;
        else
               
            ex = fluorophoreGet(fl,'excitation photons');
            em = fluorophoreGet(fl,'emission photons');
            qe = fluorophoreGet(fl,'qe');
            
            % Apply the Stoke's constraint
            val = qe*tril(em*ex',-1)*deltaL;
        end
        
    case {'photons'}
        illWave  = illuminantGet(varargin{1},'wave');
        illSpd = illuminantGet(varargin{1},'photons');
        
        fl = fluorophoreSet(fl,'wave',illWave);
        DM = fluorophoreGet(fl,'Donaldson matrix');

        val = DM*illSpd;
        
    case 'nwave'
        
        val = length(fluorophoreGet(fl,'wave'));
        
    case 'comment'
        val = fl.comment;
    
    case 'qe'
        if isfield(fl,'qe')
            val = fl.qe;
        end
        
    case 'solvent'
        val = fl.solvent;
        
    otherwise
        error('Unknown fluorescence parameter %s\n',param)
end

end
