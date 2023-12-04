function inertP = humanOpticalDensity(visualField, wave)
% Create optical density default parameters
%
% Syntax:
%   inertP = humanOpticalDensity([visualField], [wave])
%
% Description:
%    Create the optical density default parameters.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanOpticalDensity.m' into the Command Window.
%
% Inputs:
%    visualField - (Optional) String. The string describing the visual
%                  field. Options can include a specific subject from HH's
%                  paper. Default is Stockman fovea 'fovea'. Options are:
%           'fov'  - Default. Stockman Fovea.
%           'peri' - Stockman Peripheral (at 10 deg.)
%           's1f'  - Subject 1 fovea
%           's1p'  - Subject 1 periphery
%           's2f'  - Subject 2 fovea
%           's2p'  - Subject 2 periphery
%    wave        - (Optional) Vector. The wavelength list. Default 390:730.
%
% Outputs:
%    inertP      - Struct. A structure containing the default parameters
%                  for the optical density as per the entered visual field.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    humanCones, ie.m
%

% History:
%    xx/xx/12  HH   (c) VISTA lab 2012
%    06/22/18  JNM  Formatting

% Examples:
%{
    fovParams = humanOpticalDensity('stockman fovea', 400:700)
    peripheryParams = humanOpticalDensity('stockman periphery', 400:700)
%}

%%
if notDefined('visualField'), visualField = 'fovea'; end
if notDefined('wave'), wave = 390:730; end

% Stash these variables
inertP.visfield = visualField;
inertP.wave = wave;

% Options are standard or a few possible subjects. We should probably have
% a random subject generator
visualField = ieParamFormat(visualField);
switch lower(visualField)
    % stockman foveal params (at 2 deg)
    case {'f', 'fov', 'fovea', 'stf', 'stockmanfovea'}
        % Default. Stockman, default of fovea
        inertP.lens = 1;        % Lens transmittance?
        inertP.macular = 0.28;  % Macular pigment density
        inertP.LPOD = 0.5;      % L, M, S cone pigment optical densities
        inertP.MPOD = 0.5;
        inertP.SPOD = 0.4;
        inertP.melPOD = 0.5;

    % stockman peripheral params (at 10 deg)
    case {'p', 'peri', 'periphery', 'stp', ...
            'stockmanperi', 'stockmanperiphery'}
        % Stockman, default of periphery
        inertP.lens = 1;
        inertP.macular = 0;
        inertP.LPOD = 0.38;
        inertP.MPOD = 0.38;
        inertP.SPOD = 0.3;
        inertP.melPOD = 0.5;

    case {'s1f'}
        % Subject 1 fovea
        inertP.lens = 0.7467;
        inertP.macular = 0.6910;
        inertP.LPOD = 0.4964;
        inertP.MPOD = 0.2250;
        inertP.SPOD = 0.1480;
        inertP.melPOD = 0.3239;
        inertP.visfield = 'f';

    case {'s1p'}
        % Subject 1 periphery
        inertP.lens = 0.7467;
        inertP.macular = 0;
        inertP.LPOD = 0.4964 ./ 0.5 .* 0.38;
        inertP.MPOD = 0.2250 ./ 0.5 .* 0.38;
        inertP.SPOD = 0.1480 ./ 0.4 .* 0.3;
        inertP.melPOD = 0.3239;
        inertP.visfield = 'p';

    case {'s2f'}
        % Subject 2 fovea
        inertP.lens = 0.7637;
        inertP.macular = 0.5216;
        inertP.LPOD = 0.4841;
        inertP.MPOD = 0.2796;
        inertP.SPOD = 0.2072;
        inertP.melPOD = 0.3549;
        inertP.visfield = 'f';

    case {'s2p'}
        % Subject 2 periphery
        inertP.lens = 0.7637;
        inertP.macular = 0;
        inertP.LPOD = 0.4841 ./ 0.5 .* 0.38;
        inertP.MPOD = 0.2796 ./ 0.5 .* 0.38;
        inertP.SPOD = 0.2072 ./ 0.4 .* 0.3;
        inertP.melPOD = 0.3549;
        inertP.visfield = 'p';
end
