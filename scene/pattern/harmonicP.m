function params = harmonicP(varargin)
% Default harmonic params
%
% Syntax:
%	params = harmonicP([varargin]);
%
% Description:
%    Generally  used with scene = sceneCreate('harmonic', params).  This
%    creates a harmonic scene.  Also used with oisCreate('harmonic', ...).
%
%    To create the sum of two gratings, set the following parameters as
%    vectors: ang, contrast, freq and ph.
%
% 
% Inputs:
%    varargin - (Optional) A structure containing one or more of the
%    following options (defaults listed within):
%       name      - Used by oiSequence.visualize. Default 'harmonicP'.
%       ang       - Orientation (angle) of the grating. Default 0 degrees.
%       contrast  - Contrast. Default 1.
%       freq      - Spatial frequency (cycles/image). Default 1.
%       ph        - Phase (0 is center of image). Default pi/2.
%       row       - Rows. Default 65.
%       col       - Columns. Default 65.
%       center    - position within the support. Default [0 0]
%       GaborFlag - Gaussian window, standard deviation re: window size.
%                   Default 0.
%
% Outputs:
%    params       - The structure containing the amalgamated parameters.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/16  BW   ISETBIO Team, 2016
%    02/02/18  jnm  Formatting

% Examples:
%{
    p = harmonicP;
    p.name = 'example';
    s = sceneCreate('harmonic', p);
    ieAddObject(s);
    sceneWindow;

    p.ang = [0 pi / 4];
    p.contrast = [.6 .6];
    p.freq = [4 8];
    p.ph = [0 0];
    s = sceneCreate('harmonic', p);
    ieAddObject(s);
    sceneWindow;
%}

%% Parse arguments
p = inputParser;
p.addParameter('name', 'harmonicP', @ischar);
p.addParameter('ang', 0, @isnumeric);
p.addParameter('contrast', 1, @isnumeric);
p.addParameter('freq', 1, @isnumeric);
p.addParameter('ph', pi / 2, @isnumeric);
p.addParameter('row', 65, @isscalar);
p.addParameter('col', 65, @isscalar);
p.addParameter('center',[0 0],@isvector);
p.addParameter('GaborFlag', 0, @isscalar);


p.parse(varargin{:});

%% Assign parameters
params.name = p.Results.name;
params.ang = p.Results.ang;
params.contrast = p.Results.contrast;
params.freq = p.Results.freq; 
params.ph = p.Results.ph;
params.row = p.Results.row; 
params.col = p.Results.col; 
params.center = p.Results.center; 
params.GaborFlag = p.Results.GaborFlag;

end
