function params = gaborP(varargin)
% Default Gabor params
%
% Syntax:
%	params = gaborP([varargin]);
%
% Description:
%    Default parameters for this function
%
% 
% Inputs:
%    varargin - (Optional) A structure containing one or more of the
%    following options (defaults listed within):
%
% Outputs:
%    params       - The structure containing the parameters.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/16  BW   ISETBIO Team, 2016
%    02/02/18  jnm  Formatting

% Examples:
%{
p = gaborP;
img = imageGabor(p);
imshow(img);
%}

%% Parse arguments
p = inputParser;
p.addParameter('orientation', 0, @isnumeric);
p.addParameter('contrast', 1, @isnumeric);
p.addParameter('frequency', 1, @isnumeric);
p.addParameter('phase', pi / 2, @isnumeric);
p.addParameter('imagesize', 65, @isscalar);
p.addParameter('spread', 10, @isscalar);


p.parse(varargin{:});

%% Assign parameters
params.orientation = p.Results.orientation;
params.contrast = p.Results.contrast;
params.frequency = p.Results.frequency; 
params.phase = p.Results.phase;
params.imagesize = p.Results.imagesize; 
params.spread = p.Results.spread;

end
