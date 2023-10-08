function [circ, xDist] = opticsCoC( optics, oDist, varargin )
% Circle of confusion diameter 
%
%  Syntax:
%    [circDiameter, xDist] = opticsCoC(optics, oDist, varargin)
%
%  Brief description:
%    The default blur circle is calculated for an object at a distance
%    oDist (meters) on the surface of a sensor positioned at the focal
%    distance from the lens. This calculation is an approximation for a
%    thin lens.
%
%    If we set 
%
%  Parameters
%    optics - optics struct (required)
%    oDist  - distance to the object in focus (meters)
%
%  Optional key/val pairs
%    unit  - Spatial units of the circle diameter ('m' default)
%    xDist - Evaluation distances in meters (usually closer and further
%            than the oDist
%    nSamples - How many distance samples
%
%  Return
%    circDiameter - Circle of confusion diameter
%
% We use ray trace geometry to compute the circle size.  We could impose a
% limit for diffraction, but it is not relevant for this calculation.
%
% Suppose the in-focus image point, O, is at the object distance, oDist.
% The optics focal length is f. Then O is brought to focus at fO,
% determined by the Lensmaker's Equation.
%
% Consider another point, say X, at distance xDist.  It will be in focus at
% fX, also calculated by the Lensmaker's equation.
% 
% First, imagine that X is closer thanO and thus fX is beyond fO. The
% spread of the rays from X at the focal plane, fO - the circle of
% confusion - is calculated from the two similar right triangles (see
% course powerpoint). One triangle has a side A/2 and fX, and the smaller,
% similar triangle has one side (fX - fO) and another side (A/2)*(fX -
% fO)/fX. This side is half the diameter of the circle of confusion.
%
% Second, imagine that fX is closer than fO. There will still be similar
% triangles.  But the length of the short side is fO - fX. 
%
% So the general formula for the diameter of the circle of confusion on the
% sensor surface is
%
%     CoC = 2 * (A/2) * abs(fX - fO)/fX 
%         = A * abs(fX - fO)/fX
%
% where fX and fO are derived from the LensMaker's equation for points O
% and X at distance oDist and xDist.
%
% To calculate the depth of field, we find two distances in object space
% that have the same circle of confusion. One point (X) will be closer than
% O (xDist < oDist) and the other point (Y) will be further than the object
% point, O (yDist > oDist).  The distance between those two points is the
% depth of field (at a distance P, and a criterion circle of confusion).
%
%    2 * (A/2) * abs(fX - fO)/fX  =  2 * (A/2) * abs(fY - fO)/fY
%
% We leave it as an exercise to cancel the terms, insert the Lensmaker's
% equation, and solve for these two distances.
%
% Programming: Perhaps this should just be a call
%
%      opticsGet(optics,'coc',dist,unit)
%
%  and perhaps we should never let this be smaller than the
%  diffraction limit, and there should be a call
%
%      opticsGet(optics,'diffraction limit diameter');
%
% The circle of confusion calculation has a wonderful history
%
%   http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
%
% Wikipedia includes the original wonderful article, written in 1866,
% describing the geometry. 
%
% Example:
%   optics = opticsCreate;
%   oDist = 1;    opticsCoC(optics,oDist,'um')  % Far away
%   oDist = 0.2;  opticsCoC(optics,oDist,'um')  % Close
%
% Copyright Imageval Consulting, LLC 2015
%
% See also
%  s_opticsCoC

%Examples:
%{
optics = opticsCreate;
optics = opticsSet(optics,'focal length',0.100); % 50 mm
optics = opticsSet(optics,'fnumber',20);  
oDist = 3; 
[cocDiam, xDist] = opticsCoC(optics,oDist,'unit','um');
ieNewGraphWin; plot(xDist,cocDiam); grid on;
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('optics',@isstruct);
p.addRequired('oDist',@(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('unit','m',@ischar);
p.addParameter('xdist',[],@isvector);
p.addParameter('nsamples',21,@isnumeric);   % Odd is a little better

p.parse(optics,oDist,varargin{:});

unit  = p.Results.unit;
xDist = p.Results.xdist;
nSamples = p.Results.nsamples;

if isempty(xDist)
    % Sample distances around the oDist
    xDist = 10.^(log10(oDist) + linspace(-0.5,0.5,nSamples));
end

% But only include object distances beyond the focal length
fL = opticsGet(optics,'focal length','m');
xDist = xDist(xDist > fL);

% Lensmaker's Equation that computes the image distance for an object
% distance x and a thin lens with focal length f.
%
% This can take an array of x distances as input
lm = @(dist,f)(1 ./ ( (1 / f) - (1 ./ dist)));

%% Basic parameters

% Aperture
A = opticsGet(optics,'diameter','m');

% Focal length
f = opticsGet(optics,'focal length','m');

% Image points using the lensmaker's equation
fO = lm(oDist,f);   % This is the focal plane given an object at oDist
fX = lm(xDist,f);   % These are the test distances
fX = max(fX,0);     % We can't have any planes less than 0

circ = A * abs(fX - fO)./fX;

% This is the magnification.  The cone of confusion back in object space is
% the circ times the magnification.  We could return this, but not needed.
% magnification = fO / oDist;
%

% Deal with the units
circ = circ*ieUnitScaleFactor(unit);

end




