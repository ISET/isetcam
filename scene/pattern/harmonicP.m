function params = harmonicP(varargin)
% Default harmonic params
%
%   params = harmonicP;
%
% Generally  used with scene = sceneCreate('harmonic',params).  This creates a
% harmonic scene.  Also used with oisCreate('harmonic', ...).
%
%  name  - Used by oiSequence.visualize
%  ang   - Orientation (angle) of the grating
%  contrast  - Contrast
%  freq      - Spatial frequency (cycles/image)
%  ph        - Phase (0 is center of image)
%  row       - rows and cols
%  col
%  GaborFlag - Gaussian window, standard deviation re: window size
%
% To create the sum of two gratings, set these parameters as vectors
%
%   ang, contrast, freq and ph
%
% Example
%   p = harmonicP; p.name = 'example'; s = sceneCreate('harmonic',p);
%   ieAddObject(s); sceneWindow;
%
%   p.ang = [0 pi/4]; p.contrast = [.6 .6]; p.freq = [4 8]; p.ph = [0 0];
%   s = sceneCreate('harmonic',p);ieAddObject(s); sceneWindow;
%
% See also
%
% BW, ISETBIO Team, 2016

%% Parse arguments

p = inputParser;

p.addParameter('name','harmonicP',@ischar);
p.addParameter('ang',0,@isnumeric);
p.addParameter('contrast',1,@isnumeric);
p.addParameter('freq',1,@isnumeric);
p.addParameter('ph',pi/2,@isnumeric);
p.addParameter('row',64,@isscalar);
p.addParameter('col',64,@isscalar);
p.addParameter('GaborFlag',0,@isscalar);

p.parse(varargin{:});

%% Assign parameters

params.name      = p.Results.name;
params.ang       = p.Results.ang;
params.contrast  = p.Results.contrast;
params.freq      = p.Results.freq;
params.ph        = p.Results.ph;
params.row       = p.Results.row;
params.col       = p.Results.col;
params.GaborFlag = p.Results.GaborFlag;

end
