function wvf = wvfCreate(varargin)
% Create a wavefront parameters structure.
%
% Syntax:
%   wvf = wvfCreate;
%
% Description:
%    Create the wavefront parameters structure.
%
%    The default parameters will give you diffraction limited PSF
%    for 550 nm light and a 3 mm pupil.
%
%    Many of the keys specified in the key/value pair section below accept
%    synonyms. The key listed is our preferred usage, see the code in
%    wvfKeySynonyms for available synonyms.
%   
%    The properties that may be specified here using key/value pairs may
%    also be set using wvfSet.  And, wvfSet gives more details of what they
%    mean.
%
% Inputs:
%    None required.
%
% Outputs:
%    wvf      - The wavefront object
%
% Optional key/value pairs:
%     'name'                               - 'default'
%     'type'                               - 'wvf'
%     'zcoeffs'                            - 0
%     'measured pupil'                     - 8
%     'measured wl'                        - 550
%     'measured optical axis'              - 0
%     'measured observer accommodation'    - 0
%     'measured observer focus correction' - 0
%     'sample interval domain'             - 'psf'
%     'spatial samples'                    - 201
%     'ref pupil plane size'               - 16.212
%     'calc pupil size'                    - 3
%     'calc wavelengths'                   - 550
%     'calc optical axis'                  - 0
%     'calc observer accommodation'        - 0
%     'calc observer focus correction'     - 0
%     'um per degree'                      - 300
%     'sce params'                         - Struct specifying no sce
%                                            correction.
%     'calc cone psf info'                 - Default structure returned by
%                                            conePsfInfoCreate.
%
% Examples are included in the code.     
%
% See Also:
%    wvfSet, wvfGet, wvfKeySynonyms, sceCreate, sceGet
%

% History:
%    xx/xx/11       (c) Wavefront Toolbox Team 2011, 2012
%    07/20/12  dhb  Get rid of weighting spectrum, replace with cone psf
%                   info structure
%    12/06/17  dhb  Use input parser to handle key/value pairs. This was
%                   previously being done in a manner that may not have
%                   matched up with the documentation.
%    12/08/17  dhb  Add um per degree. We need control over this to match
%                   up across calculations. Default is 300, whereas 330
%                   used to be hard coded in the wvf calculations. The
%                   difference messed up comparison with oi based
%                   calculation
%    07/05/22  npc  Custom LCA

% Examples:
%{
	wvf = wvfCreate('calc wavelengths', [400:10:700]);
%}

%% Input parse
%
% Run ieParamFormat over varargin before passing to the parser,
% so that keys are put into standard format
p = inputParser;
p.addParameter('name', 'default', @ischar);
p.addParameter('type', 'wvf', @ischar);

% Zernike coefficients and related
p.addParameter('zcoeffs', 0, @isnumeric);
p.addParameter('measuredpupil', 8, @isscalar);
p.addParameter('measuredwl', 550, @isscalar);
p.addParameter('measuredopticalaxis', 0, @isscalar);
p.addParameter('measuredobserveraccommodation', 0, @isscalar);
p.addParameter('measuredobserverfocuscorrection', 0, @isscalar);

% Spatial sampling parameters
p.addParameter('sampleintervaldomain', 'psf', @ischar);
p.addParameter('spatialsamples', 201, @isscalar);
p.addParameter('refpupilplanesize', 16.212, @isscalar);

% Calculation parameters
p.addParameter('calcpupilsize', 3, @isscalar);
p.addParameter('calcwavelengths', 550, @isnumeric);
p.addParameter('calcopticalaxis', 0, @isscalar);
p.addParameter('calcobserveraccommodation', 0), @isscalar;
p.addParameter('calcobserverfocuscorrection', 0, @isscalar);

% Retinal parameters
p.addParameter('umperdegree', 300, @isscalar);

% Custom lca
p.addParameter('customlca', [], @(x)( (isempty(x)) || (isa(x, 'function_handle')) ));

% SCE parameters
p.addParameter('sceparams',sceCreate([],'none'), @isstruct);

% Cone PSF information
p.addParameter('calcconepsfinfo',conePsfInfoCreate,@isstruct);

% Whether to flip the PSF upside/down
p.addParameter('flipPSFUpsideDown', false, @islogical);
p.addParameter('rotatePSF90degs', false, @islogical);

% Massage varargin and parse
ieVarargin = ieParamFormat(varargin);
ieVarargin = wvfKeySynonyms(ieVarargin);
p.parse(ieVarargin{:});

%% Now set all of the properties that are specified by the parse above.
%
% This is done via wvfSet. 
wvf = [];
wvf = wvfSet(wvf, 'name', p.Results.name);
wvf = wvfSet(wvf, 'type', p.Results.type);

% Zernike coefficients and related
wvf = wvfSet(wvf, 'zcoeffs', p.Results.zcoeffs);
wvf = wvfSet(wvf, 'measured pupil', p.Results.measuredpupil);
wvf = wvfSet(wvf, 'measured wl', p.Results.measuredwl);
wvf = wvfSet(wvf, 'measured optical axis', p.Results.measuredopticalaxis);
wvf = wvfSet(wvf, 'measured observer accommodation', ...
    p.Results.measuredobserveraccommodation);
wvf = wvfSet(wvf, 'measured observer focus correction', ...
    p.Results.measuredobserverfocuscorrection);

% Spatial sampling parameters
wvf = wvfSet(wvf, 'sample interval domain', ...
    p.Results.sampleintervaldomain);
wvf = wvfSet(wvf, 'spatial samples', p.Results.spatialsamples);
wvf = wvfSet(wvf, 'ref pupil plane size', p.Results.refpupilplanesize);

% Calculation parameters
wvf = wvfSet(wvf, 'calc pupil size', p.Results.calcpupilsize);
wvf = wvfSet(wvf, 'calc wavelengths', p.Results.calcwavelengths);
wvf = wvfSet(wvf, 'calc optical axis', p.Results.calcopticalaxis);
wvf = wvfSet(wvf, 'calc observer accommodation', ...
    p.Results.calcobserveraccommodation);
wvf = wvfSet(wvf, 'calc observer focus correction', ...
    p.Results.calcobserverfocuscorrection);

% Conversion between degrees of visual angle and mm
wvf = wvfSet(wvf, 'um per degree',p.Results.umperdegree);

% Custom LCA function handle
wvf = wvfSet(wvf, 'custom lca',p.Results.customlca);

% Stiles Crawford Effect parameters
wvf = wvfSet(wvf, 'sce params', p.Results.sceparams);

% Cone PSF information
wvf = wvfSet(wvf, 'calc cone psf info', p.Results.calcconepsfinfo);

% Flip PSF upside down
wvf = wvfSet(wvf, 'flipPSFUpsideDown', p.Results.flipPSFUpsideDown);
wvf = wvfSet(wvf, 'rotatePSF90degs', p.Results.rotatePSF90degs);

end
