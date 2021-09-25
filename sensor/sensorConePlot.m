function [support, spread, delta] = sensorConePlot(sensor,support,spread,delta)
% Plot the cone array contained in sensor
%
%   [support, spread, delta] = sensorConePlot(sensor,[support],[spread],[delta])
%
% This should only be run when you have a human sensor based on a cone
% mosaic. This plotting routine will not run correctly (or at all) for
% non-human mosaics.
%
% The parameters support, spread and delta define the appearance of the
% plotted cone mosaic.  Each cone is rendered as a small blurry gaussian
% with support and spread as passed in.  The spatial sampling is delta.
%
% If you are particularly interested in biological applications, then you
% might consider using ISETBIO.
%
% See also:  humanConeMosaic, conePlot, sensorCreateConeMosaic,
%            sensorShowCFA, sensorCreate
%
% Examples:
%
% All filled up, old defaults
%   sensor = sensorCreateConeMosaic(sensorCreate,[120,120],[.6 .3 .1]);
%   sensorConePlot(sensor)
%
%   support = [7 7]; spread = 3; delta = .1;
%   sensorConePlot(sensor,support,spread,delta)
%
% Some empty spots (black).  New imaging defaults.
%   sensor = sensorCreateConeMosaic(sensorCreate,[120,120],[.1 .5 .3 .1]);
%   support = [5 5]; spread = 2; delta = .2;
%   sensorConePlot(sensor,support,spread,delta)
%
% Copyright ImagEval, 2010

if ieNotDefined('support'), support = []; end
if ieNotDefined('spread'), spread = []; end
if ieNotDefined('delta'), delta = []; end

% Read cone mosaic parameters and call cone plotting routine to make it
% look reasonably nice.
xy       = sensorGet(sensor,'human cone locs');
coneType = sensorGet(sensor,'cone type');
if isempty(xy)
    % A regular block array with human cones (rather than random mosaic).
    % Even so, we show the whole sensor CFA, as below for conePlot.
    fullArray = 1;
    sensorShowCFA(sensor,fullArray);
else
    [support, spread, delta] = conePlot(xy, coneType, support, spread, delta);
end

end
