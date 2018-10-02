function fl = fluorophoreCreate(varargin)
% Creates a fluorophore structure
%
% Syntax
%  fl = fluorophoreCreate(...)
%
% Descripton
%   A fluorophore scructure is a basic unit summarizing fluorescence
%   properties of a particular point in space. A fluorophore is defined in
%   terms of its excitation and emission spectra OR its Donaldson matrix.
%   The two representations are mutually exclusive, i.e. settgin excitation
%   and/or emission spectra deletes the Donaldson matrix field and vice
%   versa.
%
% Inputs (optional)
%   'type' - describes the type of fluorophore that is created. Currently
%      supported options are
%      'default' - no other input parameters are expected. Creates generic
%         excitation and emission spectrum as gaussian curves.
%      'custom' - create a fluorophore from fluorescence excitation and
%         emission spectra. When 'custom' type is specified the user should
%         also provide parameters: 'wave','name','solvent','excitation
%         photons','emission photons','qe'.
%      'fromdonaldsonmatrix' - create a fluorophore given its Donaldson
%         matrix properties. When 'fromdonaldsonmatrix' is specified, the
%         user should also provide parameters: 'wave','name','solvent',
%         'DonaldsonMatrix'
%   'wave' - a (w x 1) vector of wavelength sampling interval 
%      (default = 400:10:700)
%   'name' - the name of the fluorophore.
%   'solvent' - the name of the solvent in which the fluorophore is
%      diluted. Same fluorophore with different solvents can produce 
%      different fluorescence properties.
%   'excitation' - a (w x 1) vector representing the fluorescence
%      excitation properties (default = [0 0 ... 0]).
%   'emission' - a (w x 1) vector representing the fluorescence emission
%      properties (default = [0 0 ... 0]).
%   'qe' - fluorophore quantum efficiency, defined as the ratio between
%      total number of incident and emitted photons (default = 1).
%   'DonaldsonMatrix' - a (w x w) array representing the Donaldson matrix
%      of a particualr fluorophore (default = []).
%
% Outputs
%    fl - a fluorophore structure
%
% Copyright Henryk Blasinski 2016

%%
p = inputParser;

p.addParameter('type','default',@ischar);
p.addParameter('wave',400:10:700,@isvector);
p.addParameter('name','',@(x)(ischar(x) || isempty(x)));
p.addParameter('solvent','',@(x)(ischar(x) || isempty(x)));
p.addParameter('excitation',zeros(31,1),@isnumeric);
p.addParameter('emission',zeros(31,1),@isnumeric);
p.addParameter('qe',1,@isscalar);
p.addParameter('DonaldsonMatrix',[],@isnumeric);

p.parse(varargin{:});
inputs = p.Results;

%% Initialize the struct

fl.name = inputs.name;
fl.type = 'fluorophore';
fl = initDefaultSpectrum(fl,'custom',inputs.wave);


%% Fill in the struct according to the different parameter type

type = lower(inputs.type);
type = strrep(type,' ','');

switch type
    
    case 'fromdonaldsonmatrix'
        fl = fluorophoreCreate('wave',inputs.wave);
        fl = fluorophoreSet(fl,'name',inputs.name);
        fl = fluorophoreSet(fl,'solvent',inputs.solvent);
        fl = fluorophoreSet(fl,'Donaldson matrix',inputs.DonaldsonMatrix);
        fl = fluorophoreSet(fl,'qe',1);
    
    case 'custom'
    
        fl = fluorophoreCreate('wave',inputs.wave);
        fl = fluorophoreSet(fl,'name',inputs.name);
        fl = fluorophoreSet(fl,'solvent',inputs.solvent);
        fl = fluorophoreSet(fl,'excitation photons',inputs.excitation);
        fl = fluorophoreSet(fl,'emission photons',inputs.emission);
        fl = fluorophoreSet(fl,'qe',inputs.qe);
    
    case 'default'
        
        % Create a default, idealized fluorophore with Gaussian excitation
        % and emission spectra
        
        deltaL = inputs.wave(2) - inputs.wave(1);

        emWave = 550;   % Default peak emission wavelength
        em = exp(-(fl.spectrum.wave - emWave).^2/2/(15^2));
        em = em/sum(em)/deltaL;
        
        exWave = 450;   % Default peak excitation wavelength
        ex = exp(-(fl.spectrum.wave - exWave).^2/2/(15^2));
        ex = ex/max(ex);
        
        fl = fluorophoreSet(fl,'excitation photons',ex);
        fl = fluorophoreSet(fl,'emission photons',em);
        fl = fluorophoreSet(fl,'qe',1);
        fl = fluorophoreSet(fl,'solvent','');
                
end


return;
