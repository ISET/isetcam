function params = harmonicP(varargin)
% Default harmonic params
%
% Syntax:
%	params = harmonicP([varargin]);
%
% Description:
%    Generally used with scene = sceneCreate('harmonic', params) to
%    create a scene comprising one or the sum of a few harmonics.
%
%    Also used with oisCreate('harmonic', ...).
%
%    To create the sum of two harmonics, set the following parameters as
%    vectors: 
%      ang (orientation)
%      contrast
%      freq (frequency)
%      ph (phase)
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
%   You can use aliases for several of the parameters
% 
%     ang | orientation
%     freq | frequency
%     ph | phase
%     [row,col] | 'image size'.  
% 
%  The aliases, if present, override the values in ang, freq, ph,[row,col]. 
% 
% Outputs:
%    params - The structure containing the parameters, including defaults.
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
sceneWindow(s);
%}
%{
% Multiple harmonics
p = harmonicP('orientation',[0 pi/4], 'contrast',[1 0.5], ...
    'frequency',[4 8],'phase',[0 0],'gabor flag',0.2);    
s = sceneCreate('harmonic', p);    
sceneWindow(s);
%}

%% Parse arguments
varargin = ieParamFormat(varargin);

p = inputParser;

p.addParameter('name', 'harmonicP', @ischar);
p.addParameter('ang', 0, @isnumeric);
p.addParameter('orientation', [], @isnumeric);
p.addParameter('contrast', 1, @isnumeric);
p.addParameter('freq', 1, @isnumeric);
p.addParameter('frequency', [], @isnumeric);
p.addParameter('ph', pi / 2, @isnumeric);
p.addParameter('phase', [], @isnumeric);
p.addParameter('row', 65, @isscalar);
p.addParameter('col', 65, @isscalar);
p.addParameter('imagesize',[],@isscalar);
p.addParameter('center',[0 0],@isvector);
p.addParameter('gaborflag', 0, @isscalar);


p.parse(varargin{:});

%% Assign parameters
params.name = p.Results.name;

params.ang = p.Results.ang;
if ~isempty(p.Results.orientation), params.ang = p.Results.orientation; end
params.contrast = p.Results.contrast;

params.freq = p.Results.freq; 
if ~isempty(p.Results.frequency), params.freq = p.Results.frequency; end

params.ph = p.Results.ph;
if ~isempty(p.Results.phase), params.ph = p.Results.phase; end

params.row = p.Results.row;
params.col = p.Results.col;
if ~isempty(p.Results.imagesize)
    params.row = p.Results.imagesize;
    params.col = p.Results.imagesize;
end

params.center = p.Results.center; 
params.GaborFlag = p.Results.gaborflag;

end
